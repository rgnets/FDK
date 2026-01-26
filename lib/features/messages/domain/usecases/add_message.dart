import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';

/// Parameters for AddMessage use case
class AddMessageParams extends Equatable {
  const AddMessageParams({required this.message});

  final AppMessage message;

  @override
  List<Object?> get props => [message];
}

/// Use case to add a new message
final class AddMessage extends UseCase<AppMessage, AddMessageParams> {
  AddMessage(this._repository);

  final MessageRepository _repository;

  @override
  Future<Either<Failure, AppMessage>> call(AddMessageParams params) {
    return _repository.addMessage(params.message);
  }
}
