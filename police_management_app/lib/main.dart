// lib/main.dart
// App entry point: multi-provider setup, named routing, lifecycle auto-lock.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // PLATFORM FIX: Web-only URL strategy guard
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/news_provider.dart';
import 'providers/case_provider.dart';
import 'providers/module_registry.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'utils/app_constants.dart';
import 'utils/pdf_auth_gate.dart';
import 'utils/notification_service.dart';
import 'services/fcm_service.dart';
import 'providers/notification_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_pin_setup_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/transfer_request_screen.dart';
import 'screens/transfer_status_screen.dart';
import 'screens/pending_transfers_screen.dart';
import 'screens/station_access_grants_screen.dart';
import 'screens/login_security_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/classification_list_screen.dart';
import 'screens/pin_reauth_screen.dart';

import 'services/biometric_service.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // PLATFORM FIX: Web path URL routing parity

import 'dart:ui';

// ── FCM Background Message Handler ──────────────────────────────────────────
// Must be a top-level function (not a class method) per firebase_messaging docs.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background isolate.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch all Flutter framework errors so they show in console, not white screen.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[FLUTTER ERROR] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[ASYNC ERROR] $error\n$stack');
    return true; // handled
  };

  try {
    if (kIsWeb) usePathUrlStrategy(); // PLATFORM FIX: enable clean URLs on web without hash

    // Initialize Firebase (Supports all platforms including Web)
    try {
      await Future.any([
        Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        Future.delayed(const Duration(seconds: 5)).then((_) {
          throw TimeoutException('Firebase initialization timed out');
        }),
      ]);
    } catch (e) {
      debugPrint('[MAIN] Firebase initialization timed out/failed: $e');
    }

    // Register FCM background message handler (must be called before runApp).
    // PLATFORM FIX: Background messaging is NOT supported on web.
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // System chrome setup (fast, no await needed)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize local notifications (calendar reminders)
    // PLATFORM FIX: flutter_local_notifications does not support web.
    if (!kIsWeb) {
      NotificationService().initialize();
    }

    // Initialize FCM push notifications BEFORE runApp
    // so the foreground stream is ready when NotificationProvider starts listening.
    try {
      unawaited(FcmService().initialize());
    } catch (e) {
      debugPrint('[MAIN] FCM init failed (non-fatal): $e');
    }
  } catch (e, stack) {
    debugPrint('[MAIN] Pre-runApp initialization error: $e');
    debugPrint('[MAIN] Stack: $stack');
  }

  runApp(
    MultiProvider(
      providers: [
        // Critical providers (fast initialization)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
        ChangeNotifierProvider(create: (_) {
          final np = NotificationProvider();
          // Start listening to FCM stream after provider is created.
          np.startListening();
          return np;
        }),
        // Lazy-loaded module providers (initialized but not pre-fetching data)
        ...moduleProviders,
      ],
      child: const PoliceMgmtApp(),
    ),
  );
}

class PoliceMgmtApp extends StatefulWidget {
  const PoliceMgmtApp({super.key});

  @override
  State<PoliceMgmtApp> createState() => _PoliceMgmtAppState();
}

