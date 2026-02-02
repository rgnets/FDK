import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_view_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_device_view_model.freezed.dart';
part 'room_device_view_model.g.dart';

/// Room device filtering and management view model
///
/// Following MVVM architecture, this view model handles all business logic
/// for device filtering, counting, and display within room context.
/// Extracts complex logic from UI components to maintain separation of concerns.
@freezed
class RoomDeviceState with _$RoomDeviceState {
  const factory RoomDeviceState({
    @Default([]) List<Device> allDevices,
    @Default([]) List<Device> filteredDevices,
    @Default(RoomDeviceStats()) RoomDeviceStats stats,
    @Default(false) bool isLoading,
    String? error,
  }) = _RoomDeviceState;
}

/// Device statistics for a room
@freezed
class RoomDeviceStats with _$RoomDeviceStats {
  const factory RoomDeviceStats({
    @Default(0) int total,
    @Default(0) int accessPoints,
    @Default(0) int switches,
    @Default(0) int onts,
    @Default(0) int wlanControllers,
  }) = _RoomDeviceStats;
}

/// Room device view model provider
///
/// Provides device filtering and statistics for a specific room.
/// Follows Clean Architecture and MVVM patterns.
@riverpod
class RoomDeviceNotifier extends _$RoomDeviceNotifier {
  @override
  RoomDeviceState build(String roomId) {
    // Set up listeners for future updates
    ref
      ..listen(devicesNotifierProvider, (previous, next) {
        next.when(
          data: (devices) => _updateDevices(roomId, devices),
          loading: _setLoading,
          error: (error, stack) => _setError(error.toString()),
        );
      })
      // Listen to room changes to validate room still exists
      ..listen(roomViewModelByIdProvider(roomId), (previous, next) {
        if (next == null) {
          _setError('Room not found: $roomId');
        }
      });

    // Process current state of devices provider
    final devicesState = ref.read(devicesNotifierProvider);

    // Return appropriate initial state based on current data
    return devicesState.when(
      data: (devices) {
        try {
          // Validate room ID format (must be numeric)
          final roomIdInt = int.tryParse(roomId);
          if (roomIdInt == null) {
            return RoomDeviceState(
              error:
                  'Invalid room ID format: "$roomId". Room IDs must be numeric.',
            );
          }

          // Filter devices for this room
          final roomDevices = _filterDevicesForRoom(devices, roomIdInt);

          // Calculate statistics
          final stats = _calculateDeviceStats(roomDevices);

          // Return initial state with devices
          return RoomDeviceState(
            allDevices: roomDevices,
            filteredDevices: roomDevices,
            stats: stats,
            isLoading: false,
          );
        } on Object catch (e) {
          return RoomDeviceState(
            error: 'Failed to process devices for room $roomId: $e',
          );
        }
      },
      loading: () => const RoomDeviceState(isLoading: true),
      error: (error, _) => RoomDeviceState(error: error.toString()),
    );
  }

  /// Update devices when data changes
  void _updateDevices(String roomId, List<Device> allDevices) {
    try {
      // Validate room ID format (must be numeric)
      final roomIdInt = int.tryParse(roomId);
      if (roomIdInt == null) {
        throw ArgumentError(
          'Invalid room ID format: "$roomId". Room IDs must be numeric.',
        );
      }

      // Filter devices for this room
      final roomDevices = _filterDevicesForRoom(allDevices, roomIdInt);

      // Calculate statistics
      final stats = _calculateDeviceStats(roomDevices);

      // Update state
      state = RoomDeviceState(
        allDevices: roomDevices,
        filteredDevices: roomDevices, // Default to all devices
        stats: stats,
        isLoading: false,
      );
    } on Exception catch (e) {
      _setError('Failed to process devices for room $roomId: $e');
    }
  }

  /// Filter devices for a specific room
  List<Device> _filterDevicesForRoom(List<Device> allDevices, int roomIdInt) {
    try {
      // DEBUG: Log all devices with their pmsRoomId
      print('DEBUG _filterDevicesForRoom: Looking for roomId=$roomIdInt in ${allDevices.length} devices');

      final filtered = allDevices.where((device) {
        // Use pmsRoomId for room association
        // This is the established pattern from room_view_models.dart
        return device.pmsRoomId == roomIdInt;
      }).toList();

      // DEBUG: Log filtered devices
      print('DEBUG _filterDevicesForRoom: Found ${filtered.length} devices for room $roomIdInt:');
      for (final d in filtered) {
        print('  - id=${d.id}, name=${d.name}, type=${d.type}, pmsRoomId=${d.pmsRoomId}');
      }

      return filtered;
    } on Exception catch (e) {
      // Defensive programming - if filtering fails, return empty list
      // This prevents UI crashes from propagating
      throw Exception('Device filtering failed: $e');
    }
  }

