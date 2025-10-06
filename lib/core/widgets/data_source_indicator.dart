import 'package:flutter/material.dart';

/// Widget that displays the current data source (Mock or Real API)
class DataSourceIndicator extends StatelessWidget {
  const DataSourceIndicator({required this.isUsingMockData, super.key, this.errorMessage});
  final bool isUsingMockData;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (!isUsingMockData && errorMessage == null) {
      // Successfully using real API - don't show anything
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUsingMockData ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUsingMockData ? Colors.orange : Colors.green, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUsingMockData ? Icons.developer_mode : Icons.cloud_done,
            size: 16,
            color: isUsingMockData ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 6),
          Text(
            isUsingMockData ? 'Mock Data' : 'Live API',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUsingMockData ? Colors.orange : Colors.green,
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: errorMessage,
              child: Icon(Icons.info_outline, size: 14, color: isUsingMockData ? Colors.orange : Colors.green),
            ),
          ],
        ],
      ),
    );
  }
}

/// Banner version for more prominent display
class DataSourceBanner extends StatelessWidget {
  const DataSourceBanner({required this.isUsingMockData, super.key, this.errorMessage, this.onDismiss});
  final bool isUsingMockData;
  final String? errorMessage;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!isUsingMockData && errorMessage == null) {
      // Successfully using real API - don't show banner
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      backgroundColor: isUsingMockData ? Colors.orange.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
      content: Row(
        children: [
          Icon(
            isUsingMockData ? Icons.developer_mode : Icons.cloud_off,
            color: isUsingMockData ? Colors.orange : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUsingMockData ? 'Using Mock Data' : 'API Connection Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUsingMockData ? Colors.orange[800] : Colors.red[800],
                  ),
                ),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(fontSize: 12, color: isUsingMockData ? Colors.orange[700] : Colors.red[700]),
                  )
                else
                  Text(
                    isUsingMockData ? 'Development mode - showing sample data' : 'Falling back to mock data',
                    style: TextStyle(fontSize: 12, color: isUsingMockData ? Colors.orange[700] : Colors.red[700]),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [if (onDismiss != null) TextButton(onPressed: onDismiss, child: const Text('DISMISS'))],
    );
  }
}
