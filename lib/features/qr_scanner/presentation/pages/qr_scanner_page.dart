import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/qr_scanner_widget.dart';
import '../../domain/entities/qr_result.dart';

class QRScannerPage extends StatefulWidget {
  final Function(QRResult)? onQRScanned;

  const QRScannerPage({
    Key? key,
    this.onQRScanned,
  }) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() => _isLoading = true);

    final status = await Permission.camera.status;

    if (status == PermissionStatus.granted) {
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);

    final status = await Permission.camera.request();

    setState(() {
      _hasPermission = status == PermissionStatus.granted;
      _isLoading = false;
    });
  }

  void _onQRScanned(QRResult result) {
    // Call the parent's callback if provided
    widget.onQRScanned?.call(result);

    // Pop back to previous screen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please grant camera permission to scan QR codes',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: QRScannerWidget(
        onQRScanned: _onQRScanned,
      ),
    );
  }
}
