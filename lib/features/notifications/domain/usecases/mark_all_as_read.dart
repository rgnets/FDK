import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';

final class MarkAllAsRead extends UseCase<void, NoParams> {

  MarkAllAsRead(this.repository);
  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.markAllAsRead();
  }
}