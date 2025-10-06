import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';

final class GetUnreadCount extends UseCase<int, GetUnreadCountParams> {

  GetUnreadCount(this.repository);
  final NotificationRepository repository;

  @override
  Future<Either<Failure, int>> call(GetUnreadCountParams params) {
    return repository.getUnreadCount(filter: params.filter);
  }
}

class GetUnreadCountParams {

  const GetUnreadCountParams({this.filter});
  final NotificationFilter? filter;
}