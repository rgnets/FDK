import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';

/// Parameters for MarkMessageAsRead use case
class MarkMessageAsReadParams extends Equatable {
  const MarkMessageAsReadParams({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// Use case to mark a message as read
final class MarkMessageAsRead extends UseCase<void, MarkMessageAsReadParams> {
  MarkMessageAsRead(this._repository);

  final MessageRepository _repository;

  @override
  Future<Either<Failure, void>> call(MarkMessageAsReadParams params) {
    return _repository.markAsRead(params.messageId);
  }
}