  /// Calculate device statistics with strict type validation
  RoomDeviceStats _calculateDeviceStats(List<Device> devices) {
    try {
      var accessPoints = 0;
      var switches = 0;
      var onts = 0;
      var wlanControllers = 0;

      for (final device in devices) {
        // Validate device type before counting
        // This will throw ArgumentError for invalid types (as requested)
        DeviceTypes.validateDeviceType(device.type);

        // Count by device type using constants
        switch (device.type) {
          case DeviceTypes.accessPoint:
            accessPoints++;
            break;
          case DeviceTypes.networkSwitch:
            switches++;
            break;
          case DeviceTypes.ont:
            onts++;
            break;
          case DeviceTypes.wlanController:
            wlanControllers++;
            break;
          default:
            // This should never happen due to validation above
            throw StateError(
              'Unhandled device type in statistics: ${device.type}',
            );
        }
      }

      return RoomDeviceStats(
        total: devices.length,
        accessPoints: accessPoints,
        switches: switches,
        onts: onts,
        wlanControllers: wlanControllers,
      );
    } on Exception catch (e) {
      // Re-throw with context - this will bubble up as requested
      throw Exception('Device statistics calculation failed: $e');
    }
  }

  /// Filter devices by type
  void filterByType(String? deviceType) {
    if (state.isLoading || state.error != null) {
      return;
    }

    try {
      List<Device> filtered;

      if (deviceType == null || deviceType.isEmpty) {
        // Show all devices
        filtered = state.allDevices;
      } else {
        // Validate the filter type
        DeviceTypes.validateDeviceType(deviceType);

        // Filter by type
        filtered = state.allDevices.where((device) {
          return device.type == deviceType;
        }).toList();
      }

      state = state.copyWith(filteredDevices: filtered);
    } on Exception catch (e) {
      _setError('Device type filtering failed: $e');
    }
  }

  /// Set loading state
  void _setLoading() {
    state = state.copyWith(isLoading: true, error: null);
  }

  /// Set error state
  void _setError(String error) {
    state = state.copyWith(isLoading: false, error: error);
  }

  /// Refresh room devices
  Future<void> refresh() async {
    _setLoading();

    try {
      // Trigger device refresh through the devices provider
      await ref.read(devicesNotifierProvider.notifier).userRefresh();
    } on Exception catch (e) {
      _setError('Failed to refresh devices: $e');
    }
  }
}

/// Device type filter options for UI
enum DeviceTypeFilter {
  all,
  accessPoints,
  switches,
  onts,
  wlanControllers;

  /// Get the device type string for filtering
  String? get deviceType {
    switch (this) {
      case DeviceTypeFilter.all:
        return null; // Show all
      case DeviceTypeFilter.accessPoints:
        return DeviceTypes.accessPoint;
      case DeviceTypeFilter.switches:
        return DeviceTypes.networkSwitch;
      case DeviceTypeFilter.onts:
        return DeviceTypes.ont;
      case DeviceTypeFilter.wlanControllers:
        return DeviceTypes.wlanController;
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case DeviceTypeFilter.all:
        return 'All';
      case DeviceTypeFilter.accessPoints:
        return 'Access Points';
      case DeviceTypeFilter.switches:
        return 'Switches';
      case DeviceTypeFilter.onts:
        return 'ONTs';
      case DeviceTypeFilter.wlanControllers:
        return 'WLAN Controllers';
    }
  }

  /// Get icon identifier for UI
  String get iconIdentifier {
    switch (this) {
      case DeviceTypeFilter.all:
        return 'devices';
      case DeviceTypeFilter.accessPoints:
        return DeviceTypes.getIconIdentifier(DeviceTypes.accessPoint);
      case DeviceTypeFilter.switches:
        return DeviceTypes.getIconIdentifier(DeviceTypes.networkSwitch);
      case DeviceTypeFilter.onts:
        return DeviceTypes.getIconIdentifier(DeviceTypes.ont);
      case DeviceTypeFilter.wlanControllers:
        return DeviceTypes.getIconIdentifier(DeviceTypes.wlanController);
    }
  }
}
