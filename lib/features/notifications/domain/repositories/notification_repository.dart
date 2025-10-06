import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    NotificationFilter? filter,
    int? limit,
    int? offset,
  });
  
  Future<Either<Failure, AppNotification>> getNotification(String id);
  
  Future<Either<Failure, void>> markAsRead(String id);
  
  Future<Either<Failure, void>> markAllAsRead();
  
  Future<Either<Failure, void>> deleteNotification(String id);
  
  Future<Either<Failure, void>> clearNotifications({
    NotificationFilter? filter,
  });
  
  Future<Either<Failure, int>> getUnreadCount({
    NotificationFilter? filter,
  });
  
  Stream<AppNotification> get notificationStream;
}