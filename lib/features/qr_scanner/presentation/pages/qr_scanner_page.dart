import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/qr_scanner_widget.dart';
import '../../domain/entities/qr_result.dart';
import '../widgets/qr_result_widget.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _hasPermission = false;
  bool _isLoading = true;
  QRResult? _lastScannedResult;

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
    setState(() {
      _lastScannedResult = result;
    });
    
    // Show result dialog
    _showResultDialog(result);
  }

  void _showResultDialog(QRResult result) {
    showDialog(
      context: context,
      builder: (context) => QRResultDialog(
        result: result,
        onDismiss: () {
          Navigator.of(context).pop();
          setState(() {
            _lastScannedResult = null;
          });
        },
        onProcess: (result) {
          Navigator.of(context).pop();
          _processResult(result);
        },
      ),
    );
  }

  void _processResult(QRResult result) {
    // Handle different types of QR results
    switch (result.type) {
      case QRDataType.credential:
        _handleCredential(result);
        break;
      case QRDataType.did:
        _handleDID(result);
        break;
      case QRDataType.url:
        _handleURL(result);
        break;
      case QRDataType.text:
      case QRDataType.unknown:
        _handleText(result);
        break;
    }
  }

  void _handleCredential(QRResult result) {
    // Navigate to credential import/verification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Credential detected: ${result.description}'),
        action: SnackBarAction(
          label: 'Import',
          onPressed: () {
            // TODO: Navigate to credential import
          },
        ),
      ),
    );
  }

  void _handleDID(QRResult result) {
    // Navigate to DID import/verification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('DID detected: ${result.description}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // TODO: Navigate to DID details
          },
        ),
      ),
    );
  }

  void _handleURL(QRResult result) {
    // Handle URL - maybe open in browser
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL detected: ${result.description}'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            // TODO: Open URL in browser
          },
        ),
      ),
    );
  }

  void _handleText(QRResult result) {
    // Handle plain text
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text: ${result.description}'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // TODO: Copy to clipboard
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    return QRScannerWidget(
      onQRScanned: _onQRScanned,
      overlayText: 'Scan QR code for credentials, DIDs, or other data',
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade200,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We need camera access to scan QR codes for credentials and DIDs.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 