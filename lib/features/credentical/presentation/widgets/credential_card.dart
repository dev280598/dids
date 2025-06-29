import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/credential.dart';

class CredentialCard extends StatelessWidget {
  final Credential credential;

  const CredentialCard({
    super.key,
    required this.credential,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      elevation: 0.2,
      color: Colors.grey.shade100,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.1),
      //       blurRadius: 8,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
               
                
                // Title and Issuer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        credential.issuer,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                 // Issuer Logo/Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(120),
                  ),
                  child: Center(
                    child: Text(
                      credential.issuerLogo,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // // More Options Menu
                // IconButton(
                //   icon: const Icon(Icons.more_vert, color: Colors.grey),
                //   onPressed: () => _showOptionsMenu(context),
                // ),
              ],
            ),
            
            const SizedBox(height: 36),
            
            // Status and Date Row
            Row(
              children: [
                // Selective Disclosure Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Colors.purple.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Selective Disclosure',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                 // Expiry Date
                if (credential.expiryDate != null)
                  Text(
                    'Exp: ${DateFormat('MMM d yyyy').format(credential.expiryDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: credential.isExpired 
                          ? Colors.red.shade600 
                          : Colors.grey.shade600,
                      fontWeight: credential.isExpired 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Verification Status and Expiry
            Row(
              children: [
                // Verified Badge
                if (credential.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Spacer(),
                 // Issue Date
                Text(
                  'Issued: ${DateFormat('MMM d yyyy').format(credential.issuedDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
               
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCredentialType(CredentialType type) {
    switch (type) {
      case CredentialType.identity:
        return Colors.blue.shade500;
      case CredentialType.license:
        return Colors.orange.shade500;
      case CredentialType.certificate:
        return Colors.purple.shade500;
      case CredentialType.employment:
        return Colors.green.shade500;
      case CredentialType.education:
        return Colors.indigo.shade500;
      case CredentialType.other:
        return Colors.grey.shade500;
    }
  }

  void _showOptionsMenu(BuildContext context) {
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
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showCredentialDetails(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle share
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('Show QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle QR code display
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCredentialDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(credential.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issuer: ${credential.issuer}'),
              const SizedBox(height: 8),
              Text('Type: ${credential.type.displayName}'),
              const SizedBox(height: 8),
              Text('Issued: ${DateFormat('MMM d, yyyy').format(credential.issuedDate)}'),
              if (credential.expiryDate != null) ...[
                const SizedBox(height: 8),
                Text('Expires: ${DateFormat('MMM d, yyyy').format(credential.expiryDate!)}'),
              ],
              const SizedBox(height: 8),
              Text('Status: ${credential.isVerified ? 'Verified' : 'Unverified'}'),
              const SizedBox(height: 8),
              Text('Description: ${credential.description}'),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Credential'),
          content: Text('Are you sure you want to delete "${credential.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle delete - would normally use Provider here
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
} 