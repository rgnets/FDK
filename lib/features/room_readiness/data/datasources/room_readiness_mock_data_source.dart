import 'dart:async';

import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';

/// Mock data source for room readiness in development mode.
abstract class RoomReadinessMockDataSource {
  /// Get readiness metrics for all rooms.
  Future<List<RoomReadinessMetrics>> getAllRoomReadiness();

  /// Get readiness metrics for a specific room by ID.
  Future<RoomReadinessMetrics?> getRoomReadinessById(int roomId);

  /// Get the overall readiness percentage across all non-empty rooms.
  double getOverallReadinessPercentage();

  /// Get rooms filtered by status.
  List<RoomReadinessMetrics> getRoomsByStatus(RoomStatus status);

  /// Stream of room readiness updates.
  Stream<RoomReadinessUpdate> get readinessUpdates;

  /// Refresh room readiness data.
  Future<void> refresh();
}

/// Implementation of mock data source for room readiness.
class RoomReadinessMockDataSourceImpl implements RoomReadinessMockDataSource {
  RoomReadinessMockDataSourceImpl({
    required this.mockDataService,
    Logger? logger,
  }) : _logger = logger ?? Logger();

  final MockDataService mockDataService;
  final Logger _logger;

  /// Cached mock metrics.
  List<RoomReadinessMetrics>? _cachedMetrics;

  /// Stream controller for readiness updates.
  final _updateController =
      StreamController<RoomReadinessUpdate>.broadcast();

  @override
  Future<List<RoomReadinessMetrics>> getAllRoomReadiness() async {
    _logger.i('RoomReadinessMockDataSource: getAllRoomReadiness() called');

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (_cachedMetrics != null) {
      return _cachedMetrics!;
    }

    _cachedMetrics = _generateMockMetrics();
    return _cachedMetrics!;
  }

  @override
  Future<RoomReadinessMetrics?> getRoomReadinessById(int roomId) async {
    _logger.i('RoomReadinessMockDataSource: getRoomReadinessById($roomId) called');

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final metrics = await getAllRoomReadiness();
    return metrics.where((m) => m.roomId == roomId).firstOrNull;
  }

  @override
  double getOverallReadinessPercentage() {
    if (_cachedMetrics == null || _cachedMetrics!.isEmpty) {
      return 0.0;
    }

    final nonEmptyRooms =
        _cachedMetrics!.where((m) => m.status != RoomStatus.empty).toList();

    if (nonEmptyRooms.isEmpty) {
      return 0.0;
    }

    final readyRooms =
        nonEmptyRooms.where((m) => m.status == RoomStatus.ready).length;
    return (readyRooms / nonEmptyRooms.length) * 100;
  }

  @override
  List<RoomReadinessMetrics> getRoomsByStatus(RoomStatus status) {
    if (_cachedMetrics == null) {
      return [];
    }
    return _cachedMetrics!.where((m) => m.status == status).toList();
  }

  @override
  Stream<RoomReadinessUpdate> get readinessUpdates => _updateController.stream;

  @override
  Future<void> refresh() async {
    _logger.i('RoomReadinessMockDataSource: refresh() called');
    _cachedMetrics = null;
    await getAllRoomReadiness();
  }

  List<RoomReadinessMetrics> _generateMockMetrics() {
    _logger.i('RoomReadinessMockDataSource: Generating mock metrics');

    final now = DateTime.now();

    return [
      // Ready room
      RoomReadinessMetrics(
        roomId: 1,
        roomName: '(North Tower) 101',
        status: RoomStatus.ready,
        totalDevices: 3,
        onlineDevices: 3,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: now,
      ),
      // Ready room
      RoomReadinessMetrics(
        roomId: 2,
        roomName: '(North Tower) 102',
        status: RoomStatus.ready,
        totalDevices: 2,
        onlineDevices: 2,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: now,
      ),
      // Partial room - has warning issues
      RoomReadinessMetrics(
        roomId: 3,
        roomName: '(North Tower) 103',
        status: RoomStatus.partial,
        totalDevices: 4,
        onlineDevices: 4,
        offlineDevices: 0,
        issues: [
          Issue.onboardingIncomplete(
            deviceId: 10,
            deviceName: 'AP-103-1',
            deviceType: 'AP',
            currentStage: 4,
            totalStages: 6,
          ),
        ],
        lastUpdated: now,
      ),
      // Down room - has critical issues
      RoomReadinessMetrics(
        roomId: 4,
        roomName: '(North Tower) 104',
        status: RoomStatus.down,
        totalDevices: 3,
        onlineDevices: 1,
        offlineDevices: 2,
        issues: [
          Issue.deviceOffline(
            deviceId: 15,
            deviceName: 'ONT-104',
            deviceType: 'ONT',
          ),
          Issue.deviceOffline(
            deviceId: 16,
            deviceName: 'AP-104',
            deviceType: 'AP',
          ),
        ],
        lastUpdated: now,
      ),
      // Ready room
      RoomReadinessMetrics(
        roomId: 5,
        roomName: '(South Tower) 201',
        status: RoomStatus.ready,
        totalDevices: 3,
        onlineDevices: 3,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: now,
      ),
      // Partial room - minor issues
      RoomReadinessMetrics(
        roomId: 6,
        roomName: '(South Tower) 202',
        status: RoomStatus.partial,
        totalDevices: 3,
        onlineDevices: 3,
        offlineDevices: 0,
        issues: [
          Issue.missingImages(
            deviceId: 20,
            deviceName: 'ONT-202',
            deviceType: 'ONT',
          ),
        ],
        lastUpdated: now,
      ),
      // Empty room
      RoomReadinessMetrics(
        roomId: 7,
        roomName: '(South Tower) 203',
        status: RoomStatus.empty,
        totalDevices: 0,
        onlineDevices: 0,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: now,
      ),
      // Ready room
      RoomReadinessMetrics(
        roomId: 8,
        roomName: '(South Tower) 204',
        status: RoomStatus.ready,
        totalDevices: 2,
        onlineDevices: 2,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: now,
      ),
    ];
  }
}
