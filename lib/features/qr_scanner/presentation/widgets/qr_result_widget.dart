import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/qr_result.dart';

class QRResultDialog extends StatelessWidget {
  final QRResult result;
  final VoidCallback onDismiss;
  final Function(QRResult) onProcess;

  const QRResultDialog({
    Key? key,
    required this.result,
    required this.onDismiss,
    required this.onProcess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildTypeIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.title ?? 'QR Code Result',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getTypeColor()),
              ),
              child: Text(
                _getTypeText(),
                style: TextStyle(
                  color: _getTypeColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            if (result.description != null) ...[
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                result.description!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],
            
            // Raw data preview
            Text(
              'Data:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(
                  result.rawData,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.rawData));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    child: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onProcess(result),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getTypeColor(),
                    ),
                    child: Text(_getProcessButtonText()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color = _getTypeColor();
    
    switch (result.type) {
      case QRDataType.credential:
        icon = Icons.badge_outlined;
        break;
      case QRDataType.did:
        icon = Icons.person_outline;
        break;
      case QRDataType.url:
        icon = Icons.link;
        break;
      case QRDataType.text:
      case QRDataType.unknown:
        icon = Icons.text_fields;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getTypeColor() {
    switch (result.type) {
      case QRDataType.credential:
        return Colors.green;
      case QRDataType.did:
        return Colors.blue;
      case QRDataType.url:
        return Colors.orange;
      case QRDataType.text:
      case QRDataType.unknown:
        return Colors.grey;
    }
  }

  String _getTypeText() {
    switch (result.type) {
      case QRDataType.credential:
        return 'CREDENTIAL';
      case QRDataType.did:
        return 'DID';
      case QRDataType.url:
        return 'URL';
      case QRDataType.text:
        return 'TEXT';
      case QRDataType.unknown:
        return 'UNKNOWN';
    }
  }

  String _getProcessButtonText() {
    switch (result.type) {
      case QRDataType.credential:
        return 'Import';
      case QRDataType.did:
        return 'View';
      case QRDataType.url:
        return 'Open';
      case QRDataType.text:
      case QRDataType.unknown:
        return 'Process';
    }
  }
}

class QRResultCard extends StatelessWidget {
  final QRResult result;
  final VoidCallback? onTap;

  const QRResultCard({
    Key? key,
    required this.result,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildTypeIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title ?? 'QR Code',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (result.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Scanned ${_formatTime(result.scannedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;
    
    switch (result.type) {
      case QRDataType.credential:
        icon = Icons.badge_outlined;
        color = Colors.green;
        break;
      case QRDataType.did:
        icon = Icons.person_outline;
        color = Colors.blue;
        break;
      case QRDataType.url:
        icon = Icons.link;
        color = Colors.orange;
        break;
      case QRDataType.text:
      case QRDataType.unknown:
        icon = Icons.text_fields;
        color = Colors.grey;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
} 