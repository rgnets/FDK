import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/repositories/room_readiness_repository.dart';

/// Use case to get readiness metrics for all rooms
final class GetAllRoomReadiness
    extends UseCaseNoParams<List<RoomReadinessMetrics>> {
  GetAllRoomReadiness(this.repository);

  final RoomReadinessRepository repository;

  @override
  Future<Either<Failure, List<RoomReadinessMetrics>>> call() async {
    return repository.getAllRoomReadiness();
  }
}
