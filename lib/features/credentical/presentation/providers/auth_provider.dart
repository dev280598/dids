import 'package:flutter/material.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../shared/services/biometric_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();
  
  bool _isAuthenticated = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    try {
      final status = await _biometricService.getBiometricStatus();
      _isBiometricAvailable = status == BiometricStatus.available;
      _isBiometricEnabled = _isBiometricAvailable && await _storageService.isBiometricEnabled();
    } catch (e) {
      _isBiometricAvailable = false;
      _isBiometricEnabled = false;
    }
    notifyListeners();
  }

  /// Check if biometric authentication is available on the device
  Future<bool> checkBiometricAvailability() async {
    try {
      print('Checking biometric status...');
      final status = await _biometricService.getBiometricStatus();
      print('Biometric status: $status');
      
      // Also check device support
      final isDeviceSupported = await _biometricService.isDeviceSupported();
      print('Device supports biometrics: $isDeviceSupported');
      
      // Get available biometric types
      final availableBiometrics = await _biometricService.getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');
      
      _isBiometricAvailable = status == BiometricStatus.available && isDeviceSupported;
      notifyListeners();
      return _isBiometricAvailable;
    } catch (e) {
      print('Error checking biometric availability: $e');
      _isBiometricAvailable = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    _setLoading(true);
    _clearError();

    try {
      final hasPin = await _storageService.hasPin();
      
      if (!hasPin) {
        // First time setup - save the PIN
        await _storageService.savePin(pin);
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        // Verify existing PIN
        final isValid = await _storageService.verifyPin(pin);
        if (isValid) {
          _isAuthenticated = true;
          _setLoading(false);
          return true;
        } else {
          _setError('Invalid PIN. Please try again.');
          _setLoading(false);
          return false;
        }
      }
    } catch (e) {
      _setError('Authentication failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> setupPin(String pin) async {
    _setLoading(true);
    _clearError();

    try {
      await _storageService.savePin(pin);
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to setup PIN. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) {
      print('Biometric auth skipped - Available: $_isBiometricAvailable, Enabled: $_isBiometricEnabled');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('Starting biometric authentication...');
      final result = await _biometricService.authenticate(
        localizedReason: 'Please authenticate to access your digital wallet',
      );
      print('Authentication result: $result');

      if (result.success) {
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Biometric authentication failed');
        print('Authentication failed: ${result.error} (${result.errorCode})');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Authentication error: $e');
      _setError('Biometric authentication error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> enableBiometric(bool enable) async {
    print('Attempting to ${enable ? 'enable' : 'disable'} biometrics');
    print('Current state - Available: $_isBiometricAvailable, Enabled: $_isBiometricEnabled');
    
    if (!_isBiometricAvailable) {
      print('Cannot enable biometrics - not available');
      return;
    }

    if (enable) {
      // Test biometric authentication before enabling
      print('Testing biometric authentication...');
      final result = await _biometricService.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
      );
      print('Test authentication result: $result');
      
      if (result.success) {
        await _storageService.setBiometricEnabled(true);
        _isBiometricEnabled = true;
        print('Biometrics enabled successfully');
      } else {
        _setError(result.error ?? 'Failed to enable biometric authentication');
        print('Failed to enable biometrics: ${result.error} (${result.errorCode})');
        return;
      }
    } else {
      await _storageService.setBiometricEnabled(false);
      _isBiometricEnabled = false;
      print('Biometrics disabled successfully');
    }
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _clearError();
    notifyListeners();
  }

  Future<void> resetApp() async {
    await _storageService.clearAllData();
    _isAuthenticated = false;
    _isBiometricEnabled = false;
    _clearError();
    notifyListeners();
  }

  Future<void> clearPinAndBiometric() async {
    _setLoading(true);
    _clearError();

    try {
      // Clear PIN
      await _storageService.deletePin();
      
      // Disable biometric
      await _storageService.setBiometricEnabled(false);
      
      // Reset authentication state
      _isAuthenticated = false;
      _isBiometricEnabled = false;
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to clear authentication data');
      _setLoading(false);
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 