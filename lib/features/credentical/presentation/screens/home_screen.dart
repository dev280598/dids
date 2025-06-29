import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/credentials_tab.dart';
import '../../../dids/presentation/screen/dids_tab.dart';
import '../../../qr_scanner/presentation/screen/scan_tab.dart';
import '../widgets/settings_tab.dart';
import '../providers/credential_provider.dart';
import '../../../qr_scanner/domain/entities/qr_result.dart';
import '../../data/models/credential.dart';
import '../../../qr_scanner/presentation/widgets/qr_scanner_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<CredentialsTabState> _credentialsTabKey = GlobalKey();

  // List of dummy credential types and their data
  final List<Map<String, dynamic>> _dummyCredentials = [
    {
      'title': 'University Degree',
      'issuer': 'Stanford University',
      'issuerLogo': '🎓',
      'description': 'Bachelor of Computer Science',
      'type': CredentialType.education,
      'data': {
        'degree': 'Bachelor of Science',
        'major': 'Computer Science',
        'graduationYear': '2024',
      },
    },
    {
      'title': 'Driver License',
      'issuer': 'DMV California',
      'issuerLogo': '🚗',
      'description': 'Class C Driver License',
      'type': CredentialType.license,
      'data': {
        'licenseClass': 'C',
        'restrictions': 'None',
        'endorsements': 'None',
      },
    },
    {
      'title': 'Employment Certificate',
      'issuer': 'Tech Corp Inc.',
      'issuerLogo': '💼',
      'description': 'Senior Software Engineer',
      'type': CredentialType.employment,
      'data': {
        'position': 'Senior Software Engineer',
        'department': 'Engineering',
        'startDate': '2024-01-01',
      },
    },
    {
      'title': 'Professional Certificate',
      'issuer': 'Microsoft',
      'issuerLogo': '📜',
      'description': 'Azure Cloud Architect',
      'type': CredentialType.certificate,
      'data': {
        'certification': 'Azure Solutions Architect Expert',
        'validUntil': '2025-12-31',
        'badgeId': 'MS-AZ305',
      },
    },
    {
      'title': 'Health Insurance',
      'issuer': 'Blue Shield',
      'issuerLogo': '🏥',
      'description': 'Premium Health Coverage',
      'type': CredentialType.other,
      'data': {
        'policyNumber': 'BSC-2024-123456',
        'coverage': 'Premium',
        'network': 'PPO',
      },
    },
  ];

  void _handleQRScanned(QRResult result) {
    // Switch to credentials tab with animation
    setState(() {
      _currentIndex = 0; // Credentials tab index
    });

    // Get a random dummy credential template
    final random = DateTime.now().millisecond % _dummyCredentials.length;
    final dummyData = _dummyCredentials[random];

    // Create credential with dummy data
    final credential = Credential(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: dummyData['title'],
      issuer: dummyData['issuer'],
      issuerLogo: dummyData['issuerLogo'],
      isVerified: true,
      issuedDate: DateTime.now(),
      expiryDate:
          DateTime.now().add(const Duration(days: 365)), // 1 year expiry
      description: dummyData['description'],
      type: dummyData['type'],
      data: dummyData['data'],
    );

    // Add credential with animation after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<CredentialProvider>().addCredential(credential);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == 2) { // If we're leaving the scan tab
            QRScannerWidget.pauseCamera(); // Pause the camera
          }
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) { // If we're entering the scan tab
            QRScannerWidget.startCamera(); // Start the camera
          }
        },
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Credentials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'DIDs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return CredentialsTab(key: _credentialsTabKey);
      case 1:
        return const DidsTab();
      case 2:
        return ScanTab(onQRScanned: _handleQRScanned);
      case 3:
        return const SettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
