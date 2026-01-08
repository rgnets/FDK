import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/core/services/notification_generation_service.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';

/// Implementation of NotificationRepository
/// Generates notifications locally from device data (client-side only)
class NotificationRepositoryImpl implements NotificationRepository {
  
  NotificationRepositoryImpl({
    required this.notificationGenerationService,
    required this.deviceRepository,
  });
  final NotificationGenerationService notificationGenerationService;
  final DeviceRepository deviceRepository;
  final _logger = LoggerConfig.getLogger();
  
  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    NotificationFilter? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      // Fetch devices using the device repository
      _logger.d('🔔 NotificationRepository: Fetching devices for notification generation');
      
      final devicesResult = await deviceRepository.getDevices();
      
      final allDevices = devicesResult.fold(
        (failure) {
          _logger.e('Failed to fetch devices: ${failure.message}');
          // If we can't get devices, return empty notifications
          return <Device>[];
        },
        (devices) {
          _logger.d('Fetched ${devices.length} devices for notification generation');
          return devices;
        },
      );
      
      // If using synthetic data and no devices, use mock data
      if (EnvironmentConfig.useSyntheticData && allDevices.isEmpty) {
        _logger.d('Synthetic data mode: Using mock devices');
        final mockDevices = MockDataService().getMockDevices();
        allDevices.addAll(mockDevices);
      }
      
      // Generate notifications from device data
      notificationGenerationService.generateFromDevices(allDevices);
      
      // Get all generated notifications
      var notifications = notificationGenerationService.getAllNotifications()
        // Sort by timestamp (newest first)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply filter if provided
      if (filter != null) {
        notifications = notifications.where(filter.matches).toList();
      }
      
      // Apply pagination
      if (offset != null && offset > 0) {
        notifications = notifications.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        notifications = notifications.take(limit).toList();
      }
      
      return Right(notifications);
    } on Exception catch (e) {
      return Left(NotificationFailure(message: 'Failed to get notifications: $e'));
    }
  }
  
  
  @override
  Future<Either<Failure, AppNotification>> getNotification(String id) async {
    try {
      final result = await getNotifications();
      return result.fold(
        Left.new,
        (notifications) {
          final notification = notifications.firstWhere(
            (n) => n.id == id,
            orElse: () => throw Exception('Notification not found'),
          );
          return Right(notification);
        },
      );
    } on Exception catch (e) {
      return Left(NotificationFailure(message: 'Failed to get notification: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      notificationGenerationService.markAsRead(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(NotificationFailure(message: 'Failed to mark as read: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      notificationGenerationService.markAllAsRead();
      return const Right(null);
    } on Exception catch (e) {
      return Left(NotificationFailure(message: 'Failed to mark all as read: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteNotification(String id) async {
    try {
      notificationGenerationService.deleteNotification(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(NotificationFailure(message: 'Failed to delete notification: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> clearNotifications({NotificationFilter? filter}) async {
    try {
      if (filter == null) {
        notificationGenerationService.clearAllNotifications();
      } else {
        // Clear only filtered notifications - get all, filter, and remove matches
        final notifications = notificationGenerationService.getAllNotifications();
        final toDelete = notifications.where(filter.matches);
        for (final notification in toDelete) {
          notificationGenerationService.deleteNotification(notification.id);
        }
      }
      return const Right(null);
    } on Exception catch (e) {
      return Left(NotificationFailure(message: 'Failed to clear notifications: $e'));
    }
  }
  
  @override
  Future<Either<Failure, int>> getUnreadCount({NotificationFilter? filter}) async {
    try {
      var notifications = notificationGenerationService.getAllNotifications();
      if (filter != null) {
        notifications = notifications.where(filter.matches).toList();
      }
      final unreadCount = notifications.where((n) => !n.isRead).length;
      return Right(unreadCount);
    } on Exception catch (e) {
      return Left(NotificationFailure(message: 'Failed to get unread count: $e'));
    }
  }
  
  @override
  Stream<AppNotification> get notificationStream {
    return notificationGenerationService.notificationStream;
  }
}
