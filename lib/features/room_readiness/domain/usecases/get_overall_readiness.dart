import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/repositories/room_readiness_repository.dart';

/// Use case to get the overall readiness percentage across all non-empty rooms
final class GetOverallReadiness extends UseCaseNoParams<double> {
  GetOverallReadiness(this.repository);

  final RoomReadinessRepository repository;

  @override
  Future<Either<Failure, double>> call() async {
    return repository.getOverallReadinessPercentage();
  }
}
