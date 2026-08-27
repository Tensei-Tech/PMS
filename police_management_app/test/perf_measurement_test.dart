import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:khakhi_diary/l10n/app_localizations.dart';
import 'package:khakhi_diary/utils/perf_tracker.dart';
import 'package:khakhi_diary/main.dart';
import 'package:khakhi_diary/providers/auth_provider.dart';
import 'package:khakhi_diary/providers/theme_provider.dart';
import 'package:khakhi_diary/providers/settings_provider.dart';
import 'package:khakhi_diary/providers/news_provider.dart';
import 'package:khakhi_diary/providers/case_provider.dart';
import 'package:khakhi_diary/providers/notification_provider.dart';
import 'package:khakhi_diary/providers/module_registry.dart';
import 'package:khakhi_diary/screens/dashboard_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: '1:1:android:test',
          messagingSenderId: '1',
          projectId: 'test-project',
          storageBucket: 'test-project.appspot.com',
        ),
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('Full End-to-End Performance Lifecycle Benchmark', (WidgetTester tester) async {
    PerfTracker.reset('FULL_APP_PERF_BENCHMARK');
    PerfTracker.log('STAGE 1: App main() launch & Firebase Core Init');

    // 1. App Startup & Root MultiProvider construction
    PerfTracker.startOp('Stage 1.1: Root Widget Tree & 36 Module Providers Construction');
    late AuthProvider authProvider;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (ctx) {
            authProvider = AuthProvider();
            return authProvider;
          }),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => NewsProvider()),
          ChangeNotifierProvider(create: (_) => CaseProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ...moduleProviders,
        ],
        child: const PoliceMgmtApp(),
      ),
    );
    PerfTracker.stopOp('Stage 1.1: Root Widget Tree & 36 Module Providers Construction');
    
    PerfTracker.startOp('Stage 1.2: App Shell Settling & Login Screen First Frame');
    await tester.pumpAndSettle();
    PerfTracker.stopOp('Stage 1.2: App Shell Settling & Login Screen First Frame');

    // 2. Simulated Auth Login & Station Context Propagation
    PerfTracker.startOp('Stage 2: Auth Login & Profile Loading');
    PerfTracker.log('Simulating Auth state update with station="Pune City PS"');
    authProvider.switchStation('Pune City PS');
    PerfTracker.stopOp('Stage 2: Auth Login & Profile Loading');

    // 3. Station context propagation to 36 module providers
    PerfTracker.startOp('Stage 3: 36 Module Providers setStationContext execution');
    await tester.pump();
    PerfTracker.stopOp('Stage 3: 36 Module Providers setStationContext execution');

    // 4. DashboardScreen Route Push & Rendering
    PerfTracker.startOp('Stage 4: DashboardScreen Route Push & Render');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => authProvider),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => NewsProvider()),
          ChangeNotifierProvider(create: (_) => CaseProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ...moduleProviders,
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DashboardScreen(),
        ),
      ),
    );
    PerfTracker.stopOp('Stage 4: DashboardScreen Route Push & Render');

    // 5. Settlement & Data Stream Loading
    PerfTracker.startOp('Stage 5: Dashboard Data Streams & Final Settlement');
    await tester.pump(const Duration(milliseconds: 300));
    PerfTracker.stopOp('Stage 5: Dashboard Data Streams & Final Settlement');

    PerfTracker.log('STAGE 10: END-TO-END MEASUREMENT COMPLETE');
  });
}
