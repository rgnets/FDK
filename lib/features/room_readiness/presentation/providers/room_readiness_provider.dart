import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_failures_aggregate_provider.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';
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

    // Spec B5 / TR-7: compliance failures plumb into per-AP room_readiness
    // issues using widgets that already exist. No new "Compliance" screen.
    // When the rxg has failure rows for an AP (e.g. "FDK Missing Installation
    // Images"), we attach `Issue.missingImages` / `Issue.missingSpeedTest`
    // to the room containing that AP, matched by AP id.
    //
    // User override (slice 5, 2026-05-14): per-rule `unknown` / `indeterminate`
    // / `loading` / `error` / `compliant` states intentionally render NOTHING
    // visually here. The earlier synthetic-HealthNotice meta-banners ("Installation
    // status not yet captured") were reverted at the user's direction — they
    // were confusing alongside the actual failure rows the rxg admin view shows.
    // Only the `failures([list])` variant of `ComplianceFeedState` contributes
    // issues; everything else is a no-op. This is contrary to spec §5 lines
    // 255–256's banner copy and is a deliberate deviation.
    final complianceFailures = ref.watch(complianceFailuresAggregateProvider);

    try {
      final result = await _getAllRoomReadiness();
      return result.fold(
        (failure) {
          _logger.e('RoomReadinessNotifier: Error - ${failure.message}');
          throw Exception(failure.message);
        },
        (metrics) {
          _logger.i('RoomReadinessNotifier: Got ${metrics.length} metrics');
          return _attachComplianceIssues(metrics, complianceFailures);
        },
      );
    } catch (e, stack) {
      _logger.e('RoomReadinessNotifier: Exception', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Walks each room's device list and, for each AP id matching a
  /// `ComplianceFailure`, appends the corresponding `Issue.missingImages`
  /// or `Issue.missingSpeedTest` to that room's issues. Room status is
  /// recomputed if the new issues add up to non-empty.
  ///
  /// Matching is by AP `deviceId` (the integer rxg PK). The data source's
  /// device-issue list already names devices by their numeric id under the
  /// `metadata['deviceId']` key on existing `Issue` rows, so the same id
  /// space lines up cleanly here. Rooms whose `metadata['deviceId']` is
  /// missing (corner-case empty rooms or unbuilt entries) simply receive no
  /// compliance issue.
  List<RoomReadinessMetrics> _attachComplianceIssues(
    List<RoomReadinessMetrics> metrics,
    List<ComplianceFailure> failures,
  ) {
    if (failures.isEmpty) {
      return metrics;
    }

    // Group failures by AP id for O(rooms * apsInRoom) injection rather
    // than O(rooms * apsInRoom * failures).
    final byApId = <int, List<ComplianceFailure>>{};
    for (final f in failures) {
      if (f.deviceType != 'access_point') {
        continue;
      }
      byApId.putIfAbsent(f.deviceId, () => <ComplianceFailure>[]).add(f);
    }
    if (byApId.isEmpty) {
      return metrics;
    }

    return metrics
        .map((m) => _injectIssuesForRoom(m, byApId))
        .toList(growable: false);
  }

  RoomReadinessMetrics _injectIssuesForRoom(
    RoomReadinessMetrics room,
    Map<int, List<ComplianceFailure>> byApId,
  ) {
    if (room.accessPointIds.isEmpty) {
      return room;
    }
    final extras = <Issue>[];
    for (final id in room.accessPointIds) {
      final apFailures = byApId[id];
      if (apFailures == null) {
        continue;
      }
      for (final f in apFailures) {
        if (f.ruleName == ComplianceNames.imagesRule) {
          extras.add(Issue.missingImages(
            deviceId: f.deviceId,
            deviceName: f.deviceName,
            deviceType: 'AP',
            detectedAt: f.checkedAt,
          ));
        } else if (f.ruleName == ComplianceNames.speedTestRule) {
          extras.add(Issue.missingSpeedTest(
            deviceId: f.deviceId,
            deviceName: f.deviceName,
            detectedAt: f.checkedAt,
          ));
        }
      }
    }
    if (extras.isEmpty) {
      return room;
    }
    final newIssues = [...room.issues, ...extras];
    // If the room was `ready` and now has issues, it transitions to
    // `partial`. `down` / `empty` remain unchanged: critical issues or
    // zero-device rooms aren't downgraded by an informational compliance
    // issue.
    final newStatus = (room.status == RoomStatus.ready)
        ? RoomStatus.partial
        : room.status;
    return room.copyWith(issues: newIssues, status: newStatus);
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
