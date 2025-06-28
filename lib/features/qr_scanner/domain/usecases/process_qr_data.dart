import '../entities/qr_result.dart';
import '../repositories/qr_scanner_repository.dart';

class ProcessQRData {
  final QRScannerRepository repository;

  ProcessQRData(this.repository);

  /// Process QR data and return parsed result
  Future<QRResult> call(String rawData) async {
    return await repository.processQRData(rawData);
  }
} 