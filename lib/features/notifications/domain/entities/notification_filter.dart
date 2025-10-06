import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';

part 'notification_filter.freezed.dart';

@freezed
class NotificationFilter with _$NotificationFilter {
  const factory NotificationFilter({
    Set<NotificationType>? types,
    Set<NotificationPriority>? priorities,
    DateTime? startDate,
    DateTime? endDate,
    bool? unreadOnly,
    String? searchQuery,
    String? deviceId,
    String? location,
  }) = _NotificationFilter;

  const NotificationFilter._();

  bool matches(AppNotification notification) {
    if (types != null && !types!.contains(notification.type)) {
      return false;
    }
    
    if (priorities != null && !priorities!.contains(notification.priority)) {
      return false;
    }
    
    if ((unreadOnly ?? false) && notification.isRead) {
      return false;
    }
    
    if (startDate != null && notification.timestamp.isBefore(startDate!)) {
      return false;
    }
    
    if (endDate != null && notification.timestamp.isAfter(endDate!)) {
      return false;
    }
    
    if (deviceId != null && notification.deviceId != deviceId) {
      return false;
    }
    
    if (location != null && notification.location != location) {
      return false;
    }
    
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      final matchesTitle = notification.title.toLowerCase().contains(query);
      final matchesMessage = notification.message.toLowerCase().contains(query);
      if (!matchesTitle && !matchesMessage) {
        return false;
      }
    }
    
    return true;
  }
}