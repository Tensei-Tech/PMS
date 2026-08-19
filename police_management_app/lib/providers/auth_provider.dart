import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../utils/app_constants.dart';
import '../utils/pin_crypto.dart';
import '../services/firestore_service.dart';
import '../services/lockout_service.dart';
import '../services/audit_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../models/account_access.dart';
import '../utils/station_address_parser.dart';
import 'package:image_picker/image_picker.dart';

void _secureLog(String message) {
  if (kDebugMode) debugPrint('[AuthProvider] $message');
}

class RegistrationResult {
  final bool success;
  final String? errorCode;
  final String? errorMessage;
  final String? userId;

  const RegistrationResult._({
    required this.success,
    this.errorCode,
    this.errorMessage,
    this.userId,
  });

  factory RegistrationResult.success(String userId) =>
      RegistrationResult._(success: true, userId: userId);

  factory RegistrationResult.failure(String code, String message) =>
      RegistrationResult._(success: false, errorCode: code, errorMessage: message);

  factory RegistrationResult.networkError() => RegistrationResult._(
        success: false,
        errorCode: 'network-request-failed',
        errorMessage: 'Network connection failed. Please check your internet connection.',
      );

  factory RegistrationResult.emailInUse() => RegistrationResult._(
        success: false,
        errorCode: 'email-already-in-use',
        errorMessage: 'This Government ID is already registered. Please login instead.',
      );

  factory RegistrationResult.weakPassword() => RegistrationResult._(
        success: false,
        errorCode: 'weak-password',
        errorMessage: 'PIN does not meet security requirements. Please try again.',
      );

  factory RegistrationResult.invalidEmail() => RegistrationResult._(
        success: false,
        errorCode: 'invalid-email',
        errorMessage: 'Invalid email format. Please enter a valid Government Email.',
      );

  factory RegistrationResult.unknownError(String message) => RegistrationResult._(
        success: false,
        errorCode: 'unknown',
        errorMessage: 'Registration failed: $message',
      );

  factory RegistrationResult.firestoreError(String authUid, {String? message}) =>
      RegistrationResult._(
        success: false,
        errorCode: 'firestore-error',
        errorMessage: message ??
            'Could not save your profile to the database. Please try again or contact support.',
        userId: authUid,
      );
}

class AuthProvider extends ChangeNotifier {
  fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  final LockoutService _lockout = LockoutService();
  final AuditService _audit = AuditService();
  static const _secure = FlutterSecureStorage();

  bool _isSessionActive = false;
  bool _isRegistered = false;

  String _username = '';
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _designation = '';
  String _badgeNumber = '';
  String _stationName = '';
  String? _overrideStationName;
  String _stationAddress = '';
  String _stationLandline = '';
  String _govtId = '';
  String _profilePhoto = '';
  String _role = 'officer';
  List<String> _additionalStations = [];
  String? _district;
  String? _zone;
  String _accountStatus = UserAccountStatus.active;
  String _status = '';
  bool _stationCaseViewGranted = false;
  StreamSubscription<UserModel?>? _profileSub;
  String get uid => _auth.currentUser?.uid ?? '';

  bool get isSessionActive => _isSessionActive;
  bool get isRegistered => _isRegistered;
  bool get isLoggedIn => _isSessionActive;
  String get username => _username;
  String get fullName => _fullName;
  String get email => _email;
  String get phone => _phone;
  String get contactNumber => _phone;
  String get designation => _designation;
  String get badgeNumber => _badgeNumber;
  String get sevaNumber => _badgeNumber.isNotEmpty ? _badgeNumber : _govtId;
  String get stationName => _overrideStationName ?? _stationName;
  /// Active station for queries and new records (may differ from [homeStationName] when switched).
  String get activeStation => stationName;
  String get homeStationName => _stationName;
  String get stationAddress => _stationAddress;
  String get stationLandline => _stationLandline;
  String get govtId => _govtId;
  String get profilePhoto => _profilePhoto;
  String get role => _role;
  List<String> get additionalStations => List.unmodifiable(_additionalStations);
  String get district => _district ?? '';
  String get zone => _zone ?? _district ?? '';
  String get accountStatus => _accountStatus;
  String get status => _status;
  bool get stationCaseViewGranted => _stationCaseViewGranted;
  bool get isAccountActive =>
      _accountStatus == UserAccountStatus.active &&
      _status.trim().toLowerCase() != 'inactive';
  bool get isAccountPendingApproval =>
      _accountStatus == UserAccountStatus.pendingApproval;

