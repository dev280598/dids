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

  Future<bool> authenticateWithBiometric() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) {
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _biometricService.authenticate(
        localizedReason: 'Please authenticate to access your digital wallet',
      );

      if (result.success) {
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Biometric authentication failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Biometric authentication error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> enableBiometric(bool enable) async {
    if (!_isBiometricAvailable) return;

    if (enable) {
      // Test biometric authentication before enabling
      final result = await _biometricService.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
      );
      
      if (result.success) {
        await _storageService.setBiometricEnabled(true);
        _isBiometricEnabled = true;
      } else {
        _setError(result.error ?? 'Failed to enable biometric authentication');
        return;
      }
    } else {
      await _storageService.setBiometricEnabled(false);
      _isBiometricEnabled = false;
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