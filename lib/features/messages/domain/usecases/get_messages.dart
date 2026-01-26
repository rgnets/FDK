import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';

/// Parameters for GetMessages use case
class GetMessagesParams extends Equatable {
  const GetMessagesParams({
    this.type,
    this.category,
    this.unreadOnly,
    this.limit,
    this.offset,
  });

  final MessageType? type;
  final MessageCategory? category;
  final bool? unreadOnly;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [type, category, unreadOnly, limit, offset];
}

/// Use case to get messages from the repository
final class GetMessages extends UseCase<List<AppMessage>, GetMessagesParams> {
  GetMessages(this._repository);

  final MessageRepository _repository;

  @override
  Future<Either<Failure, List<AppMessage>>> call(GetMessagesParams params) {
    return _repository.getMessages(
      type: params.type,
      category: params.category,
      unreadOnly: params.unreadOnly,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
