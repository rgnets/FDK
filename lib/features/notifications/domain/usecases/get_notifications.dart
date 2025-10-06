import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';

final class GetNotifications extends UseCase<List<AppNotification>, GetNotificationsParams> {

  GetNotifications(this.repository);
  final NotificationRepository repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call(GetNotificationsParams params) {
    return repository.getNotifications(
      filter: params.filter,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetNotificationsParams {

  const GetNotificationsParams({
    this.filter,
    this.limit,
    this.offset,
  });
  final NotificationFilter? filter;
  final int? limit;
  final int? offset;
}