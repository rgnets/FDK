import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/use_case_providers.dart';
import 'package:rgnets_fdk/core/services/adaptive_refresh_manager.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_devices_params.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/reboot_device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/search_devices.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'devices_provider.g.dart';

@Riverpod(keepAlive: true)
class DevicesNotifier extends _$DevicesNotifier {
  static final _logger = LoggerConfig.getLogger();
  AdaptiveRefreshManager? _refreshManager;
  CacheManager? _cacheManager;

  @override
  Future<List<Device>> build() async {
    // Initialize managers
    _refreshManager = ref.read(adaptiveRefreshManagerProvider);
    _cacheManager = ref.read(cacheManagerProvider);
    final storage = ref.read(storageServiceProvider);
    final allowUnauthenticated = EnvironmentConfig.useSyntheticData;

    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('DevicesProvider: Loading devices');
    }

    if (!storage.isAuthenticated && !allowUnauthenticated) {
      if (LoggerConfig.isVerboseLoggingEnabled) {
        _logger.i('DevicesProvider: Skipping load (not authenticated)');
      }
      return [];
    }

    if (!EnvironmentConfig.useSyntheticData) {
      // Start sequential background refresh only when using live data.
      _startBackgroundRefresh();
    }

    try {
      // Try to get from cache first with stale-while-revalidate
      // Use list fields for optimized loading
      final cacheKey = DeviceFieldSets.getCacheKey(
        'devices_list',
        DeviceFieldSets.listFields,
      );
      final devices = await _cacheManager!.get<List<Device>>(
        key: cacheKey,
        fetcher: () async {
          final getDevices = ref.read(getDevicesProvider);
          final result = await getDevices(
            const GetDevicesParams(fields: DeviceFieldSets.listFields),
          );

          return result.fold(
            (failure) {
              _logger.e(
                'DevicesProvider: Failed to load devices - ${failure.message}',
              );
              throw Exception(failure.message);
            },
            (devices) {
              if (LoggerConfig.isVerboseLoggingEnabled) {
                _logger.i(
                  'DevicesProvider: Successfully loaded ${devices.length} devices with ${DeviceFieldSets.listFields.length} fields',
                );
              }
              return devices;
            },
          );
        },
        ttl: const Duration(minutes: 5),
      );

      return devices ?? [];
    } on Exception catch (e, stack) {
      _logger.e(
        'DevicesProvider: Exception in build(): $e',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// User-triggered refresh with loading state
  Future<void> userRefresh() async {
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('DevicesProvider: User-triggered refresh');
    }

    // Show loading state for user-triggered refresh
    state = const AsyncValue.loading();

    try {
      // Force refresh the cache with list fields
      final cacheKey = DeviceFieldSets.getCacheKey(
        'devices_list',
        DeviceFieldSets.listFields,
      );
      final devices = await _cacheManager!.get<List<Device>>(
        key: cacheKey,
        fetcher: () async {
          final getDevices = ref.read(getDevicesProvider);
          final result = await getDevices(
            const GetDevicesParams(fields: DeviceFieldSets.listFields),
          );

          return result.fold(
            (failure) => throw Exception(failure.message),
            (devices) => devices,
          );
        },
        ttl: const Duration(minutes: 5),
        forceRefresh: true,
      );

      state = AsyncValue.data(devices ?? []);
    } on Exception catch (e, stack) {
      _logger.e(
        'DevicesProvider: User refresh failed: $e',
        error: e,
        stackTrace: stack,
      );
      state = AsyncValue.error(e, stack);
    }
  }

  /// Silent background refresh without loading state
  /// Context-aware: refreshes based on what view is active
  Future<void> silentRefresh({String? context}) async {
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i(
        'DevicesProvider: Silent background refresh (context: $context)',
      );
    }

    try {
      // Determine fields based on context
      final fields = (context == null || context == 'list')
          ? DeviceFieldSets.refreshFields
          : DeviceFieldSets.listFields;
      final cacheKey = DeviceFieldSets.getCacheKey('devices_list', fields);

      // Force refresh the cache with appropriate fields
      final devices = await _cacheManager!.get<List<Device>>(
        key: cacheKey,
        fetcher: () async {
          final getDevices = ref.read(getDevicesProvider);
          final result = await getDevices(GetDevicesParams(fields: fields));

          return result.fold(
            (failure) => throw Exception(failure.message),
            (devices) => devices,
          );
        },
        ttl: const Duration(minutes: 5),
        forceRefresh: true,
      );

      // Update state without showing loading
      if (devices != null && state.hasValue) {
        state = AsyncValue.data(devices);
      }
    } on Exception catch (e) {
      // Silent fail for background refresh
      _logger.w('DevicesProvider: Silent refresh failed: $e');
    }
  }

