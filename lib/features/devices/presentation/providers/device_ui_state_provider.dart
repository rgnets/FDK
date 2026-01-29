import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/phase_filter_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/room_filter_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/status_filter_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_ui_state_provider.g.dart';

/// UI state for device list filtering and searching
class DeviceUIState {
  const DeviceUIState({
    this.searchQuery = '',
    this.filterType = 'access_point', // Default to first tab (APs)
    this.isSearching = false,
    this.selectedPhase = PhaseFilterState.allPhases,
    this.selectedStatus = StatusFilterState.allStatuses,
    this.selectedRoom = RoomFilterState.allRooms,
  });

  final String searchQuery;
  final String filterType;
  final bool isSearching;
  final String selectedPhase;
  final String selectedStatus;
  final String selectedRoom;

  /// Returns true if phase filtering is active
  bool get isPhaseFiltering => selectedPhase != PhaseFilterState.allPhases;

  /// Returns true if status filtering is active
  bool get isStatusFiltering => selectedStatus != StatusFilterState.allStatuses;

  /// Returns true if room filtering is active
  bool get isRoomFiltering => selectedRoom != RoomFilterState.allRooms;

  DeviceUIState copyWith({
    String? searchQuery,
    String? filterType,
    bool? isSearching,
    String? selectedPhase,
    String? selectedStatus,
    String? selectedRoom,
  }) {
    return DeviceUIState(
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      isSearching: isSearching ?? this.isSearching,
      selectedPhase: selectedPhase ?? this.selectedPhase,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedRoom: selectedRoom ?? this.selectedRoom,
    );
  }
}

