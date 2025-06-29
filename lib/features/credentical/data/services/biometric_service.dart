import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

enum BiometricStatus {
  unknown,
  available,
  notAvailable,
  notEnrolled,
}

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  Future<BiometricStatus> getBiometricStatus() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return BiometricStatus.notAvailable;
      }

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricStatus.notEnrolled;
      }

      return BiometricStatus.available;
    } catch (e) {
      return BiometricStatus.unknown;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics;
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
    bool biometricOnly = true,
    bool stickyAuth = true,
  }) async {
    try {
      final BiometricStatus status = await getBiometricStatus();
      
      if (status != BiometricStatus.available) {
        return BiometricAuthResult(
          success: false,
          error: _getErrorMessage(status),
          errorCode: status.toString(),
        );
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
        ),
      );

      return BiometricAuthResult(
        success: didAuthenticate,
        error: didAuthenticate ? null : 'Authentication failed',
      );
    } on PlatformException catch (e) {
      String errorMessage = 'Authentication error';
      String? errorCode = e.code;

      switch (e.code) {
        case auth_error.notAvailable:
          errorMessage = 'Biometric authentication is not available';
          break;
        case auth_error.notEnrolled:
          errorMessage = 'No biometrics enrolled on this device';
          break;
        case auth_error.lockedOut:
          errorMessage = 'Biometric authentication is locked out';
          break;
        case auth_error.permanentlyLockedOut:
          errorMessage = 'Biometric authentication is permanently locked out';
          break;
        case auth_error.biometricOnlyNotSupported:
          errorMessage = 'Biometric-only authentication is not supported';
          break;
        default:
          errorMessage = e.message ?? 'Unknown biometric error';
      }

      return BiometricAuthResult(
        success: false,
        error: errorMessage,
        errorCode: errorCode,
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: 'Unexpected error occurred',
        errorCode: 'unknown',
      );
    }
  }

  /// Stop authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Handle error if needed
    }
  }

  /// Check if device supports biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  String _getErrorMessage(BiometricStatus status) {
    switch (status) {
      case BiometricStatus.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricStatus.notEnrolled:
        return 'No biometrics are enrolled on this device';
      case BiometricStatus.unknown:
        return 'Unable to determine biometric status';
      case BiometricStatus.available:
        return '';
    }
  }
}

class BiometricAuthResult {
  final bool success;
  final String? error;
  final String? errorCode;

  BiometricAuthResult({
    required this.success,
    this.error,
    this.errorCode,
  });

  @override
  String toString() {
    return 'BiometricAuthResult(success: $success, error: $error, errorCode: $errorCode)';
  }
} 