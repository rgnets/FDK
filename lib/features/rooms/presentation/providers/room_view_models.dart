import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/presentation/providers/room_readiness_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_view_models.g.dart';

const String allPhasesRoom = 'All Phases';

class RoomUIState {
  const RoomUIState({
    this.selectedPhase = allPhasesRoom,
  });

  final String selectedPhase;

  bool get isFilteringByPhase => selectedPhase != allPhasesRoom;

  RoomUIState copyWith({
    String? selectedPhase,
  }) {
    return RoomUIState(
      selectedPhase: selectedPhase ?? this.selectedPhase,
    );
  }
}

@riverpod
class RoomUIStateNotifier extends _$RoomUIStateNotifier {
  @override
  RoomUIState build() {
    return const RoomUIState();
  }

  void setPhase(String phase) {
    if (state.selectedPhase == phase) {
      return;
    }
    state = state.copyWith(selectedPhase: phase);
  }

  void clearPhaseFilter() {
    state = state.copyWith(selectedPhase: allPhasesRoom);
  }
}

class RoomViewModel {
  const RoomViewModel({
    required this.room,
    required this.deviceCount,
    required this.onlineDevices,
    required this.status,
    this.devicePhases = const [],
  });

  final Room room;
  final int deviceCount;
  final int onlineDevices;
  final RoomStatus status;
  final List<String> devicePhases;

  String get id => room.id.toString();
  String get name => room.name;
  String? get roomNumber => room.extractedNumber;
  List<String>? get deviceIds => room.deviceIds;
  Map<String, dynamic>? get metadata => room.metadata;

  double get onlinePercentage =>
      deviceCount > 0 ? (onlineDevices / deviceCount) * 100 : 0;

  bool get hasIssues => status == RoomStatus.partial || status == RoomStatus.down;

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

  bool matchesPhase(String selectedPhase) {
    if (selectedPhase == allPhasesRoom) {
      return true;
    }
    if (selectedPhase == 'Unassigned') {
      return devicePhases.isEmpty || devicePhases.any((p) => p.isEmpty);
    }
    return devicePhases.contains(selectedPhase);
  }
}

@riverpod
List<RoomViewModel> roomViewModels(RoomViewModelsRef ref) {
  final roomsAsync = ref.watch(roomsNotifierProvider);
  final devicesAsync = ref.watch(devicesNotifierProvider);
  final readinessAsync = ref.watch(roomReadinessNotifierProvider);

  final readinessMap = <int, RoomReadinessMetrics>{};
  readinessAsync.whenData((metrics) {
    for (final m in metrics) {
      readinessMap[m.roomId] = m;
    }
  });

  return roomsAsync.when(
    data: (rooms) {
      final allDevices = devicesAsync.valueOrNull ?? [];

      return rooms.map((room) {
        final roomDevices = _getDevicesForRoom(room, allDevices);

        final deviceCount = roomDevices.length;
        final onlineDevices = roomDevices
            .where((device) => device.status.toLowerCase() == 'online')
            .length;

        final readinessMetrics = readinessMap[room.id];
        final status = readinessMetrics?.status ?? _deriveStatus(
          deviceCount: deviceCount,
          onlineDevices: onlineDevices,
        );

        final devicePhases = roomDevices
            .map((d) => d.metadata?['phase']?.toString() ?? '')
            .where((p) => p.isNotEmpty)
            .toSet()
            .toList();

        return RoomViewModel(
          room: room,
          deviceCount: deviceCount,
          onlineDevices: onlineDevices,
          status: status,
          devicePhases: devicePhases,
        );
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

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

@riverpod
List<RoomViewModel> filteredRoomViewModels(
  FilteredRoomViewModelsRef ref,
  String filter,
) {
  final viewModels = ref.watch(roomViewModelsProvider);
  final roomUIState = ref.watch(roomUIStateNotifierProvider);

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

  if (roomUIState.isFilteringByPhase) {
    filtered = filtered
        .where((vm) => vm.matchesPhase(roomUIState.selectedPhase))
        .toList();
  }

  filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return filtered;
}

@riverpod
List<String> uniqueRoomPhases(UniqueRoomPhasesRef ref) {
  final viewModels = ref.watch(roomViewModelsProvider);

  final phases = <String>{};
  var hasUnassigned = false;

  for (final vm in viewModels) {
    if (vm.devicePhases.isEmpty) {
      hasUnassigned = true;
    } else {
      phases.addAll(vm.devicePhases);
    }
  }

  final phaseList = phases.toList()..sort();

  if (hasUnassigned) {
    return [allPhasesRoom, 'Unassigned', ...phaseList];
  }

  return [allPhasesRoom, ...phaseList];
}

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

List<Device> _getDevicesForRoom(Room room, List<Device> allDevices) {
  final roomDeviceIds = room.deviceIds ?? [];
  if (roomDeviceIds.isEmpty) {
    return [];
  }

  return allDevices.where((device) => roomDeviceIds.contains(device.id)).toList();
}
