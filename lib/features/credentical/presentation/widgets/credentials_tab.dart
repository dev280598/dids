import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credential_provider.dart';
import '../../data/models/credential.dart';
import 'credential_card.dart';

class CredentialsTab extends StatefulWidget {
  const CredentialsTab({super.key});

  @override
  State<CredentialsTab> createState() => CredentialsTabState();
}

class CredentialsTabState extends State<CredentialsTab> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Credential> _previousCredentials = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Credentials',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: _showAddCredentialDialog,
          ),
          IconButton(
            icon:
                const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Consumer<CredentialProvider>(
        builder: (context, credentialProvider, child) {
          // Check for new credentials
          final currentCredentials = credentialProvider.credentials;
          if (_previousCredentials.length < currentCredentials.length) {
            // New credential was added
            final newCredential = currentCredentials.first;
            if (!_previousCredentials.contains(newCredential) &&
                _previousCredentials.isNotEmpty) {
              // Animate the new credential
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _listKey.currentState?.insertItem(0);
              });
            }
          }
          _previousCredentials = List.from(currentCredentials);

          return Column(
            children: [
              // Search and Filter Bar
              _buildSearchAndFilter(credentialProvider),

              // Sort Options
              _buildSortOptions(),

              // Credentials List
              Expanded(
                child: _buildCredentialsList(credentialProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(CredentialProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Filter Button
          GestureDetector(
            onTap: () => _showFilterDialog(provider),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Date issued (newest to oldest)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsList(CredentialProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final credentials = provider.credentials;

    if (credentials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No credentials found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first credential to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      initialItemCount: credentials.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index, animation) {
        final credential = credentials[index];
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CredentialCard(credential: credential),
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog(CredentialProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...CredentialType.values.map((type) {
                return ListTile(
                  title: Text(type.displayName),
                  trailing: provider.filterType == type
                      ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                      : null,
                  onTap: () {
                    provider
                        .setFilter(provider.filterType == type ? null : type);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Clear Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCredentialDialog() {
    // For demo purposes, we'll just show a simple dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Credential'),
          content: const Text(
            'In a real app, this would open a form to manually add credentials or scan a QR code.',
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
}
