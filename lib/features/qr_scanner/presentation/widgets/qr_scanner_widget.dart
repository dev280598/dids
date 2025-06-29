import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/qr_result.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(QRResult)? onQRScanned;
  static final MobileScannerController _globalController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  const QRScannerWidget({
    super.key,
    this.onQRScanned,
  });

  static void pauseCamera() {
    _globalController.stop();
  }

  static void startCamera() {
    _globalController.start();
  }

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> with WidgetsBindingObserver {
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    QRScannerWidget.startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    QRScannerWidget.pauseCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        QRScannerWidget.startCamera();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        QRScannerWidget.pauseCamera();
        break;
      default:
        break;
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scanner
        MobileScanner(
          controller: QRScannerWidget._globalController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final barcode = barcodes.first;
              if (barcode.rawValue != null) {
                final qrResult = QRResult(
                  rawData: barcode.rawValue!,
                  type: _determineQRType(barcode.rawValue!),
                  scannedAt: DateTime.now(),
                );
                widget.onQRScanned?.call(qrResult);
              }
            }
          },
        ),

        // Minimal overlay with scan area
        CustomPaint(
          size: Size.infinite,
          painter: ScanAreaPainter(),
        ),

        // Flash toggle
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
                QRScannerWidget._globalController.toggleTorch();
              });
            },
          ),
        ),
      ],
    );
  }
}

class ScanAreaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12))),
      ),
      paint,
    );

    // Draw scan area border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 