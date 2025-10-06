import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    required DateTime timestamp,
    required bool isRead,
    String? deviceId,
    String? location,
    Map<String, dynamic>? metadata,
  }) = _AppNotification;

  const AppNotification._();
}

enum NotificationType {
  deviceOffline,
  deviceNote,
  missingImage,
  deviceOnline,
  scanComplete,
  syncComplete,
  error,
  warning,
  info,
  system,
}

enum NotificationPriority {
  urgent,    // Red - for offline devices
  medium,    // Orange - for device notes
  low,       // Green - for missing images
}