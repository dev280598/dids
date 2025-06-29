import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EnableBiometricModal extends StatelessWidget {
  const EnableBiometricModal({
    super.key,
    required this.biometricType,
    required this.onDontAllow,
    required this.onOK,
  });

  final String biometricType; // "Face ID", "Touch ID", etc.
  final VoidCallback onDontAllow;
  final VoidCallback onOK;

  @override
  Widget build(BuildContext context) {
    debugPrint('🔐 EnableBiometricModal: Building modal for $biometricType');
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Do you want to enable $biometricType for transaction confirmation?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Use $biometricType instead of your PIN to confirm future transfers. You can change this anytime in Settings.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    debugPrint('🔐 EnableBiometricModal: User tapped "Don\'t Allow"');
                    onDontAllow();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: const Color(0xFF374151),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Don\'t Allow',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('🔐 EnableBiometricModal: User tapped "OK"');
                    onOK();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3059FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 