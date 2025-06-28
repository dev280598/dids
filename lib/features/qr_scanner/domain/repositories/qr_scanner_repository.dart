import '../entities/qr_result.dart';

abstract class QRScannerRepository {
  /// Start QR code scanning
  Stream<QRResult> startScanning();
  
  /// Stop QR code scanning
  Future<void> stopScanning();
  
  /// Process QR data and return parsed result
  Future<QRResult> processQRData(String rawData);
  
  /// Check camera permission
  Future<bool> checkCameraPermission();
  
  /// Request camera permission
  Future<bool> requestCameraPermission();
  
  /// Check if flash is available
  Future<bool> isFlashAvailable();
  
  /// Toggle flash
  Future<void> toggleFlash();
} 