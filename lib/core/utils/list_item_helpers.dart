import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/widgets/unified_list/unified_list_item.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';

/// Shared helper methods for list item display
class ListItemHelpers {
  ListItemHelpers._();

  /// Get icon for device type
  static IconData getDeviceIcon(String type) {
    switch (type) {
      case 'access_point':
        return Icons.wifi;
      case 'switch':
        return Icons.hub;
      case 'ont':
        return Icons.fiber_manual_record;
      case 'wlan_controller':
        return Icons.router;
      default:
        return Icons.devices_other;
    }
  }

  /// Map device status to unified status
  static UnifiedItemStatus mapDeviceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return UnifiedItemStatus.online;
      case 'offline':
        return UnifiedItemStatus.offline;
      case 'warning':
        return UnifiedItemStatus.warning;
      case 'error':
        return UnifiedItemStatus.error;
      default:
        return UnifiedItemStatus.unknown;
    }
  }

  /// Get color for status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get icon for notification type
  static IconData getNotificationIcon(String type) {
    switch (type) {
      case 'deviceOffline':
        return Icons.wifi_off;
      case 'deviceNote':
        return Icons.note_outlined;
      case 'missingImage':
        return Icons.image_not_supported_outlined;
      case 'deviceOnline':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  /// Get color for notification type
  static Color getNotificationColor(String type) {
    // Unified colors: Red for critical, Orange for warnings, Blue for info
    switch (type) {
      case 'deviceOffline':
      case 'error':
        return Colors.red;
      case 'deviceNote':
      case 'warning':
        return Colors.orange;
      case 'missingImage':
      case 'info':
        return Colors.blue;
      case 'deviceOnline':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Map notification priority to unified status
  static UnifiedItemStatus mapNotificationStatus(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return UnifiedItemStatus.error;
      case NotificationPriority.medium:
        return UnifiedItemStatus.warning;
      case NotificationPriority.low:
        return UnifiedItemStatus.info;
    }
  }

  /// Format timestamp for display
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}