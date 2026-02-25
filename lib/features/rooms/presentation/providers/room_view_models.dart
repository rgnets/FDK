import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/presentation/providers/room_readiness_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_ui_state_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_view_models.g.dart';

/// View model for room display information
class RoomViewModel {
  RoomViewModel({
    required this.room,
    required this.deviceCount,
    required this.onlineDevices,
    required this.status,
  });

  final Room room;
  final int deviceCount;
  final int onlineDevices;
  final RoomStatus status;

  String get id => room.id.toString();
  String get name => room.name;
  String? get roomNumber => room.extractedNumber;
  List<String>? get deviceIds => room.deviceIds;
  Map<String, dynamic>? get metadata => room.metadata;

  double get onlinePercentage =>
      deviceCount > 0 ? (onlineDevices / deviceCount) * 100 : 0;

  /// Returns true if room has issues (partial or down status)
  bool get hasIssues => status == RoomStatus.partial || status == RoomStatus.down;

  /// Returns the display text for the room status
  String get statusText {
    switch (status) {
      case RoomStatus.ready:
        return 'Ready';
      case RoomStatus.partial:
        return 'Partial';
      case RoomStatus.down:
        return 'Down';
      case RoomStatus.empty:
        return 'Empty';
    }
  }
}

/// Provider for room view models with display information
@riverpod
List<RoomViewModel> roomViewModels(RoomViewModelsRef ref) {
  final roomsAsync = ref.watch(roomsNotifierProvider);
  final devicesAsync = ref.watch(devicesNotifierProvider);
  final readinessAsync = ref.watch(roomReadinessNotifierProvider);

  // Build a map of room ID to readiness metrics for efficient lookup
  final readinessMap = <int, RoomReadinessMetrics>{};
  readinessAsync.whenData((metrics) {
    for (final m in metrics) {
      readinessMap[m.roomId] = m;
    }
  });

  return roomsAsync.when(
    data: (rooms) {
      // Get all devices or empty list if loading/error
      final allDevices = devicesAsync.valueOrNull ?? [];

      return rooms.map((room) {
        // Get devices for this room using consolidated logic
        final roomDevices = _getDevicesForRoom(room, allDevices);

        // Calculate stats
        final deviceCount = roomDevices.length;
        final onlineDevices = roomDevices
            .where((device) => device.status.toLowerCase() == 'online')
            .length;

        // Get status from readiness metrics, or derive from device counts
        final readinessMetrics = readinessMap[room.id];
        final status = readinessMetrics?.status ?? _deriveStatus(
          deviceCount: deviceCount,
          onlineDevices: onlineDevices,
        );

        return RoomViewModel(
          room: room,
          deviceCount: deviceCount,
          onlineDevices: onlineDevices,
          status: status,
        );
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Derive RoomStatus from device counts when readiness data is unavailable
RoomStatus _deriveStatus({
  required int deviceCount,
  required int onlineDevices,
}) {
  if (deviceCount == 0) {
    return RoomStatus.empty;
  }
  if (onlineDevices == 0) {
    return RoomStatus.down;
  }
  if (onlineDevices < deviceCount) {
    return RoomStatus.partial;
  }
  return RoomStatus.ready;
}

/// Provider for a single room view model by ID
@riverpod
RoomViewModel? roomViewModelById(RoomViewModelByIdRef ref, String roomId) {
  final viewModels = ref.watch(roomViewModelsProvider);
  
  for (final vm in viewModels) {
    if (vm.id == roomId) {
      return vm;
    }
  }
  return null;
}

/// Provider for filtered room view models
@riverpod
List<RoomViewModel> filteredRoomViewModels(
  FilteredRoomViewModelsRef ref,
  String filter,
) {
  final viewModels = ref.watch(roomViewModelsProvider);
  final uiState = ref.watch(roomUIStateNotifierProvider);
  final searchQuery = uiState.searchQuery.toLowerCase();

  List<RoomViewModel> filtered;
  switch (filter) {
    case 'ready':
      filtered = viewModels.where((vm) => vm.status == RoomStatus.ready).toList();
      break;
    case 'issues':
      filtered = viewModels.where((vm) => vm.hasIssues).toList();
      break;
    case 'partial':
      filtered = viewModels.where((vm) => vm.status == RoomStatus.partial).toList();
      break;
    case 'down':
      filtered = viewModels.where((vm) => vm.status == RoomStatus.down).toList();
      break;
    case 'empty':
      filtered = viewModels.where((vm) => vm.status == RoomStatus.empty).toList();
      break;
    default:
      filtered = List.from(viewModels);
  }

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((vm) {
      return vm.name.toLowerCase().contains(searchQuery) ||
          (vm.roomNumber?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  // Sort by room name alphabetically
  filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return filtered;
}

/// Provider for room statistics based on view models
@riverpod
RoomStats roomStats(RoomStatsRef ref) {
  final viewModels = ref.watch(roomViewModelsProvider);

  final total = viewModels.length;
  final ready = viewModels.where((vm) => vm.status == RoomStatus.ready).length;
  final partial = viewModels.where((vm) => vm.status == RoomStatus.partial).length;
  final down = viewModels.where((vm) => vm.status == RoomStatus.down).length;
  final empty = viewModels.where((vm) => vm.status == RoomStatus.empty).length;
  final withIssues = partial + down;

  return RoomStats(
    total: total,
    ready: ready,
    withIssues: withIssues,
    partial: partial,
    down: down,
    empty: empty,
  );
}

/// Statistics for rooms display
class RoomStats {
  const RoomStats({
    required this.total,
    required this.ready,
    required this.withIssues,
    required this.partial,
    required this.down,
    required this.empty,
  });

  final int total;
  final int ready;
  final int withIssues;
  final int partial;
  final int down;
  final int empty;
}

/// Private helper to get devices for a room using unified approach.
/// Matches devices by pmsRoomId first, then falls back to the room's
/// deviceIds list (populated from switch_ports/switch_devices in room data).
/// This ensures switches are included even when they lack a direct pms_room_id.
List<Device> _getDevicesForRoom(Room room, List<Device> allDevices) {
  final deviceIdSet = room.deviceIds?.toSet();
  return allDevices.where((device) {
    if (device.pmsRoomId == room.id) return true;
    if (deviceIdSet != null && deviceIdSet.contains(device.id)) return true;
    return false;
  }).toList();
}
