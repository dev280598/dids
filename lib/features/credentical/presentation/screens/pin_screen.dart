import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  static const int _pinLength = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo and App Name
                  _buildHeader(),

                  const Spacer(),

                  // PIN Input Circles
                  _buildPinDisplay(),

                  const SizedBox(height: 24),

                  // Enter PIN Text
                  const Text(
                    'Enter your passcode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  const Spacer(),

                  // Numeric Keypad
                  _buildKeypad(),

                  const SizedBox(height: 32),

                  // Biometric Login Button
                  if (authProvider.isBiometricAvailable &&
                      authProvider.isBiometricEnabled)
                    _buildBiometricButton(authProvider),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),

        // App Name
        const Text(
          'DID Wallet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? const Color(0xFF4CAF50) : Colors.transparent,
            border: Border.all(
              color: isFilled ? const Color(0xFF4CAF50) : Colors.grey.shade400,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 24),

        // Row 2: 4, 5, 6
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 24),

        // Row 3: 7, 8, 9
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 24),

        // Row 4: empty, 0, delete
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80), // Empty space
            _buildKeypadButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map(_buildKeypadButton).toList(),
    );
  }

  Widget _buildKeypadButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(AuthProvider authProvider) {
    return GestureDetector(
      onTap: () => _authenticateWithBiometric(authProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Text(
          'Login with biometric',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _onNumberPressed(String number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == _pinLength) {
        _authenticateWithPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _authenticateWithPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final isAuthenticated = await authProvider.authenticateWithPin(_pin);

    if (isAuthenticated) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // Show error and reset PIN
      setState(() {
        _pin = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _authenticateWithBiometric(AuthProvider authProvider) async {
    final isAuthenticated = await authProvider.authenticateWithBiometric();

    if (isAuthenticated) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                authProvider.errorMessage ?? 'Biometric authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