/// Provider for device UI state (search, filters, etc.)
@riverpod
class DeviceUIStateNotifier extends _$DeviceUIStateNotifier {
  @override
  DeviceUIState build() {
    // Listen to phase filter changes and update only selectedPhase
    ref.listen<PhaseFilterState>(phaseFilterNotifierProvider, (previous, next) {
      if (previous?.selectedPhase != next.selectedPhase) {
        state = state.copyWith(selectedPhase: next.selectedPhase);
      }
    });

    // Listen to status filter changes and update only selectedStatus
    ref.listen<StatusFilterState>(statusFilterNotifierProvider, (
      previous,
      next,
    ) {
      if (previous?.selectedStatus != next.selectedStatus) {
        state = state.copyWith(selectedStatus: next.selectedStatus);
      }
    });

    // Listen to room filter changes and update only selectedRoom
    ref.listen<RoomFilterState>(roomFilterNotifierProvider, (previous, next) {
      if (previous?.selectedRoom != next.selectedRoom) {
        state = state.copyWith(selectedRoom: next.selectedRoom);
      }
    });

    // Initialize with current filter states
    final phaseState = ref.read(phaseFilterNotifierProvider);
    final statusState = ref.read(statusFilterNotifierProvider);
    final roomState = ref.read(roomFilterNotifierProvider);
    return DeviceUIState(
      selectedPhase: phaseState.selectedPhase,
      selectedStatus: statusState.selectedStatus,
      selectedRoom: roomState.selectedRoom,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterType(String type) {
    state = state.copyWith(filterType: type);
  }

  void setSearching({required bool isSearching}) {
    state = state.copyWith(isSearching: isSearching);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', isSearching: false);
  }

  void setPhaseFilter(String phase) {
    // Update both local state and the phase filter provider (for persistence)
    state = state.copyWith(selectedPhase: phase);
    ref.read(phaseFilterNotifierProvider.notifier).setPhase(phase);
  }

  void clearPhaseFilter() {
    setPhaseFilter(PhaseFilterState.allPhases);
  }

  void setStatusFilter(String status) {
    // Update both local state and the status filter provider (for persistence)
    state = state.copyWith(selectedStatus: status);
    ref.read(statusFilterNotifierProvider.notifier).setStatus(status);
  }

  void clearStatusFilter() {
    setStatusFilter(StatusFilterState.allStatuses);
  }

  void setRoomFilter(String room) {
    // Update both local state and the room filter provider (for persistence)
    state = state.copyWith(selectedRoom: room);
    ref.read(roomFilterNotifierProvider.notifier).setRoom(room);
  }

  void clearRoomFilter() {
    setRoomFilter(RoomFilterState.allRooms);
  }
}

/// Provider for filtered devices based on UI state
@riverpod
List<Device> filteredDevicesList(FilteredDevicesListRef ref) {
  final devices = ref.watch(devicesNotifierProvider);
  final uiState = ref.watch(deviceUIStateNotifierProvider);
  final phaseFilter = ref.watch(phaseFilterNotifierProvider);
  final statusFilter = ref.watch(statusFilterNotifierProvider);
  final roomFilter = ref.watch(roomFilterNotifierProvider);
  final roomsAsync = ref.watch(roomsNotifierProvider);

  return devices.when(
    data: (deviceList) {
      // Precompute search query once (trimmed and lowercased)
      final query = uiState.searchQuery.trim().toLowerCase();

      // Get the selected room's ID for matching by ID (more reliable than name)
      int? selectedRoomId;
      if (roomFilter.isFiltering) {
        final selectedRoomName = roomFilter.selectedRoom.trim().toLowerCase();
        roomsAsync.whenData((roomList) {
          for (final room in roomList) {
            if (room.name.trim().toLowerCase() == selectedRoomName) {
              selectedRoomId = room.id;
              break;
            }
          }
        });
      }

      final filtered =
          deviceList.where((device) {
            // Filter by type
            final matchesType =
                uiState.filterType == 'all' ||
                device.type == uiState.filterType;

            // Filter by search query (name, type, location, IP, MAC)
            final matchesSearch =
                query.isEmpty ||
                device.name.toLowerCase().contains(query) ||
                device.type.toLowerCase().contains(query) ||
                (device.location?.toLowerCase().contains(query) ?? false) ||
                (device.ipAddress?.toLowerCase().contains(query) ?? false) ||
                (device.macAddress?.toLowerCase().contains(query) ?? false);

            // Filter by phase (using metadata) - handle both String and int types
            final rawPhase = device.metadata?['phase'];
            final devicePhase = rawPhase?.toString();
            final matchesPhase = phaseFilter.matchesFilter(devicePhase);

            // Filter by status
            final matchesStatus = statusFilter.matchesFilter(device.status);

            // Filter by room - match by ID (pmsRoomId) for reliability
            bool matchesRoom;
            if (!roomFilter.isFiltering) {
              matchesRoom = true; // Show all when not filtering
            } else if (selectedRoomId != null) {
              // Match by room ID
              matchesRoom = device.pmsRoomId == selectedRoomId;
            } else {
              // Fallback to name matching if room ID lookup failed
              final deviceRoom = device.pmsRoom?.name ?? device.location;
              matchesRoom = roomFilter.matchesFilter(deviceRoom);
            }

            return matchesType &&
                matchesSearch &&
                matchesPhase &&
                matchesStatus &&
                matchesRoom;
          }).toList()..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for device statistics
@riverpod
DeviceStatistics deviceStatistics(DeviceStatisticsRef ref) {
  final devices = ref.watch(devicesNotifierProvider);

  return devices.when(
    data: (deviceList) {
      final total = deviceList.length;
      final online = deviceList.where((d) => d.status == 'online').length;
      final offline = deviceList.where((d) => d.status == 'offline').length;
      final issues = deviceList
          .where((d) => d.status == 'warning' || d.status == 'error')
          .length;

      return DeviceStatistics(
        total: total,
        online: online,
        offline: offline,
        issues: issues,
      );
    },
    loading: () => const DeviceStatistics(),
    error: (_, __) => const DeviceStatistics(),
  );
}

/// Statistics for devices
class DeviceStatistics {
  const DeviceStatistics({
    this.total = 0,
    this.online = 0,
    this.offline = 0,
    this.issues = 0,
  });

  final int total;
  final int online;
  final int offline;
  final int issues;
}

/// Provider to check if using mock data and error messages
@riverpod
MockDataState mockDataState(MockDataStateRef ref) {
  final devices = ref.watch(devicesNotifierProvider);

  return devices.when(
    data: (_) => const MockDataState(isUsingMockData: false),
    loading: () => const MockDataState(isUsingMockData: false),
    error: (error, _) =>
        MockDataState(isUsingMockData: true, apiErrorMessage: error.toString()),
  );
}

/// State for mock data information
class MockDataState {
  const MockDataState({this.isUsingMockData = false, this.apiErrorMessage});

  final bool isUsingMockData;
  final String? apiErrorMessage;
}

/// Provider for available phases based on all devices
@riverpod
List<String> devicePhases(DevicePhasesRef ref) {
  final devices = ref.watch(devicesNotifierProvider);

  return devices.when(
    data: PhaseFilterState.getUniquePhasesFromDevices,
    loading: () => [PhaseFilterState.allPhases],
    error: (_, __) => [PhaseFilterState.allPhases],
  );
}
