import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';

final class ClearNotifications extends UseCase<void, ClearNotificationsParams> {

  ClearNotifications(this.repository);
  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(ClearNotificationsParams params) {
    return repository.clearNotifications(filter: params.filter);
  }
}

class ClearNotificationsParams {

  const ClearNotificationsParams({this.filter});
  final NotificationFilter? filter;
}