import 'dart:async';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/qr_result_model.dart';
import '../../domain/entities/qr_result.dart';

abstract class QRScannerDataSource {
  Stream<QRResult> startScanning();
  Future<void> stopScanning();
  Future<QRResult> processQRData(String rawData);
  Future<bool> checkCameraPermission();
  Future<bool> requestCameraPermission();
  Future<bool> isFlashAvailable();
  Future<void> toggleFlash();
}

class QRScannerDataSourceImpl implements QRScannerDataSource {
  MobileScannerController? _controller;
  StreamController<QRResult>? _scanStreamController;

  @override
  Stream<QRResult> startScanning() {
    _scanStreamController?.close();
    _scanStreamController = StreamController<QRResult>.broadcast();

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _controller!.barcodes.listen((BarcodeCapture barcodeCapture) {
      final List<Barcode> barcodes = barcodeCapture.barcodes;
      for (final Barcode barcode in barcodes) {
        if (barcode.rawValue != null) {
          final qrResult = _parseQRData(barcode.rawValue!);
          _scanStreamController?.add(qrResult);
        }
      }
    });

    return _scanStreamController!.stream;
  }

  @override
  Future<void> stopScanning() async {
     _controller?.dispose();
    _controller = null;
    await _scanStreamController?.close();
    _scanStreamController = null;
  }

  @override
  Future<QRResult> processQRData(String rawData) async {
    return _parseQRData(rawData);
  }

  @override
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  @override
  Future<bool> isFlashAvailable() async {
    return _controller?.torchEnabled ?? false;
  }

  @override
  Future<void> toggleFlash() async {
    await _controller?.toggleTorch();
  }

  /// Parse QR data and determine type
  QRResult _parseQRData(String rawData) {
    final now = DateTime.now();

    // Try to parse as JSON first
    try {
      final Map<String, dynamic> jsonData = json.decode(rawData);
      
      // Check if it's a credential
      if (jsonData.containsKey('credentialSubject') || 
          jsonData.containsKey('@context') && 
          jsonData['@context'].toString().contains('credentials')) {
        return QRResultModel(
          rawData: rawData,
          type: QRDataType.credential,
          parsedData: jsonData,
          scannedAt: now,
          title: 'Verifiable Credential',
          description: _extractCredentialDescription(jsonData),
        );
      }

      // Check if it's a DID
      if (jsonData.containsKey('id') && 
          jsonData['id'].toString().startsWith('did:')) {
        return QRResultModel(
          rawData: rawData,
          type: QRDataType.did,
          parsedData: jsonData,
          scannedAt: now,
          title: 'DID Document',
          description: 'Decentralized Identifier',
        );
      }

      return QRResultModel(
        rawData: rawData,
        type: QRDataType.text,
        parsedData: jsonData,
        scannedAt: now,
        title: 'JSON Data',
        description: 'Structured data',
      );
    } catch (e) {
      // Not JSON, check other patterns
      
      // Check if it's a DID string
      if (rawData.startsWith('did:')) {
        return QRResultModel(
          rawData: rawData,
          type: QRDataType.did,
          parsedData: {'did': rawData},
          scannedAt: now,
          title: 'DID',
          description: 'Decentralized Identifier',
        );
      }

      // Check if it's a URL
      if (rawData.startsWith('http://') || rawData.startsWith('https://')) {
        return QRResultModel(
          rawData: rawData,
          type: QRDataType.url,
          parsedData: {'url': rawData},
          scannedAt: now,
          title: 'URL',
          description: rawData,
        );
      }

      // Default to text
      return QRResultModel(
        rawData: rawData,
        type: QRDataType.text,
        parsedData: {'text': rawData},
        scannedAt: now,
        title: 'Text',
        description: rawData.length > 50 ? '${rawData.substring(0, 50)}...' : rawData,
      );
    }
  }

  String _extractCredentialDescription(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey('credentialSubject')) {
      final subject = jsonData['credentialSubject'];
      if (subject is Map && subject.containsKey('type')) {
        return 'Credential Type: ${subject['type']}';
      }
    }
    
    if (jsonData.containsKey('type')) {
      final types = jsonData['type'];
      if (types is List && types.isNotEmpty) {
        return 'Type: ${types.last}';
      }
    }

    return 'Verifiable Credential';
  }

  void dispose() {
    stopScanning();
  }
} 