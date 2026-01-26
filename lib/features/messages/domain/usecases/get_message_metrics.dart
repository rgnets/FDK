import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';

/// Use case to get message metrics
final class GetMessageMetrics extends UseCaseNoParams<MessageMetrics> {
  GetMessageMetrics(this._repository);

  final MessageRepository _repository;

  @override
  Future<Either<Failure, MessageMetrics>> call() {
    return _repository.getMetrics();
  }
}
