import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';

/// Repository interface for room readiness operations
abstract class RoomReadinessRepository {
  /// Get readiness metrics for all rooms
  Future<Either<Failure, List<RoomReadinessMetrics>>> getAllRoomReadiness();

  /// Get readiness metrics for a specific room by ID
  Future<Either<Failure, RoomReadinessMetrics>> getRoomReadinessById(
    int roomId,
  );

  /// Get the overall readiness percentage across all non-empty rooms
  Future<Either<Failure, double>> getOverallReadinessPercentage();

  /// Get rooms filtered by status
  Future<Either<Failure, List<RoomReadinessMetrics>>> getRoomsByStatus(
    RoomStatus status,
  );

  /// Stream of room readiness updates for real-time monitoring
  Stream<RoomReadinessUpdate> get readinessUpdates;

  /// Refresh room readiness data
  Future<Either<Failure, void>> refresh();

  /// Dispose resources
  void dispose();
}
