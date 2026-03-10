import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/widgets/unified_list/unified_list_item.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';

/// Shared helper methods for list item display
class ListItemHelpers {
  ListItemHelpers._();

  /// Get icon for device type
  static IconData getDeviceIcon(String type) => switch (type) {
    'access_point' => Icons.wifi,
    'switch' => Icons.hub,
    'ont' => Icons.fiber_manual_record,
    'wlan_controller' => Icons.router,
    _ => Icons.devices_other,
  };

  /// Map device status to unified status
  static UnifiedItemStatus mapDeviceStatus(String status) => switch (status.toLowerCase()) {
    'online' => UnifiedItemStatus.online,
    'offline' => UnifiedItemStatus.offline,
    'warning' => UnifiedItemStatus.warning,
    'error' => UnifiedItemStatus.error,
    _ => UnifiedItemStatus.unknown,
  };

  /// Get color for status (list items: offline = red for visibility)
  static Color getStatusColor(String status) => switch (status.toLowerCase()) {
    'online' => Colors.green,
    'offline' => Colors.red,
    'warning' => Colors.orange,
    'error' => Colors.red,
    _ => Colors.grey,
  };

  /// Get color for status in filter buttons (offline = grey for inactive look)
  static Color getFilterStatusColor(String status) => switch (status.toLowerCase()) {
    'online' => Colors.green,
    'offline' => Colors.grey,
    'warning' => Colors.orange,
    'error' => Colors.red,
    _ => Colors.grey,
  };

  /// Get icon for device status
  static IconData getStatusIcon(String status) => switch (status.toLowerCase()) {
    'online' => Icons.check_circle,
    'offline' => Icons.cancel,
    'warning' => Icons.warning,
    'error' => Icons.error,
    _ => Icons.help,
  };

  /// Get icon for notification type
  static IconData getNotificationIcon(String type) => switch (type) {
    'deviceOffline' => Icons.wifi_off,
    'deviceNote' => Icons.note_outlined,
    'missingImage' => Icons.image_not_supported_outlined,
    'deviceOnline' => Icons.check_circle_outline,
    'error' => Icons.error_outline,
    'warning' => Icons.warning_amber,
    'info' => Icons.info_outline,
    _ => Icons.notifications,
  };

  /// Get color for notification type
  static Color getNotificationColor(String type) => switch (type) {
    'deviceOffline' || 'error' => Colors.red,
    'deviceNote' || 'warning' => Colors.orange,
    'missingImage' || 'info' => Colors.blue,
    'deviceOnline' => Colors.green,
    _ => Colors.grey,
  };

  /// Map notification priority to unified status
  static UnifiedItemStatus mapNotificationStatus(NotificationPriority priority) => switch (priority) {
    NotificationPriority.urgent => UnifiedItemStatus.error,
    NotificationPriority.medium => UnifiedItemStatus.warning,
    NotificationPriority.low => UnifiedItemStatus.info,
  };

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