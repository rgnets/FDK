import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';

final class MarkAsRead extends UseCase<void, MarkAsReadParams> {

  MarkAsRead(this.repository);
  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) {
    return repository.markAsRead(params.notificationId);
  }
}

class MarkAsReadParams {

  const MarkAsReadParams({required this.notificationId});
  final String notificationId;
}