  bool get isAdmin => _role == 'admin';
  bool get isSupervisor => _role == 'supervisor' || _role == 'admin';
  bool get isViewingOtherStation =>
      _overrideStationName != null && _overrideStationName != _stationName;

  /// Switch the active station (for senior officers viewing another station).
  void switchStation(String stationName) {
    if (stationName == _stationName) {
      _overrideStationName = null;
    } else {
      _overrideStationName = stationName;
    }
    notifyListeners();
  }

  /// Reset to the officer's home station.
  void resetToHomeStation() {
    _overrideStationName = null;
    notifyListeners();
  }

  /// Add a station to the officer's additional locations list.
  /// Persists to Firestore immediately.
  Future<void> addStation(String stationName) async {
    final trimmed = stationName.trim();
    if (trimmed.isEmpty) return;
    if (_additionalStations.contains(trimmed)) return; // Already added
    if (trimmed == _stationName) return; // Already home station
    _additionalStations.add(trimmed);
    notifyListeners();
    // Persist to Firestore
    try {
      await _firestore.updateUserField(uid, 'additionalStations', _additionalStations);
    } catch (e) {
      _secureLog('addStation: Firestore persist failed');
    }
  }

  /// Remove a station/location from the officer's additional locations list.
  /// Persists to Firestore immediately.
  Future<void> removeStation(String stationName) async {
    final trimmed = stationName.trim();
    if (trimmed.isEmpty) return;
    if (trimmed == _stationName) return; // Never remove home station
    if (!_additionalStations.contains(trimmed)) return;
    _additionalStations.remove(trimmed);
    notifyListeners();
    // Persist to Firestore
    try {
      await _firestore.updateUserField(uid, 'additionalStations', _additionalStations);
    } catch (e) {
      _secureLog('removeStation: Firestore persist failed');
    }
  }