/// ISSUE 3: WidgetsBindingObserver detects app lifecycle changes for auto-lock.
class _PoliceMgmtAppState extends State<PoliceMgmtApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  late final AppLifecycleListener _lifecycleListener;
  bool _authPromptInFlight = false;
  bool _skipFirstResume = true;
  OverlayEntry? _lockOverlay;
  // The system biometric prompt itself triggers a paused→resumed transition
  // when it closes, which would otherwise re-fire `onResume` and pop a second
  // prompt. Use a short cool-down after a successful auth to absorb that.
  DateTime? _lastSuccessfulAuth;
  static const Duration _resumeCooldown = Duration(seconds: 2);
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // AppLifecycleListener.onResume only fires on transition to
    // AppLifecycleState.resumed — never on inactive/paused.
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleAppResume,
    );
  }

  @override
  void dispose() {
    _removeLockOverlay();
    _lifecycleListener.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleAppResume() async {
    // Skip the very first resume after cold start so we don't double-prompt
    // on top of the normal launch flow.
    if (_skipFirstResume) {
      _skipFirstResume = false;
      return;
    }
    // Web: do not enforce PIN/biometric overlay on resume.
    if (kIsWeb) return;
    // Don't stack prompts: PIN overlay already up, or auth already running.
    if (_lockOverlay != null) return;
    if (_authPromptInFlight) return;
    // PDF download auth: cancelling the **first** biometric dismisses that
    // UI and fires `resumed`, which must NOT stack the global resume biometric
    // on top of the PDF PIN overlay (see `isPdfDownloadAuthGateActive`).
    if (isPdfDownloadAuthGateActive) return;
    // Cool-down: the system biometric prompt itself causes a spurious
    // resume when it closes. Skip if we successfully authenticated very
    // recently — otherwise the prompt would re-appear immediately.
    final last = _lastSuccessfulAuth;
    if (last != null && DateTime.now().difference(last) < _resumeCooldown) {
      return;
    }
    final navState = _navKey.currentState;
    if (navState == null) return;

    _authPromptInFlight = true;
    try {
      // Small delay to let the OS finish bringing the app to the foreground.
      // Without this, the biometric prompt can fail to appear or refuse the
      // first fingerprint attempt right after AppLifecycleState.resumed.
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      final hasBiometric = await _biometricService.isBiometricAvailable();
      if (hasBiometric) {
        // Show ONLY the system biometric prompt — no custom UI / no route push.
        // The screen the user was on stays exactly where it was; on success
        // there's nothing to remove, the system prompt simply dismisses.
        bool ok = false;
        try {
          ok = await _biometricService.authenticate(
            localizedReason: 'Authenticate to continue',
          );
        } catch (_) {
          ok = false;
        }
        if (ok) {
          _lastSuccessfulAuth = DateTime.now();
          return;
        }
        // If biometrics fail/cancel, fall through to compulsory PIN.
      }
      // No fingerprint hardware / not enrolled / biometric failed → PIN
      // shown as an OverlayEntry on top of the existing UI (no nav push,
      // no pop to home). Removing the entry returns the user to the same
      // screen they were on before backgrounding.
      _showPinLockOverlay();
    } finally {
      _authPromptInFlight = false;
    }
  }

  void _showPinLockOverlay() {
    if (_lockOverlay != null) return;
    final overlay = _navKey.currentState?.overlay;
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => PinReauthScreen(
        onAuthSuccess: _removeLockOverlay,
      ),
    );
    _lockOverlay = entry;
    overlay.insert(entry);
  }

  void _removeLockOverlay() {
    final entry = _lockOverlay;
    if (entry == null) return;
    _lockOverlay = null;
    entry.remove();
    _lastSuccessfulAuth = DateTime.now();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = context.read<AuthProvider>();

    // User requested to NOT lock when app is in 'recents' (inactive/paused)
    /*
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Immediate lock on background
      auth.lockApp();
    } else 
    */
    if (state == AppLifecycleState.detached) {
      // App fully closed → lock immediately
      auth.lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'Police Management System',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navKey,
      theme: AppTheme.lightTheme(fontScale: settings.fontScale),
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // ── Named routes ───────────────────────────────────────────────────────
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (ctx) {
          final auth = ctx.read<AuthProvider>();
          // Registration is pre-auth only — never stack it on an active dashboard.
          if (auth.isSessionActive) return const DashboardScreen();
          return const RegisterScreen();
        },
        AppRoutes.registerPendingApproval: (_) => const PendingApprovalScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.transferRequest: (_) => const TransferRequestScreen(),
        AppRoutes.pendingTransfers: (_) => const PendingTransfersScreen(),
        AppRoutes.transferStatus: (_) => const TransferStatusScreen(),
        AppRoutes.stationAccessGrants: (_) => const StationAccessGrantsScreen(),
        AppRoutes.loginSecurity: (_) => const LoginSecurityScreen(),
        AppRoutes.appSettings: (_) => const AppSettingsScreen(),

      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.registerPinSetup) {
          final draft = settings.arguments as RegistrationDraft;
          return AppTheme.fadeSlideRoute(
            page: RegisterPinSetupScreen(draft: draft),
          );
        }
        // Classification list with type argument
        if (settings.name == AppRoutes.classificationList) {
          final type = settings.arguments as String? ?? 'All';
          return AppTheme.fadeSlideRoute(
            page: ClassificationListScreen(classificationType: type),
          );
        }
        return null;
      },

      // ── Initial route based on auth state ─────────────────────────────────
      // isRegistered → show PIN screen (lock screen),
      // else → show Login (fresh install)
      home: _buildHome(auth),
      builder: (context, child) {
        final settings = context.watch<SettingsProvider>();
        // User interaction ping for inactivity timer + global font scaler.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) =>
                context.read<AuthProvider>().onUserInteraction(),
            onPointerMove: (_) =>
                context.read<AuthProvider>().onUserInteraction(),
            onPointerSignal: (_) =>
                context.read<AuthProvider>().onUserInteraction(),
            child: _AppLockNavigator(
              navigatorKey: _navKey,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHome(AuthProvider auth) {
    // CRITICAL: Check if registered but locked FIRST
    // This ensures Login screen is shown in "unlock" mode for returning users
    if (auth.isRegistered && !auth.isSessionActive) {
      // Device recognised but locked → Login screen to unlock
      return const LoginScreen();
    }
    if (auth.isSessionActive && auth.isAccountActive) {
      return const DashboardScreen();
    }
    if (auth.isSessionActive && !auth.isAccountActive) {
      return const LoginScreen();
    }
    // Fresh install → full login/register flow
    return const LoginScreen();
  }
}

/// Widget that listens to auth state and navigates to PIN screen when locked.
/// Uses navigatorKey instead of context to avoid "context does not include a Navigator" error.
class _AppLockNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget? child;
  const _AppLockNavigator({
    required this.navigatorKey,
    this.child,
  });

  @override
  State<_AppLockNavigator> createState() => _AppLockNavigatorState();
}

class _AppLockNavigatorState extends State<_AppLockNavigator> {
  bool _wasLocked = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Handle navigation when app becomes locked
    if (!auth.isSessionActive && auth.isRegistered) {
      if (!_wasLocked) {
        _wasLocked = true;
        // Use navigatorKey instead of Navigator.of(context) to avoid context issues
        // Schedule navigation after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !auth.isSessionActive && auth.isRegistered) {
            final nav = widget.navigatorKey.currentState;
            if (nav != null) {
              nav.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            }
          }
        });
      }
    } else if (auth.isSessionActive) {
      _wasLocked = false;
    }

    return widget.child ?? const SizedBox.shrink();
  }
}
