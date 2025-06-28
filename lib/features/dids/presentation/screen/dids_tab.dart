import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../credentical/presentation/providers/credential_provider.dart';

class DidsTab extends StatelessWidget {
  const DidsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DIDs',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () => _showAddDidDialog(context),
          ),
        ],
      ),
      body: Consumer<CredentialProvider>(
        builder: (context, credentialProvider, child) {
          final dids = credentialProvider.dids;

          if (dids.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No DIDs found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first DID to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showAddDidDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: const Text('Create DID'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dids.length,
            itemBuilder: (context, index) {
              final did = dids[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4CAF50),
                    child: Text(
                      did.method.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'DID:${did.method}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    did.fullDid,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    did.isActive ? Icons.check_circle : Icons.circle_outlined,
                    color: did.isActive ? Colors.green : Colors.grey,
                  ),
                  onTap: () => _showDidDetails(context, did),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New DID'),
          content: const Text(
            'In a real app, this would generate a new DID using cryptographic methods and blockchain technology.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Here you would actually create a new DID
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('DID creation would be implemented here'),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showDidDetails(BuildContext context, did) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('DID Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Full DID: ${did.fullDid}'),
              const SizedBox(height: 8),
              Text('Method: ${did.method}'),
              const SizedBox(height: 8),
              Text('Controller: ${did.controller}'),
              const SizedBox(height: 8),
              Text('Status: ${did.isActive ? 'Active' : 'Inactive'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
} 