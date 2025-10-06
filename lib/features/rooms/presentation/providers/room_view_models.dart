import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_view_models.g.dart';

/// View model for room display information
class RoomViewModel {
  RoomViewModel({
    required this.room,
    required this.deviceCount,
    required this.onlineDevices,
  });

  final Room room;
  final int deviceCount;
  final int onlineDevices;

  String get id => room.id;
  String get name => room.name;
  String? get roomNumber => room.roomNumber;
  List<String>? get deviceIds => room.deviceIds;
  Map<String, dynamic>? get metadata => room.metadata;

  double get onlinePercentage =>
      deviceCount > 0 ? (onlineDevices / deviceCount) * 100 : 0;

  bool get hasIssues => onlineDevices < deviceCount;
}

/// Provider for room view models with display information
@riverpod
List<RoomViewModel> roomViewModels(RoomViewModelsRef ref) {
  final roomsAsync = ref.watch(roomsNotifierProvider);
  final devicesAsync = ref.watch(devicesNotifierProvider);

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

        return RoomViewModel(
          room: room,
          deviceCount: deviceCount,
          onlineDevices: onlineDevices,
        );
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
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

  List<RoomViewModel> filtered;
  switch (filter) {
    case 'ready':
      filtered = viewModels.where((vm) => !vm.hasIssues).toList();
      break;
    case 'issues':
      filtered = viewModels.where((vm) => vm.hasIssues).toList();
      break;
    default:
      filtered = List.from(viewModels);
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
  final ready = viewModels.where((vm) => !vm.hasIssues).length;
  final withIssues = viewModels.where((vm) => vm.hasIssues).length;

  return RoomStats(
    total: total,
    ready: ready,
    withIssues: withIssues,
  );
}

/// Statistics for rooms display
class RoomStats {
  const RoomStats({
    required this.total,
    required this.ready,
    required this.withIssues,
  });

  final int total;
  final int ready;
  final int withIssues;
}

/// Private helper to get devices for a room using unified approach
/// Matches devices by pmsRoomId (consistent for both mock and API data)
List<Device> _getDevicesForRoom(Room room, List<Device> allDevices) {
  // Parse room ID as integer for pmsRoomId matching
  final roomIdInt = int.tryParse(room.id);
  if (roomIdInt != null) {
    // Filter devices where pmsRoomId matches the room's numeric ID
    return allDevices.where((device) => device.pmsRoomId == roomIdInt).toList();
  }
  
  // No devices found for non-numeric room IDs
  return [];
}