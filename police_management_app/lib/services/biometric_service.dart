import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device has biometric hardware and supports it.
  Future<bool> isHardwareSupported() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Checks if biometrics are both supported AND enrolled.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool supported = await isHardwareSupported();
      final bool enrolled = await hasEnrolledBiometrics();
      return supported && enrolled;
    } catch (e) {
      return false;
    }
  }

  /// Returns the type of biometrics available on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return <BiometricType>[];
    }
  }

  /// Checks if there are any enrolled biometrics.
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Performs biometric authentication.
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
