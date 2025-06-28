import '../storage/storage_service.dart';

class ClearAuthUtils {
  static final StorageService _storageService = StorageService();

  /// Clear PIN and biometric settings
  static Future<void> clearPinAndBiometric() async {
    try {
      // Clear PIN
      await _storageService.deletePin();
      
      // Disable biometric
      await _storageService.setBiometricEnabled(false);
      
      print('✅ PIN and biometric authentication cleared successfully!');
    } catch (e) {
      print('❌ Failed to clear authentication: $e');
      rethrow;
    }
  }

  /// Check if PIN exists
  static Future<bool> hasPinSetup() async {
    return await _storageService.hasPin();
  }

  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    return await _storageService.isBiometricEnabled();
  }

  /// Print current authentication status
  static Future<void> printAuthStatus() async {
    final hasPin = await hasPinSetup();
    final biometricEnabled = await isBiometricEnabled();
    
    print('📱 Authentication Status:');
    print('   PIN Setup: ${hasPin ? "✅ Yes" : "❌ No"}');
    print('   Biometric: ${biometricEnabled ? "✅ Enabled" : "❌ Disabled"}');
  }
} 