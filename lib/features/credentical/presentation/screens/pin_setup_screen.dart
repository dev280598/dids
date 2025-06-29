import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

enum PinSetupStep { create, confirm }

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> with TickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  PinSetupStep _currentStep = PinSetupStep.create;
  static const int _pinLength = 6;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentStep == PinSetupStep.create ? 'Create PIN' : 'Confirm PIN',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Header with step info
                  _buildStepHeader(),
                  
                  const SizedBox(height: 60),
                  
                  // PIN Input Circles
                  _buildPinDisplay(),
                  
                  const SizedBox(height: 24),
                  
                  // Instruction Text
                  _buildInstructionText(),
                  
                  const Spacer(),
                  
                  // Numeric Keypad
                  _buildKeypad(),
                  
                  const SizedBox(height: 32),
                  
                  // Loading indicator
                  if (authProvider.isLoading)
                    const CircularProgressIndicator(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    return Column(
      children: [
        // Step indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepCircle(1, _currentStep == PinSetupStep.create),
            Container(
              width: 40,
              height: 2,
              color: _currentStep == PinSetupStep.confirm
                  ? const Color(0xFF4CAF50)
                  : Colors.grey.shade300,
            ),
            _buildStepCircle(2, _currentStep == PinSetupStep.confirm),
          ],
        ),
        const SizedBox(height: 24),
        
        // Title
        Text(
          _currentStep == PinSetupStep.create
              ? 'Create Your PIN'
              : 'Confirm Your PIN',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          _currentStep == PinSetupStep.create
              ? 'Choose a 6-digit PIN to secure your wallet'
              : 'Enter your PIN again to confirm',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildPinDisplay() {
    final currentPin = _currentStep == PinSetupStep.create ? _pin : _confirmPin;
    
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (index) {
              final isFilled = index < currentPin.length;
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
          ),
        );
      },
    );
  }

  Widget _buildInstructionText() {
    if (_currentStep == PinSetupStep.create) {
      return Text(
        'Enter a 6-digit PIN',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      );
    } else {
      return Column(
        children: [
          Text(
            'Confirm your PIN',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (_confirmPin.length == _pinLength && _confirmPin != _pin)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'PINs do not match. Please try again.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      );
    }
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

  void _onNumberPressed(String number) {
    if (_currentStep == PinSetupStep.create) {
      if (_pin.length < _pinLength) {
        setState(() {
          _pin += number;
        });
        
        if (_pin.length == _pinLength) {
          // Move to confirm step
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              _currentStep = PinSetupStep.confirm;
            });
          });
        }
      }
    } else {
      if (_confirmPin.length < _pinLength) {
        setState(() {
          _confirmPin += number;
        });
        
        if (_confirmPin.length == _pinLength) {
          _validateAndSetupPin();
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_currentStep == PinSetupStep.create) {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
        });
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        });
      } else if (_confirmPin.isEmpty) {
        // Go back to create step
        setState(() {
          _currentStep = PinSetupStep.create;
          _pin = '';
        });
      }
    }
  }

  Future<void> _validateAndSetupPin() async {
    if (_pin != _confirmPin) {
      // Show error message and shake animation
      if (mounted) {
        // Trigger shake animation
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PINs do not match. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Reset confirm step
      setState(() {
        _confirmPin = '';
      });
      return;
    }

    // PINs match, setup the PIN
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.setupPin(_pin);

    if (success) {
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN created successfully!'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate to home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to create PIN'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Reset to create step
        setState(() {
          _pin = '';
          _confirmPin = '';
          _currentStep = PinSetupStep.create;
        });
      }
    }
  }
} 