  /// Deprecated - use userRefresh() or silentRefresh() instead
  Future<void> refresh() async {
    return userRefresh();
  }

  /// Start sequential background refresh
  void _startBackgroundRefresh() {
    _refreshManager?.startSequentialRefresh(
      () => silentRefresh(context: 'list'),
    );
  }

  Future<void> rebootDevice(String deviceId) async {
    if (LoggerConfig.isVerboseLoggingEnabled) {
      _logger.i('DevicesProvider: Rebooting device: $deviceId');
    }

    try {
      final rebootDevice = ref.read(rebootDeviceProvider);
      final result = await rebootDevice(RebootDeviceParams(deviceId: deviceId));

      await result.fold(
        (failure) {
          _logger.e('DevicesProvider: Reboot failed: ${failure.message}');
          return Future<void>.error(Exception(failure.message));
        },
        (_) {
          if (LoggerConfig.isVerboseLoggingEnabled) {
            _logger.i('DevicesProvider: Reboot command sent successfully');
          }
          return refresh();
        },
      );
    } on Exception catch (e, stack) {
      _logger.e(
        'DevicesProvider: Exception during reboot: $e',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
class DeviceNotifier extends _$DeviceNotifier {
  @override
  Future<Device?> build(String deviceId) async {
    // For detail view, fetch all fields
    final getDevice = ref.read(getDeviceProvider);
    final result = await getDevice(
      GetDeviceParams(
        id: deviceId,
        fields: DeviceFieldSets.detailFields, // Empty = all fields
      ),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (device) => device,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final getDevice = ref.read(getDeviceProvider);
    final result = await getDevice(
      GetDeviceParams(
        id: deviceId,
        fields: DeviceFieldSets
            .detailFields, // Refresh with all fields for detail view
      ),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      AsyncValue.data,
    );
  }
}

// Search provider
@Riverpod(keepAlive: true)
class DeviceSearchNotifier extends _$DeviceSearchNotifier {
  @override
  Future<List<Device>> build(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final searchDevices = ref.read(searchDevicesProvider);
    final result = await searchDevices(SearchDevicesParams(query: query));

    return result.fold(
      (failure) => throw Exception(failure.message),
      (devices) => devices,
    );
  }
}

// Filter state provider
@Riverpod(keepAlive: true)
class DeviceFilterState extends _$DeviceFilterState {
  @override
  DeviceFilters build() {
    return const DeviceFilters();
  }

  void updateType(String? type) {
    state = state.copyWith(type: type);
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void clearFilters() {
    state = const DeviceFilters();
  }
}

// Filtered devices provider
@Riverpod(keepAlive: true)
List<Device> filteredDevices(FilteredDevicesRef ref) {
  final devices = ref.watch(devicesNotifierProvider);
  final filters = ref.watch(deviceFilterStateProvider);

  return devices.when(
    data: (deviceList) {
      return deviceList.where((device) {
        final matchesType = filters.type == null || device.type == filters.type;
        final matchesStatus =
            filters.status == null || device.status == filters.status;

        return matchesType && matchesStatus;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

// Filter state class
class DeviceFilters {
  const DeviceFilters({this.type, this.status});

  final String? type;
  final String? status;

  DeviceFilters copyWith({String? type, String? status}) {
    return DeviceFilters(
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}
