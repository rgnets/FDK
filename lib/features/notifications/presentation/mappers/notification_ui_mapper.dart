import 'package:flutter/material.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';

/// Maps notification domain models to UI representations
/// Consider using extension methods on the enums for better type safety
class NotificationUIMapper {
  // Private constructor to prevent instantiation
  NotificationUIMapper._();
  
  static IconData getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.deviceOffline:
        return Icons.wifi_off;
      case NotificationType.deviceNote:
        return Icons.note;
      case NotificationType.missingImage:
        return Icons.image_not_supported;
      case NotificationType.deviceOnline:
        return Icons.check_circle;
      case NotificationType.scanComplete:
        return Icons.qr_code_scanner;
      case NotificationType.syncComplete:
        return Icons.sync;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.system:
        return Icons.settings_outlined;
    }
  }
  
  static Color getColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return Colors.red;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.low:
        return Colors.green;
    }
  }
  
  /// Get color with theme awareness
  static Color getThemedColor(BuildContext context, NotificationPriority priority) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (priority) {
      case NotificationPriority.urgent:
        return colorScheme.error;
      case NotificationPriority.medium:
        return colorScheme.tertiary;
      case NotificationPriority.low:
        return colorScheme.primary;
    }
  }
}