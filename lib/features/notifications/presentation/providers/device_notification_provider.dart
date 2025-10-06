import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/notification_generation_service.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_notification_provider.g.dart';

/// Notification generation service provider (re-export from core providers)
@riverpod
NotificationGenerationService notificationGenerationService(NotificationGenerationServiceRef ref) {
  return ref.watch(notificationGenerationServiceProvider);
}

/// Domain notification repository provider (re-export from core providers)
@riverpod
NotificationRepository domainNotificationRepository(DomainNotificationRepositoryRef ref) {
  return ref.watch(notificationRepositoryProvider);
}

/// Main device-based notifications provider
@riverpod
class DeviceNotificationsNotifier extends _$DeviceNotificationsNotifier {
  @override
  Future<List<AppNotification>> build() async {
    final repository = ref.read(domainNotificationRepositoryProvider);
    final result = await repository.getNotifications();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (notifications) => notifications,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(domainNotificationRepositoryProvider);
      final result = await repository.getNotifications();
      
      result.fold(
        (failure) => state = AsyncValue.error(Exception(failure.message), StackTrace.current),
        (notifications) => state = AsyncValue.data(notifications),
      );
    } on Exception catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    final repository = ref.read(domainNotificationRepositoryProvider);
    final result = await repository.markAsRead(id);
    
    result.fold(
      (failure) {
        // Handle error if needed
        LoggerService.error('Failed to mark notification as read: ${failure.message}');
      },
      (_) {
        // Update the local state
        final currentState = state;
        if (currentState is AsyncData<List<AppNotification>>) {
          final updatedNotifications = currentState.value.map((notification) {
            if (notification.id == id) {
              return notification.copyWith(isRead: true);
            }
            return notification;
          }).toList();
          state = AsyncValue.data(updatedNotifications);
        }
      },
    );
  }

  Future<void> markAllAsRead() async {
    final repository = ref.read(domainNotificationRepositoryProvider);
    final result = await repository.markAllAsRead();
    
    result.fold(
      (failure) {
        // Handle error if needed
        LoggerService.error('Failed to mark all notifications as read: ${failure.message}');
      },
      (_) {
        // Update the local state
        final currentState = state;
        if (currentState is AsyncData<List<AppNotification>>) {
          final updatedNotifications = currentState.value
              .map((notification) => notification.copyWith(isRead: true))
              .toList();
          state = AsyncValue.data(updatedNotifications);
        }
      },
    );
  }

  Future<void> deleteNotification(String id) async {
    final repository = ref.read(domainNotificationRepositoryProvider);
    final result = await repository.deleteNotification(id);
    
    result.fold(
      (failure) {
        // Handle error if needed
        LoggerService.error('Failed to delete notification: ${failure.message}');
      },
      (_) {
        // Remove from local state
        final currentState = state;
        if (currentState is AsyncData<List<AppNotification>>) {
          final updatedNotifications = currentState.value
              .where((notification) => notification.id != id)
              .toList();
          state = AsyncValue.data(updatedNotifications);
        }
      },
    );
  }

  Future<void> clearNotifications({NotificationFilter? filter}) async {
    final repository = ref.read(domainNotificationRepositoryProvider);
    final result = await repository.clearNotifications(filter: filter);
    
    result.fold(
      (failure) {
        // Handle error if needed
        LoggerService.error('Failed to clear notifications: ${failure.message}');
      },
      (_) {
        if (filter == null) {
          // Clear all notifications
          state = const AsyncValue.data([]);
        } else {
          // Remove filtered notifications from local state
          final currentState = state;
          if (currentState is AsyncData<List<AppNotification>>) {
            final updatedNotifications = currentState.value
                .where((notification) => !filter.matches(notification))
                .toList();
            state = AsyncValue.data(updatedNotifications);
          }
        }
      },
    );
  }
}

/// Provider for unread device notifications
@riverpod
List<AppNotification> unreadDeviceNotifications(UnreadDeviceNotificationsRef ref) {
  final notifications = ref.watch(deviceNotificationsNotifierProvider);
  
  return notifications.when(
    data: (notificationList) => 
        notificationList.where((notification) => !notification.isRead).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for unread device notifications count
@riverpod
int unreadDeviceNotificationCount(UnreadDeviceNotificationCountRef ref) {
  final unreadNotifications = ref.watch(unreadDeviceNotificationsProvider);
  return unreadNotifications.length;
}

/// Provider to check if there are unread device notifications
@riverpod
bool hasUnreadDeviceNotifications(HasUnreadDeviceNotificationsRef ref) {
  final unreadCount = ref.watch(unreadDeviceNotificationCountProvider);
  return unreadCount > 0;
}

/// Provider for notifications filtered by priority
@riverpod
List<AppNotification> notificationsByPriority(
  NotificationsByPriorityRef ref,
  NotificationPriority priority,
) {
  final notifications = ref.watch(deviceNotificationsNotifierProvider);
  
  return notifications.when(
    data: (notificationList) => notificationList
        .where((notification) => notification.priority == priority)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for notifications filtered by type
@riverpod
List<AppNotification> deviceNotificationsByType(
  DeviceNotificationsByTypeRef ref,
  NotificationType type,
) {
  final notifications = ref.watch(deviceNotificationsNotifierProvider);
  
  return notifications.when(
    data: (notificationList) => notificationList
        .where((notification) => notification.type == type)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for URGENT priority notifications (offline devices)
@riverpod
List<AppNotification> urgentNotifications(UrgentNotificationsRef ref) {
  return ref.watch(notificationsByPriorityProvider(NotificationPriority.urgent));
}

/// Provider for MEDIUM priority notifications (device notes)  
@riverpod
List<AppNotification> mediumNotifications(MediumNotificationsRef ref) {
  return ref.watch(notificationsByPriorityProvider(NotificationPriority.medium));
}

/// Provider for LOW priority notifications (missing images)
@riverpod
List<AppNotification> lowNotifications(LowNotificationsRef ref) {
  return ref.watch(notificationsByPriorityProvider(NotificationPriority.low));
}

/// Provider for notifications related to a specific device
@riverpod
List<AppNotification> deviceNotifications(
  DeviceNotificationsRef ref,
  String deviceId,
) {
  final notifications = ref.watch(deviceNotificationsNotifierProvider);
  
  return notifications.when(
    data: (notificationList) => notificationList
        .where((notification) => notification.deviceId == deviceId)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for notifications related to a specific room
@riverpod
List<AppNotification> roomNotifications(
  RoomNotificationsRef ref,
  String location,
) {
  final notifications = ref.watch(deviceNotificationsNotifierProvider);
  
  return notifications.when(
    data: (notificationList) => notificationList
        .where((notification) => notification.location == location)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}