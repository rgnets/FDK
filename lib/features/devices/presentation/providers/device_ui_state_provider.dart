import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_ui_state_provider.g.dart';

/// UI state for device list filtering and searching
class DeviceUIState {
  const DeviceUIState({
    this.searchQuery = '',
    this.filterType = 'access_point',  // Default to first tab (APs)
    this.isSearching = false,
  });

  final String searchQuery;
  final String filterType;
  final bool isSearching;

  DeviceUIState copyWith({
    String? searchQuery,
    String? filterType,
    bool? isSearching,
  }) {
    return DeviceUIState(
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// Provider for device UI state (search, filters, etc.)
@riverpod
class DeviceUIStateNotifier extends _$DeviceUIStateNotifier {
  @override
  DeviceUIState build() {
    return const DeviceUIState();
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
    state = state.copyWith(
      searchQuery: '',
      isSearching: false,
    );
  }
}

/// Provider for filtered devices based on UI state
@riverpod
List<Device> filteredDevicesList(FilteredDevicesListRef ref) {
  final devices = ref.watch(devicesNotifierProvider);
  final uiState = ref.watch(deviceUIStateNotifierProvider);

  return devices.when(
    data: (deviceList) {
      final filtered = deviceList.where((device) {
        // Filter by type
        final matchesType = uiState.filterType == 'all' || 
                           device.type == uiState.filterType;
        
        // Filter by search query
        final matchesSearch = uiState.searchQuery.isEmpty ||
                             device.name.toLowerCase().contains(uiState.searchQuery.toLowerCase()) ||
                             device.type.toLowerCase().contains(uiState.searchQuery.toLowerCase()) ||
                             (device.location?.toLowerCase().contains(uiState.searchQuery.toLowerCase()) ?? false);
        
        return matchesType && matchesSearch;
      }).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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
      final issues = deviceList.where((d) => d.status == 'warning' || d.status == 'error').length;
      
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
    error: (error, _) => MockDataState(
      isUsingMockData: true,
      apiErrorMessage: error.toString(),
    ),
  );
}

/// State for mock data information
class MockDataState {
  const MockDataState({
    this.isUsingMockData = false,
    this.apiErrorMessage,
  });

  final bool isUsingMockData;
  final String? apiErrorMessage;
}