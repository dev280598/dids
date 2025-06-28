import '../entities/qr_result.dart';
import '../repositories/qr_scanner_repository.dart';

class ScanQRCode {
  final QRScannerRepository repository;

  ScanQRCode(this.repository);

  /// Start scanning QR codes
  Stream<QRResult> call() {
    return repository.startScanning();
  }

  /// Stop scanning
  Future<void> stop() async {
    await repository.stopScanning();
  }

  /// Check camera permission
  Future<bool> checkPermission() async {
    return await repository.checkCameraPermission();
  }

  /// Request camera permission
  Future<bool> requestPermission() async {
    return await repository.requestCameraPermission();
  }

  /// Toggle flash
  Future<void> toggleFlash() async {
    await repository.toggleFlash();
  }

  /// Check if flash is available
  Future<bool> isFlashAvailable() async {
    return await repository.isFlashAvailable();
  }
} 