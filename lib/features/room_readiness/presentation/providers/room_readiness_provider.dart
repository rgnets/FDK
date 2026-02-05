import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/usecases/get_all_room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/usecases/get_overall_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/usecases/get_room_readiness_by_id.dart';

part 'room_readiness_provider.g.dart';

/// Provider for room readiness metrics.
@Riverpod(keepAlive: true)
class RoomReadinessNotifier extends _$RoomReadinessNotifier {
  Logger get _logger => LoggerService.getLogger();

  GetAllRoomReadiness get _getAllRoomReadiness =>
      GetAllRoomReadiness(ref.read(roomReadinessRepositoryProvider));

  @override
  Future<List<RoomReadinessMetrics>> build() async {
    _logger.i('RoomReadinessNotifier: build() called');

    try {
      final result = await _getAllRoomReadiness();
      return result.fold(
        (failure) {
          _logger.e('RoomReadinessNotifier: Error - ${failure.message}');
          throw Exception(failure.message);
        },
        (metrics) {
          _logger.i('RoomReadinessNotifier: Got ${metrics.length} metrics');
          return metrics;
        },
      );
    } catch (e, stack) {
      _logger.e('RoomReadinessNotifier: Exception', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Refresh room readiness data.
  Future<void> refresh() async {
    _logger.i('RoomReadinessNotifier: refresh() called');
    ref.invalidateSelf();
  }
}

/// Provider for overall readiness percentage.
@riverpod
class OverallReadinessNotifier extends _$OverallReadinessNotifier {
  Logger get _logger => LoggerService.getLogger();

  GetOverallReadiness get _getOverallReadiness =>
      GetOverallReadiness(ref.read(roomReadinessRepositoryProvider));

  @override
  Future<double> build() async {
    _logger.i('OverallReadinessNotifier: build() called');

    try {
      final result = await _getOverallReadiness();
      return result.fold(
        (failure) {
          _logger.e('OverallReadinessNotifier: Error - ${failure.message}');
          throw Exception(failure.message);
        },
        (percentage) {
          _logger.i('OverallReadinessNotifier: Got $percentage% readiness');
          return percentage;
        },
      );
    } catch (e, stack) {
      _logger.e('OverallReadinessNotifier: Exception', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

/// Provider to get room readiness by ID.
@riverpod
Future<RoomReadinessMetrics?> roomReadinessById(
  RoomReadinessByIdRef ref,
  int roomId,
) async {
  final logger = LoggerService.getLogger();
  logger.i('roomReadinessById: Getting room $roomId');

  final usecase = GetRoomReadinessById(ref.read(roomReadinessRepositoryProvider));
  final result = await usecase(roomId);

  return result.fold(
    (failure) {
      logger.e('roomReadinessById: Error - ${failure.message}');
      return null;
    },
    (metrics) {
      logger.i('roomReadinessById: Got metrics for room $roomId');
      return metrics;
    },
  );
}

/// Provider for room readiness summary statistics.
@riverpod
RoomReadinessSummary roomReadinessSummary(RoomReadinessSummaryRef ref) {
  final metricsAsync = ref.watch(roomReadinessNotifierProvider);

  return metricsAsync.when(
    data: (metrics) {
      final readyRooms =
          metrics.where((m) => m.status == RoomStatus.ready).length;
      final partialRooms =
          metrics.where((m) => m.status == RoomStatus.partial).length;
      final downRooms =
          metrics.where((m) => m.status == RoomStatus.down).length;
      final emptyRooms =
          metrics.where((m) => m.status == RoomStatus.empty).length;
      final nonEmptyRooms = metrics.length - emptyRooms;
      final percentage =
          nonEmptyRooms > 0 ? (readyRooms / nonEmptyRooms) * 100 : 0.0;

      return RoomReadinessSummary(
        totalRooms: metrics.length,
        readyRooms: readyRooms,
        partialRooms: partialRooms,
        downRooms: downRooms,
        emptyRooms: emptyRooms,
        overallReadinessPercentage: percentage,
        lastUpdated: DateTime.now(),
      );
    },
    loading: () => RoomReadinessSummary(
      totalRooms: 0,
      readyRooms: 0,
      partialRooms: 0,
      downRooms: 0,
      emptyRooms: 0,
      overallReadinessPercentage: 0,
      lastUpdated: DateTime.now(),
    ),
    error: (_, __) => RoomReadinessSummary(
      totalRooms: 0,
      readyRooms: 0,
      partialRooms: 0,
      downRooms: 0,
      emptyRooms: 0,
      overallReadinessPercentage: 0,
      lastUpdated: DateTime.now(),
    ),
  );
}

/// Provider for rooms filtered by status.
@riverpod
List<RoomReadinessMetrics> roomsByStatus(
  RoomsByStatusRef ref,
  RoomStatus status,
) {
  final metricsAsync = ref.watch(roomReadinessNotifierProvider);

  return metricsAsync.when(
    data: (metrics) => metrics.where((m) => m.status == status).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for stream of room readiness updates.
@riverpod
Stream<RoomReadinessUpdate> roomReadinessUpdates(
  RoomReadinessUpdatesRef ref,
) {
  final repository = ref.watch(roomReadinessRepositoryProvider);
  return repository.readinessUpdates;
}
