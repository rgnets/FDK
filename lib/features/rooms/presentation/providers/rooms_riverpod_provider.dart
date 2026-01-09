import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/models/websocket_events.dart';
import 'package:rgnets_fdk/core/providers/use_case_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rooms_riverpod_provider.g.dart';

@Riverpod(keepAlive: true)
class RoomsNotifier extends _$RoomsNotifier {
  static final _logger = LoggerConfig.getLogger();

  /// Internal Map for O(1) lookups/updates
  final Map<String, Room> _byId = {};

  @override
  Future<List<Room>> build() async {
    // Listen to WebSocket room events for real-time updates
    if (EnvironmentConfig.useWebSockets) {
      ref.listen(webSocketRoomEventsProvider, (_, next) {
        next.whenData(_handleRoomEvent);
      });
    }

    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('RoomsProvider: Loading rooms');
    }

    try {
      final getRooms = ref.read(getRoomsProvider);
      final result = await getRooms();

      return result.fold(
        (failure) {
          _logger.e('RoomsProvider: Failed to load rooms - ${failure.message}');
          throw Exception(failure.message);
        },
        (rooms) {
          if (LoggerConfig.isVerboseLoggingEnabled) {
            _logger.i('RoomsProvider: Successfully loaded ${rooms.length} rooms');
          }
          // Initialize internal map
          _byId
            ..clear()
            ..addAll({for (final r in rooms) r.id: r});
          return _byId.values.toList();
        },
      );
    } on Exception catch (e, stack) {
      _logger.e(
        'RoomsProvider: Exception in build(): $e',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  // ===========================================================================
  // WebSocket Event Handlers (O(1) dispatch via Freezed .when())
  // ===========================================================================

  /// Handle room events from WebSocket with O(1) dispatch
  void _handleRoomEvent(RoomEvent event) {
    event.when(
      created: _addRoom,
      updated: _updateRoom,
      deleted: _removeRoom,
      batchUpdate: _updateMultiple,
      snapshot: _handleSnapshot,
    );
  }

  /// O(1) add a new room
  void _addRoom(Room room) {
    _byId[room.id] = room;
    _emitList();
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.d('RoomsProvider: Added room ${room.id}');
    }
  }

  /// O(1) update an existing room
  void _updateRoom(Room room) {
    _byId[room.id] = room;
    _emitList();
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.d('RoomsProvider: Updated room ${room.id}');
    }
  }

  /// O(1) remove a room
  void _removeRoom(String id) {
    _byId.remove(id);
    _emitList();
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.d('RoomsProvider: Removed room $id');
    }
  }

  /// Batch update multiple rooms (O(n) but single emit)
  void _updateMultiple(List<Room> rooms) {
    for (final r in rooms) {
      _byId[r.id] = r;
    }
    _emitList();
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.d('RoomsProvider: Batch updated ${rooms.length} rooms');
    }
  }

  /// Handle full snapshot (replace all)
  void _handleSnapshot(List<Room> rooms) {
    _byId
      ..clear()
      ..addAll({for (final r in rooms) r.id: r});
    _emitList();
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.d('RoomsProvider: Snapshot received with ${rooms.length} rooms');
    }
  }

  /// Emit the current map as a list to UI
  void _emitList() {
    if (state.hasValue) {
      state = AsyncValue.data(_byId.values.toList());
    }
  }

  // ===========================================================================
  // Public API
  // ===========================================================================

  Future<void> refresh() async {
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('RoomsProvider: Refreshing rooms');
    }

    ref.invalidateSelf();
  }
}

/// Provider for room statistics
@riverpod
RoomStatistics roomStatistics(RoomStatisticsRef ref) {
  final rooms = ref.watch(roomsNotifierProvider);
  final devices = ref.watch(devicesNotifierProvider);

  return rooms.when(
    data: (roomList) {
      final total = roomList.length;

      final deviceList = devices.valueOrNull ?? <Device>[];
      final devicesById = <String, Device>{
        for (final device in deviceList) device.id: device,
      };

      var totalDevices = 0;
      var onlineDevices = 0;
      var roomsWithIssues = 0;

      for (final room in roomList) {
        final roomDeviceIds = room.deviceIds ?? <String>[];
        final roomDevices = roomDeviceIds
            .map((id) => devicesById[id])
            .whereType<Device>()
            .toList();
        totalDevices += roomDevices.length;

        final roomOnlineDevices = roomDevices.where((d) => d.isOnline).length;
        onlineDevices += roomOnlineDevices;

        if (roomDevices.any((d) => d.hasIssue || d.isOffline)) {
          roomsWithIssues++;
        }
      }

      return RoomStatistics(
        total: total,
        totalDevices: totalDevices,
        onlineDevices: onlineDevices,
        roomsWithIssues: roomsWithIssues,
      );
    },
    loading: () => const RoomStatistics(),
    error: (_, __) => const RoomStatistics(),
  );
}

/// Room statistics class
class RoomStatistics {
  const RoomStatistics({
    this.total = 0,
    this.totalDevices = 0,
    this.onlineDevices = 0,
    this.roomsWithIssues = 0,
  });

  final int total;
  final int totalDevices;
  final int onlineDevices;
  final int roomsWithIssues;
}

/// Provider for getting a specific room by ID
@riverpod
Room? roomById(RoomByIdRef ref, String roomId) {
  final rooms = ref.watch(roomsNotifierProvider);
  
  return rooms.when(
    data: (roomList) {
      final matchingRooms = roomList.where((room) => room.id == roomId);
      return matchingRooms.isNotEmpty ? matchingRooms.first : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
}