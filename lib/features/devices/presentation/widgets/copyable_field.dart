import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A row widget that displays a label-value pair with an optional copy button.
/// Used in device detail views to allow copying field values to clipboard.
class CopyableField extends StatelessWidget {
  const CopyableField({
    required this.label,
    required this.value,
    this.showCopyButton = true,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final bool showCopyButton;
  final Color? valueColor;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          // Value with optional copy button
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: valueColor != null ? FontWeight.bold : null,
                      color: valueColor,
                    ),
                  ),
                ),
                if (showCopyButton && value.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 18,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    onPressed: () => _copyToClipboard(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'Copy $label',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
