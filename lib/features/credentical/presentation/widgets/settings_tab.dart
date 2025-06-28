import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
              // Security Section
              _buildSectionHeader('Security'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: authProvider.isBiometricEnabled
                      ? 'Enabled'
                      : 'Disabled',
                  trailing: Switch(
                    value: authProvider.isBiometricEnabled,
                    onChanged: authProvider.isBiometricAvailable
                        ? (value) => authProvider.enableBiometric(value)
                        : null,
                    activeColor: const Color(0xFF4CAF50),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.lock,
                  title: 'Change PIN',
                  subtitle: 'Update your security PIN',
                  onTap: () => _showChangePinDialog(context),
                ),
              ]),

              const SizedBox(height: 24),

              // Data Section
              _buildSectionHeader('Data'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.backup,
                  title: 'Backup & Restore',
                  subtitle: 'Backup your credentials and DIDs',
                  onTap: () => _showBackupOptions(context),
                ),
                _buildSettingsTile(
                  icon: Icons.delete_forever,
                  title: 'Clear All Data',
                  subtitle: 'Remove all credentials and settings',
                  onTap: () => _showClearDataDialog(context, authProvider),
                  textColor: Colors.red,
                ),
              ]),

              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('About'),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'App Version',
                  subtitle: '1.0.0 (MVP Demo)',
                  onTap: () => _showAboutDialog(context),
                ),
              ]),

              const SizedBox(height: 32),

              // Logout Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context, authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? const Color(0xFF4CAF50)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
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
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
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

  void _showClearDataDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await authProvider.resetApp();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/pin');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All'),
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

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/pin');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
} 