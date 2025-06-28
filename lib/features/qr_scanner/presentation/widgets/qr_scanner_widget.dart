import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/qr_result.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(QRResult) onQRScanned;
  final String? overlayText;

  const QRScannerWidget({
    Key? key,
    required this.onQRScanned,
    this.overlayText,
  }) : super(key: key);

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  late MobileScannerController controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final Barcode barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        _isProcessing = true;
        
        final qrResult = QRResult(
          rawData: barcode.rawValue!,
          type: _determineQRType(barcode.rawValue!),
          scannedAt: DateTime.now(),
          title: _generateTitle(barcode.rawValue!),
          description: _generateDescription(barcode.rawValue!),
        );
        
        widget.onQRScanned(qrResult);
        
        // Reset processing flag after a delay
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            _isProcessing = false;
          }
        });
        break;
      }
    }
  }

  QRDataType _determineQRType(String data) {
    if (data.startsWith('did:')) {
      return QRDataType.did;
    }
    
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return QRDataType.url;
    }
    
    try {
      // Try to parse as JSON
      if (data.contains('{') && data.contains('}')) {
        if (data.contains('credentialSubject') || data.contains('@context')) {
          return QRDataType.credential;
        }
      }
    } catch (e) {
      // Not valid JSON
    }
    
    return QRDataType.text;
  }

  String _generateTitle(String data) {
    final type = _determineQRType(data);
    switch (type) {
      case QRDataType.did:
        return 'DID';
      case QRDataType.credential:
        return 'Credential';
      case QRDataType.url:
        return 'URL';
      case QRDataType.text:
      case QRDataType.unknown:
        return 'Text';
    }
  }

  String _generateDescription(String data) {
    if (data.length > 50) {
      return '${data.substring(0, 50)}...';
    }
    return data;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scanner view
        MobileScanner(
          controller: controller,
          onDetect: _handleBarcode,
        ),
        
        // Scanner overlay
        _buildScannerOverlay(),
        
        // Flash toggle button
        Positioned(
          top: 50,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.black.withOpacity(0.5),
            onPressed: () => controller.toggleTorch(),
            child: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          const Expanded(flex: 2, child: SizedBox()),
          
          // Scanner frame
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Corner indicators
                    _buildCornerIndicator(Alignment.topLeft),
                    _buildCornerIndicator(Alignment.topRight),
                    _buildCornerIndicator(Alignment.bottomLeft),
                    _buildCornerIndicator(Alignment.bottomRight),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Instruction text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.overlayText ?? 'Point your camera at a QR code',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCornerIndicator(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? BorderSide(color: Theme.of(context).primaryColor, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? BorderSide(color: Theme.of(context).primaryColor, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? BorderSide(color: Theme.of(context).primaryColor, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? BorderSide(color: Theme.of(context).primaryColor, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
} 