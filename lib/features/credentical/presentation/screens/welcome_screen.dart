import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pin_setup_screen.dart';
import 'import_wallet_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Logo and Welcome Text
              _buildHeader(),
              
              const SizedBox(height: 40),
              
              // Description
              _buildDescription(),
              
              const Spacer(),
              
              // Create Wallet Button
              _buildCreateWalletButton(context),
              
              const SizedBox(height: 16),
              
              // Import Wallet Button
              _buildImportWalletButton(context),
              
              const SizedBox(height: 32),
              
              // Terms and Privacy
              _buildTermsText(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        
        // Welcome Text
        Text(
          'Welcome to\nDID Wallet',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          'Your secure digital identity wallet',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Store and manage your digital credentials, DIDs, and verifiable documents safely and securely.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateWalletButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _onCreateWallet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 24),
            const SizedBox(width: 12),
            Text(
              'Create New Wallet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportWalletButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => _onImportWallet(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          side: const BorderSide(
            color: Color(0xFF4CAF50),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_outlined, size: 24),
            const SizedBox(width: 12),
            Text(
              'Import Existing Wallet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: ' and ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void _onCreateWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinSetupScreen(),
      ),
    );
  }

  void _onImportWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImportWalletScreen(),
      ),
    );
  }
} 