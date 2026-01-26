import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';

/// Use case to clear all messages
final class ClearMessages extends UseCaseNoParams<void> {
  ClearMessages(this._repository);

  final MessageRepository _repository;

  @override
  Future<Either<Failure, void>> call() {
    return _repository.clearMessages();
  }
}