  String get displayName {
    if (_fullName.isNotEmpty) return _fullName;
    if (_username.isNotEmpty) {
      return _username[0].toUpperCase() + _username.substring(1);
    }
    return 'Officer';
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    Future.microtask(() {
      _auth.authStateChanges().listen((fb.User? user) async {
        try {
          await _profileSub?.cancel();
          _profileSub = null;

          if (user != null) {
            _profileSub = _firestore.watchUser(user.uid).listen(
              (profile) async {
                try {
                  if (profile == null) return;

                  if (_isSessionActive &&
                      AccountAccess.shouldForceLogout(profile)) {
                    await _forceLogoutBlockedAccount(profile);
                    return;
                  }

                  await _applyProfileAndBackfill(profile);
                  _isRegistered = true;
                  notifyListeners();
                } catch (e, s) {
                  _secureLog('Error in profile stream: $e\n$s');
                }
              },
              onError: (e, s) {
                _secureLog('Profile stream error: $e\n$s');
              },
            );
          } else {
            _isSessionActive = false;
            final storedEmail =
                (await _secure.read(key: StorageKeys.email) ?? '').trim();
            _isRegistered = storedEmail.isNotEmpty;
            notifyListeners();
          }
        } catch (e, s) {
          _secureLog('Error in authStateChanges listener: $e\n$s');
        }
      });
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }

  void _applyProfile(UserModel profile) {
    _username = profile.name;
    _fullName = profile.name;
    _email = profile.email;
    _phone = profile.phone;
    _designation = profile.designation;
    _badgeNumber = profile.badgeNumber;
    _stationName = profile.stationName;
    _overrideStationName = null;
    _stationAddress = profile.stationAddress;
    _stationLandline = profile.stationLandline;
    _govtId = profile.govtId;
    _profilePhoto = profile.photoUrl;
    _role = profile.email.toLowerCase().startsWith('admin') ? 'admin' : profile.role;
    _additionalStations = List<String>.from(profile.additionalStations);
    _district = profile.district;
    _zone = profile.effectiveZone.isNotEmpty ? profile.effectiveZone : null;
    _accountStatus = profile.accountStatus;
    _status = profile.status;
    _stationCaseViewGranted = profile.stationCaseViewGranted;
  }

  void _clearProfileState() {
    _username = '';
    _fullName = '';
    _phone = '';
    _designation = '';
    _stationName = '';
    _overrideStationName = null;
    _stationAddress = '';
    _stationLandline = '';
    _govtId = '';
    _profilePhoto = '';
    _role = 'officer';
    _badgeNumber = '';
    _additionalStations = [];
    _district = null;
    _zone = null;
    _accountStatus = UserAccountStatus.active;
    _status = '';
    _stationCaseViewGranted = false;
  }

  Future<void> _forceLogoutBlockedAccount([UserModel? profile]) async {
    if (profile != null) {
      _accountStatus = profile.accountStatus;
      _status = profile.status;
    }

    await _auth.signOut();
    _clearProfileState();
    _isSessionActive = false;
    _isRegistered = true;

    await _audit.log(
      AuditEvent.sessionLocked,
      uid: profile?.uid ?? _auth.currentUser?.uid,
    );
    notifyListeners();
  }

  Future<String?> _completeLoginAfterAuth(UserModel profile) async {
    final access = AccountAccess.evaluate(profile);
    if (!access.allowed) {
      await _auth.signOut();
      return access.blockMessage;
    }

    await _applyProfileAndBackfill(profile);
    _isRegistered = true;
    _isSessionActive = true;
    notifyListeners();
    await _audit.log(AuditEvent.loginSuccess, uid: profile.uid);
    return null;
  }

  Future<void> _applyProfileAndBackfill(UserModel profile) async {
    _applyProfile(profile);
    await _backfillDistrictIfNeeded(profile);
    try {
      final userUid = profile.uid.isNotEmpty ? profile.uid : uid;
      if (userUid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userUid).update({
          'lastActiveAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  /// One-time district backfill from stationAddress for legacy profiles.
  Future<void> _backfillDistrictIfNeeded(UserModel profile) async {
    final existing = profile.district?.trim() ?? '';
    if (existing.isNotEmpty) {
      _district = existing;
      return;
    }
    final parsed = StationAddressParser.parse(profile.stationAddress);
    if (!parsed.hasDistrict) return;
    try {
      await _firestore.updateUserField(uid, 'district', parsed.district);
      _district = parsed.district;
    } catch (e) {
      _secureLog('district backfill failed (non-blocking)');
    }
  }

  /// Checks if an account with the given email or phone number already exists in Firestore.
  Future<bool> checkContactExists({
    required String email,
    required String phone,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedPhone = phone.replaceAll(RegExp(r'\D'), '');

    try {
      final futures = <Future<QuerySnapshot>>[
        FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: sanitizedEmail)
            .limit(1)
            .get(),
      ];

      if (sanitizedPhone.isNotEmpty) {
        futures.add(
          FirebaseFirestore.instance
              .collection('users')
              .where('phone', isEqualTo: sanitizedPhone)
              .limit(1)
              .get(),
        );
      }

      final results = await Future.wait(futures);
      for (final snap in results) {
        if (snap.docs.isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      _secureLog('checkContactExists error: $e');
      rethrow;
    }
  }

  Future<RegistrationResult> registerWithPin({
    required String fullName,
    required String designation,
    required String email,
    required String phone,
    required String pin,
    XFile? idCardFile,
    XFile? selfieFile,
    String stationName = '',
    String stationAddress = '',
    String stationLandline = '',
    String govtId = '',
    String? district,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedPhone = phone.trim();
    final sanitizedPin = pin.trim();

    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
    if (!emailRegex.hasMatch(sanitizedEmail)) {
      return RegistrationResult.invalidEmail();
    }

    fb.UserCredential? creds;

    try {
      creds = await _auth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: sanitizedPin,
      );

      if (creds.user == null) {
        return RegistrationResult.unknownError('Firebase user creation failed');
      }

      final authUid = creds.user!.uid;

      String idCardUrl = '';
      String selfieUrl = '';
      try {
        if (idCardFile != null) {
          idCardUrl = await _storage.uploadUserRegistrationImage(
            uid: authUid,
            fileName: 'id_card.jpg',
            file: idCardFile,
          );
        }
        if (selfieFile != null) {
          selfieUrl = await _storage.uploadUserRegistrationImage(
            uid: authUid,
            fileName: 'selfie.jpg',
            file: selfieFile,
          );
        }
      } catch (uploadError) {
        _secureLog('registerWithPin: identity upload failed');
        try {
          await creds.user!.delete();
        } catch (_) {}
        return RegistrationResult.unknownError(
          'Could not upload identity photos. Please try again.',
        );
      }

      final salt = PinCrypto.generateSalt();
      final pinHash = await PinCrypto.hashPinAsync(sanitizedPin, salt);

      final resolvedGovtId =
          govtId.trim().isNotEmpty ? govtId.trim() : sanitizedEmail;

      final newUser = UserModel(
        uid: authUid,
        name: fullName.trim(),
        badgeNumber: '',
        designation: designation.trim(),
        email: sanitizedEmail,
        phone: sanitizedPhone,
        stationName: stationName.trim(),
        stationAddress: stationAddress.trim(),
        stationLandline: stationLandline.trim(),
        govtId: resolvedGovtId,
        photoUrl: selfieUrl,
        idCardUrl: idCardUrl.isNotEmpty ? idCardUrl : null,
        district: district?.trim(),
        zone: (district?.trim().isNotEmpty == true) ? district!.trim() : null,
        additionalStations: const [],
        role: 'officer',
        accountStatus: UserAccountStatus.pendingApproval,
      );

      try {
        await _firestore.saveUser(newUser);
        final savedProfile = await _firestore.getUser(authUid);
        if (savedProfile == null) {
          _secureLog('registerWithPin: Firestore verify failed — doc missing');
          try {
            await creds.user!.delete();
          } catch (_) {}
          await _audit.log(AuditEvent.registrationFailed, uid: authUid);
          return RegistrationResult.firestoreError(
            authUid,
            message: 'Profile save could not be verified. Please try again.',
          );
        }
        if (savedProfile.accountStatus != UserAccountStatus.pendingApproval) {
          _secureLog(
            'registerWithPin: unexpected accountStatus=${savedProfile.accountStatus}',
          );
        }
      } on FirebaseException catch (e) {
        _secureLog(
          'registerWithPin: Firestore save failed (${e.code}): ${e.message}',
        );
        try {
          await creds.user!.delete();
        } catch (_) {}
        await _audit.log(AuditEvent.registrationFailed, uid: authUid);
        return RegistrationResult.firestoreError(
          authUid,
          message: _registrationFirestoreMessage(e),
        );
      } catch (firestoreError) {
        _secureLog('registerWithPin: Firestore save failed: $firestoreError');
        try {
          await creds.user!.delete();
        } catch (_) {}
        await _audit.log(AuditEvent.registrationFailed, uid: authUid);
        return RegistrationResult.firestoreError(authUid);
      }

      try {
        await _secure.write(key: StorageKeys.email, value: sanitizedEmail);
        await _secure.write(key: StorageKeys.pinHash, value: pinHash);
        await _secure.write(key: StorageKeys.pinSalt, value: salt);
      } catch (secureError) {
        _secureLog('registerWithPin: secure storage failed: $secureError');
        return RegistrationResult.failure(
          'secure-storage-error',
          'Account created but device login setup failed. Try logging in with your email and PIN.',
        );
      }

      _isRegistered = true;
      _isSessionActive = false;

      _applyProfile(newUser);

      notifyListeners();

      await _audit.log(AuditEvent.registrationSuccess, uid: authUid);
      return RegistrationResult.success(authUid);

    } on fb.FirebaseAuthException catch (e) {
      _secureLog('registerWithPin FirebaseAuthException: ${e.code}');
      switch (e.code) {
        case 'email-already-in-use': return RegistrationResult.emailInUse();
        case 'weak-password': return RegistrationResult.weakPassword();
        case 'invalid-email': return RegistrationResult.invalidEmail();
        case 'network-request-failed': return RegistrationResult.networkError();
        default: return RegistrationResult.unknownError(e.message ?? e.code);
      }
    } on FirebaseException catch (e) {
      _secureLog('registerWithPin FirebaseException: ${e.code} ${e.message}');
      if (creds?.user != null) {
        try {
          await creds!.user!.delete();
        } catch (_) {}
      }
      return RegistrationResult.failure(
        e.code,
        e.message ?? 'Registration failed due to a Firebase error.',
      );
    } catch (e, st) {
      _secureLog('registerWithPin unexpected error: $e\n$st');
      if (creds?.user != null) {
        try {
          await creds!.user!.delete();
        } catch (_) {}
      }
      return RegistrationResult.unknownError('$e');
    }
  }

  String _registrationFirestoreMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied while saving your profile. Deploy updated Firestore rules and try again.';
      case 'unavailable':
        return 'Firestore is temporarily unavailable. Check your connection and try again.';
      default:
        return e.message ??
            'Could not save your profile (${e.code}). Please try again.';
    }
  }

  Future<String?> loginWithPin({
    required String email,
    required String pin,
  }) async {
    final lockoutStatus = await _lockout.checkStatus();
    if (lockoutStatus.isLocked) {
      return 'Account locked. Try again in ${lockoutStatus.remainingLabel}.';
    }

    try {
      final sanitizedEmail = email.trim().toLowerCase();
      final res = await _auth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: pin.trim(),
      );

      if (res.user == null) {
        return 'Login failed. Please try again.';
      }

      final profile = await _firestore.getUser(res.user!.uid);
      if (profile == null) {
        await _auth.signOut();
        return 'User profile not found in database.';
      }

      final access = AccountAccess.evaluate(profile);
      if (!access.allowed) {
        await _auth.signOut();
        return access.blockMessage;
      }

      final salt = PinCrypto.generateSalt();
      final pinHash = await PinCrypto.hashPinAsync(pin.trim(), salt);
      await _secure.write(key: StorageKeys.email, value: sanitizedEmail);
      await _secure.write(key: StorageKeys.pinHash, value: pinHash);
      await _secure.write(key: StorageKeys.pinSalt, value: salt);

      await _lockout.recordSuccess();
      await _applyProfileAndBackfill(profile);
      _isRegistered = true;
      _isSessionActive = true;
      notifyListeners();

      await _audit.log(AuditEvent.loginSuccess, uid: res.user!.uid);
      return null;
    } catch (e) {
      _secureLog('loginWithPin: authentication failed');
      final status = await _lockout.recordFailedAttempt();
      await _audit.log(AuditEvent.loginFailed);
      if (status.isLocked) {
        await _audit.log(AuditEvent.lockoutTriggered);
        return 'Too many failed attempts. Try again in ${status.remainingLabel}.';
      }
      return 'Invalid PIN. Please try again.';
    }
  }

  Future<String?> loginWithBiometrics(String email) async {
    final lockoutStatus = await _lockout.checkStatus();
    if (lockoutStatus.isLocked) {
      return 'Account locked. Try again in ${lockoutStatus.remainingLabel}.';
    }

    final user = _auth.currentUser;
    if (user == null ||
        user.email?.toLowerCase() != email.trim().toLowerCase()) {
      return 'Login failed. Please use PIN.';
    }

    final profile = await _firestore.getUser(user.uid);
    if (profile == null) {
      await _auth.signOut();
      return 'User profile not found in database.';
    }

    return _completeLoginAfterAuth(profile);
  }

  Future<String?> loginByEmailAndPin({
    required String email,
    required String pin,
  }) async {
    final lockoutStatus = await _lockout.checkStatus();
    if (lockoutStatus.isLocked) {
      return 'Account locked. Try again in ${lockoutStatus.remainingLabel}.';
    }

    try {
      final sanitizedEmail = email.trim().toLowerCase();
      final sanitizedPin = pin.trim();

      await _auth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: sanitizedPin,
      );

      final user = await _firestore.getUser(_auth.currentUser!.uid);
      if (user == null) {
        await _auth.signOut();
        return 'User profile not found in database.';
      }

      final access = AccountAccess.evaluate(user);
      if (!access.allowed) {
        await _auth.signOut();
        return access.blockMessage;
      }

      final salt = PinCrypto.generateSalt();
      final pinHash = await PinCrypto.hashPinAsync(sanitizedPin, salt);
      await _secure.write(key: StorageKeys.email, value: sanitizedEmail);
      await _secure.write(key: StorageKeys.pinHash, value: pinHash);
      await _secure.write(key: StorageKeys.pinSalt, value: salt);

      await _lockout.recordSuccess();

      _isRegistered = true;
      _isSessionActive = true;
      await _applyProfileAndBackfill(user);

      notifyListeners();

      await _audit.log(AuditEvent.loginSuccess, uid: _auth.currentUser!.uid);
      return null;

    } on fb.FirebaseAuthException catch (e) {
      _secureLog('loginByEmailAndPin: ${e.code}');
      final status = await _lockout.recordFailedAttempt();
      await _audit.log(AuditEvent.loginFailed);
      if (status.isLocked) {
        await _audit.log(AuditEvent.lockoutTriggered);
        return 'Too many failed attempts. Try again in ${status.remainingLabel}.';
      }
      switch (e.code) {
        case 'user-not-found': return 'Account not found for this email.';
        case 'wrong-password':
        case 'invalid-credential': return 'Incorrect PIN. Please try again.';
        case 'invalid-email': return 'Invalid email format.';
        case 'user-disabled': return 'This account has been disabled.';
        case 'network-request-failed': return 'Network error. Please check your connection.';
        case 'too-many-requests': return 'Too many attempts. Please try again later.';
        default: return 'Login failed. Please try again.';
      }
    } catch (e) {
      _secureLog('loginByEmailAndPin: unexpected error');
      return 'Unexpected error. Please try again.';
    }
  }

  Future<String> getStoredGovtEmail() async {
    return (await _secure.read(key: StorageKeys.email) ?? '').trim();
  }

  Future<bool> verifyPin(String pin) async {
    final lockoutStatus = await _lockout.checkStatus();
    if (lockoutStatus.isLocked) return false;

    final storedHash = (await _secure.read(key: StorageKeys.pinHash) ?? '').trim();
    final storedSalt = (await _secure.read(key: StorageKeys.pinSalt) ?? '').trim();

    if (storedHash.isEmpty || storedSalt.isEmpty) {
      _secureLog('verifyPin: no stored hash/salt found');
      return false;
    }

    // Try first with optimized 1,000 iterations
    var isValid = await PinCrypto.verifyPinAsync(pin.trim(), storedHash, storedSalt, 1000);

    // Fallback to old 100,000 iterations to migrate legacy stored hashes seamlessly
    if (!isValid) {
      isValid = await PinCrypto.verifyPinAsync(pin.trim(), storedHash, storedSalt, 100000);
      if (isValid) {
        final newSalt = PinCrypto.generateSalt();
        final newHash = await PinCrypto.hashPinAsync(pin.trim(), newSalt);
        await _secure.write(key: StorageKeys.pinHash, value: newHash);
        await _secure.write(key: StorageKeys.pinSalt, value: newSalt);
        _secureLog('verifyPin: migrated hash from 100,000 to 1,000 iterations successfully');
      }
    }

    if (isValid) {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final profile = await _firestore.getUser(uid);
        if (profile != null) {
          if (AccountAccess.shouldForceLogout(profile)) {
            await _forceLogoutBlockedAccount(profile);
            return false;
          }
          await _applyProfileAndBackfill(profile);
        }
      }

      await _lockout.recordSuccess();
      _isSessionActive = true;
      notifyListeners();
      await _audit.log(AuditEvent.pinVerifySuccess, uid: _auth.currentUser?.uid);
      return true;
    } else {
      final status = await _lockout.recordFailedAttempt();
      await _audit.log(AuditEvent.pinVerifyFailed, uid: _auth.currentUser?.uid);
      if (status.isLocked) {
        await _audit.log(AuditEvent.lockoutTriggered, uid: _auth.currentUser?.uid);
      }
      return false;
    }
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    final storedHash = await _secure.read(key: StorageKeys.pinHash) ?? '';
    final storedSalt = await _secure.read(key: StorageKeys.pinSalt) ?? '';

    var isOldPinValid = await PinCrypto.verifyPinAsync(
      oldPin.trim(), storedHash, storedSalt, 1000,
    );
    if (!isOldPinValid) {
      isOldPinValid = await PinCrypto.verifyPinAsync(
        oldPin.trim(), storedHash, storedSalt, 100000,
      );
    }
    if (!isOldPinValid) {
      await _audit.log(AuditEvent.pinChangeFailed, uid: _auth.currentUser?.uid);
      return false;
    }

    final newSalt = PinCrypto.generateSalt();
    final newHash = await PinCrypto.hashPinAsync(newPin.trim(), newSalt);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPin.trim());
      }
      await _secure.write(key: StorageKeys.pinHash, value: newHash);
      await _secure.write(key: StorageKeys.pinSalt, value: newSalt);

      await _audit.log(AuditEvent.pinChanged, uid: _auth.currentUser?.uid);
      return true;
    } catch (e) {
      _secureLog('changePin: error updating password');
      await _audit.log(AuditEvent.pinChangeFailed, uid: _auth.currentUser?.uid);
      return false;
    }
  }

