import '../../domain/entities/qr_result.dart';
import '../../domain/repositories/qr_scanner_repository.dart';
import '../datasources/qr_scanner_datasource.dart';

class QRScannerRepositoryImpl implements QRScannerRepository {
  final QRScannerDataSource dataSource;

  QRScannerRepositoryImpl({required this.dataSource});

  @override
  Stream<QRResult> startScanning() {
    return dataSource.startScanning();
  }

  @override
  Future<void> stopScanning() async {
    await dataSource.stopScanning();
  }

  @override
  Future<QRResult> processQRData(String rawData) async {
    return await dataSource.processQRData(rawData);
  }

  @override
  Future<bool> checkCameraPermission() async {
    return await dataSource.checkCameraPermission();
  }

  @override
  Future<bool> requestCameraPermission() async {
    return await dataSource.requestCameraPermission();
  }

  @override
  Future<bool> isFlashAvailable() async {
    return await dataSource.isFlashAvailable();
  }

  @override
  Future<void> toggleFlash() async {
    await dataSource.toggleFlash();
  }
} 