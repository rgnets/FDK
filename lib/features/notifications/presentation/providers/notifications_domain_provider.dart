import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/providers/use_case_providers.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/get_notifications.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/mark_as_read.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_domain_provider.g.dart';

/// Main notifications provider using domain layer
@Riverpod(keepAlive: true)
class NotificationsDomainNotifier extends _$NotificationsDomainNotifier {
  static final _logger = LoggerConfig.getLogger();
  
  @override
  Future<List<AppNotification>> build() async {
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('NotificationsProvider: Loading notifications');
    }
    
    try {
      final getNotifications = ref.read(getNotificationsProvider);
      final result = await getNotifications(const GetNotificationsParams());
      
      return result.fold(
        (failure) {
          _logger.e('NotificationsProvider: Failed to load notifications - ${failure.message}');
          throw Exception(failure.message);
        },
        (notifications) {
          if (LoggerConfig.isVerboseLoggingEnabled) {
            _logger.i('NotificationsProvider: Successfully loaded ${notifications.length} notifications');
          }
          return notifications;
        },
      );
    } catch (e, stack) {
      _logger.e('NotificationsProvider: Exception in build(): $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('NotificationsProvider: Refreshing notifications');
    }
    
    ref.invalidateSelf();
  }
  
  Future<void> markAsRead(String id) async {
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('NotificationsProvider: Marking notification as read: $id');
    }
    
    try {
      final markAsRead = ref.read(markAsReadProvider);
      final result = await markAsRead(MarkAsReadParams(notificationId: id));
      
      result.fold(
        (failure) {
          _logger.e('NotificationsProvider: Failed to mark as read: ${failure.message}');
          throw Exception(failure.message);
        },
        (_) {
          // Update local state
          final currentNotifications = state.value ?? [];
          final updatedNotifications = currentNotifications.map((n) {
            if (n.id == id) {
              return AppNotification(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                priority: n.priority,
                timestamp: n.timestamp,
                isRead: true,
                deviceId: n.deviceId,
                location: n.location,
                metadata: n.metadata,
              );
            }
            return n;
          }).toList();
          state = AsyncValue.data(updatedNotifications);
        },
      );
    } catch (e, stack) {
      _logger.e('NotificationsProvider: Exception during markAsRead: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> markAllAsRead() async {
    final markAllAsRead = ref.read(markAllAsReadProvider);
    final result = await markAllAsRead(const NoParams());
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Update local state
        final currentNotifications = state.value ?? [];
        final updatedNotifications = currentNotifications.map((n) => AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          priority: n.priority,
          timestamp: n.timestamp,
          isRead: true,
          deviceId: n.deviceId,
          location: n.location,
          metadata: n.metadata,
        )).toList();
        state = AsyncValue.data(updatedNotifications);
      },
    );
  }
}

/// Provider for unread notification count
@riverpod
Future<int> unreadNotificationCount(UnreadNotificationCountRef ref) async {
  final notifications = ref.watch(notificationsDomainNotifierProvider);
  
  return notifications.when(
    data: (list) => list.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}