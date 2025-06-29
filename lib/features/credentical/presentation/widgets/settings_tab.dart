import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isCheckingBiometrics = true;
  String _biometricStatus = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isCheckingBiometrics = true;
    });

    try {
      final isAvailable = await authProvider.checkBiometricAvailability();
      setState(() {
        _biometricStatus =
            isAvailable ? 'Available' : 'Not available on this device';
      });
    } catch (e) {
      setState(() {
        _biometricStatus = 'Error checking biometrics';
      });
    } finally {
      setState(() {
        _isCheckingBiometrics = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Backup wallet',
                  onTap: () {},
                
                ),
                _buildSettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Remove wallet',
                    onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.check_circle_outline,
                  title: 'Credentical Verifier',
                    onTap: () {},
                ),
              ]),
              SizedBox(height: 16),
              _buildSettingsCard([
              
                _buildSettingsTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: _isCheckingBiometrics
                      ? 'Checking availability...'
                      : _getBiometricSubtitle(authProvider),
                  trailing: _isCheckingBiometrics
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Switch(
                          value: authProvider.isBiometricEnabled,
                          onChanged: authProvider.isBiometricAvailable
                              ? (value) => authProvider.enableBiometric(value)
                              : null,
                          activeColor: const Color(0xFF4CAF50),
                        ),
                ),
              ]),

              const SizedBox(height: 24),

              // Logout Button
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red, size: 16,),
                  onPressed: () => _showClearAuthDialog(context, authProvider),
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.red.shade50,
                  //   foregroundColor: Colors.red.shade700,
                  //   padding: const EdgeInsets.symmetric(vertical: 16),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //     side: BorderSide(color: Colors.red.shade200),
                  //   ),
                  //   elevation: 0,
                  // ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getBiometricSubtitle(AuthProvider authProvider) {
    if (!authProvider.isBiometricAvailable) {
      return _biometricStatus;
    }
    return authProvider.isBiometricEnabled
        ? 'Enabled'
        : 'Available but disabled';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card.filled(
      color: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
      
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
     String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(118),
        ),
        child: Icon(
          icon,
          color: textColor ?? const Color(0xFF4CAF50),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle ?? '',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _showChangePinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change PIN'),
          content: const Text(
            'This would open a flow to change the current PIN.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showBackupOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Backup & Restore'),
          content: const Text(
            'Backup your credentials and DIDs securely.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DID Wallet',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 DID Wallet Demo\nBuilt with Flutter',
    );
  }

  void _showClearAuthDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Authentication'),
          content: const Text(
            'This will clear your PIN and disable biometric authentication. You will need to set up a new PIN when you restart the app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Clear PIN and biometric
                await authProvider.clearPinAndBiometric();

                if (context.mounted) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Authentication cleared successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate back to welcome screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