  Future<void> resetPin(String newPin) async {
    final newSalt = PinCrypto.generateSalt();
    final newHash = await PinCrypto.hashPinAsync(newPin.trim(), newSalt);
    await _secure.write(key: StorageKeys.pinHash, value: newHash);
    await _secure.write(key: StorageKeys.pinSalt, value: newSalt);
    await _secure.delete(key: StorageKeys.pin);
    await _audit.log(AuditEvent.pinChanged, uid: _auth.currentUser?.uid);
  }

  void setSessionActive() {
    _isSessionActive = true;
    notifyListeners();
  }

  Future<void> signOutToLogin() async {
    await _auth.signOut();
    _isSessionActive = false;
    _isRegistered = true;
    notifyListeners();
  }

  void lockApp() {
    _isSessionActive = false;
    notifyListeners();
    _audit.log(AuditEvent.sessionLocked, uid: _auth.currentUser?.uid);
  }

  Future<void> fullLogout() async {
    final savedEmail = await _secure.read(key: StorageKeys.email);
    final savedHash = await _secure.read(key: StorageKeys.pinHash);
    final savedSalt = await _secure.read(key: StorageKeys.pinSalt);

    await _auth.signOut();
    await _secure.deleteAll();

    if (savedEmail != null) await _secure.write(key: StorageKeys.email, value: savedEmail);
    if (savedHash != null)  await _secure.write(key: StorageKeys.pinHash, value: savedHash);
    if (savedSalt != null)  await _secure.write(key: StorageKeys.pinSalt, value: savedSalt);

    await _lockout.resetAll();

    _isSessionActive = false;
    _isRegistered = true;
    _username = '';
    _fullName = '';
    _phone = '';
    _designation = '';
    _stationName = '';
    _overrideStationName = null;
    _stationAddress = '';
    _stationLandline = '';
    _govtId = '';
    _profilePhoto = '';
    _role = 'officer';
    _badgeNumber = '';
    _additionalStations = [];
    _district = null;
    _zone = null;
    _accountStatus = UserAccountStatus.active;
    _status = '';
    _stationCaseViewGranted = false;

    await _profileSub?.cancel();
    _profileSub = null;

    notifyListeners();
    await _audit.log(AuditEvent.fullLogout);
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? designation,
    String? stationName,
    String? stationAddress,
    String? stationLandline,
    String? profilePhoto,
  }) async {
    if (fullName != null)        _fullName = fullName;
    if (phone != null)           _phone = phone;
    if (designation != null)     _designation = designation;
    if (stationName != null)     _stationName = stationName;
    if (stationAddress != null)  _stationAddress = stationAddress;
    if (stationLandline != null) _stationLandline = stationLandline;
    if (profilePhoto != null)    _profilePhoto = profilePhoto;

    // Persist to Firestore
    final user = UserModel(
      uid: uid,
      name: _fullName,
      badgeNumber: _badgeNumber,
      designation: _designation,
      email: _email,
      phone: _phone,
      stationName: _stationName,
      stationAddress: _stationAddress,
      stationLandline: _stationLandline,
      govtId: _govtId,
      photoUrl: _profilePhoto,
      idCardUrl: null,
      role: _role,
      additionalStations: _additionalStations,
      district: _district,
      accountStatus: _accountStatus,
    );
    await _firestore.saveUser(user);

    notifyListeners();
  }

  Future<void> refreshProfileFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final profile = await _firestore.getUser(user.uid);
      if (profile == null) return;

      if (_isSessionActive && AccountAccess.shouldForceLogout(profile)) {
        await _forceLogoutBlockedAccount(profile);
        return;
      }

      await _applyProfileAndBackfill(profile);
      notifyListeners();
    } catch (e) {
      _secureLog('refreshProfileFromFirestore failed');
    }
  }

  Future<bool> login(String email, String password) async {
    final result = await loginWithPin(email: email, pin: password);
    return result == null;
  }

  Future<LockoutStatus> getLockoutStatus() => _lockout.checkStatus();

  Future<void> logout() async => lockApp();

  Future<bool> changePassword(String oldPin, String newPin) async {
    return changePin(oldPin, newPin);
  }

  void onUserInteraction() {
    // Used by main.dart for inactivity timer.
  }
}