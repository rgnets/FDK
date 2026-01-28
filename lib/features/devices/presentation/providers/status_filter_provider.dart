import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status_filter_provider.g.dart';

/// State for device status filtering
class StatusFilterState {
  const StatusFilterState({this.selectedStatus = allStatuses});

  /// Special value indicating no filter (show all statuses)
  static const String allStatuses = 'All Statuses';

  /// Currently selected status filter
  final String selectedStatus;

  /// Returns true if actively filtering (not showing all)
  bool get isFiltering => selectedStatus != allStatuses;

  /// Check if a device's status matches the current filter
  bool matchesFilter(String? deviceStatus) {
    if (!isFiltering) {
      return true; // Show all when not filtering
    }

    if (deviceStatus == null || deviceStatus.trim().isEmpty) {
      return false; // No match for null/empty status when filtering
    }

    return deviceStatus.trim().toLowerCase() == selectedStatus.toLowerCase();
  }

  /// Create a copy with updated values
  StatusFilterState copyWith({String? selectedStatus}) {
    return StatusFilterState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }

  /// Extract unique statuses from a list of devices
  /// Returns sorted list with "All Statuses" as first option
  /// Sorted in priority order: online, offline, warning, error, then alphabetical
  static List<String> getUniqueStatusesFromDevices(List<Device> devices) {
    final statuses = <String>{};

    for (final device in devices) {
      final status = device.status.trim();
      if (status.isNotEmpty) {
        statuses.add(status.toLowerCase());
      }
    }

    // Sort with online first, then offline, then warning/error, then others
    final statusList = statuses.toList()
      ..sort((a, b) {
        const order = ['online', 'offline', 'warning', 'error'];
        final aIndex = order.indexOf(a);
        final bIndex = order.indexOf(b);
        if (aIndex >= 0 && bIndex >= 0) {
          return aIndex.compareTo(bIndex);
        }
        if (aIndex >= 0) {
          return -1;
        }
        if (bIndex >= 0) {
          return 1;
        }
        return a.compareTo(b);
      });

    return [allStatuses, ...statusList];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusFilterState &&
          runtimeType == other.runtimeType &&
          selectedStatus == other.selectedStatus;

  @override
  int get hashCode => selectedStatus.hashCode;
}

/// Notifier for managing status filter state with persistence
@riverpod
class StatusFilterNotifier extends _$StatusFilterNotifier {
  StorageService? _storageService;

  @override
  StatusFilterState build() {
    // Try to get storage service from provider
    try {
      _storageService = ref.watch(storageServiceProvider);
    } on Object {
      // Storage service not available yet (e.g., during tests without override)
      _storageService = null;
    }

    // Load saved status synchronously from storage
    final savedStatus = _storageService?.statusFilter;
    if (savedStatus != null && savedStatus.isNotEmpty) {
      return StatusFilterState(selectedStatus: savedStatus);
    }
    return const StatusFilterState();
  }

  /// Set the selected status filter
  void setStatus(String status) {
    if (state.selectedStatus == status) {
      return;
    }
    state = state.copyWith(selectedStatus: status);
    _saveStatus(status);
  }

  /// Clear the filter (set to All Statuses)
  void clear() {
    setStatus(StatusFilterState.allStatuses);
  }

  /// Save current status to storage
  Future<void> _saveStatus(String status) async {
    if (_storageService == null) {
      return;
    }
    if (status == StatusFilterState.allStatuses) {
      // Remove the key when showing all statuses
      await _storageService!.clearStatusFilter();
    } else {
      await _storageService!.setStatusFilter(status);
    }
  }
}

/// Provider for available statuses based on all devices
@riverpod
List<String> deviceStatuses(DeviceStatusesRef ref) {
  final devices = ref.watch(devicesNotifierProvider);

  return devices.when(
    data: StatusFilterState.getUniqueStatusesFromDevices,
    loading: () => [StatusFilterState.allStatuses],
    error: (_, __) => [StatusFilterState.allStatuses],
  );
}
