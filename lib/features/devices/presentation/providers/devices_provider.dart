import 'dart:async';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/device_update_event_bus.dart';
import 'package:rgnets_fdk/core/services/image_upload_event_bus.dart';
import 'package:rgnets_fdk/core/utils/logging_utils.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/features/devices/data/repositories/device_repository.dart'
    as device_impl;
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_devices.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_devices_params.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/reboot_device.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/search_devices.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/image_upload_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'devices_provider.g.dart';

@Riverpod(keepAlive: true)
class DevicesNotifier extends _$DevicesNotifier {
  Logger get _logger => ref.read(loggerProvider);
  CacheManager get _cacheManager => ref.read(cacheManagerProvider);
  StreamSubscription<List<Device>>? _devicesStreamSub;
  bool _devicesStreamAttached = false;
  List<Device>? _latestDevices;

  GetDevices get _getDevices => GetDevices(ref.read(deviceRepositoryProvider));

  RebootDevice get _rebootDevice =>
      RebootDevice(ref.read(deviceRepositoryProvider));

  @override
  Future<List<Device>> build() async {
    final authStatus = ref.watch(authStatusProvider);
    final isAuthenticated = authStatus?.isAuthenticated ?? false;
    _attachDevicesStream();

    if (isVerboseLoggingEnabled) {
      _logger.i('DevicesProvider: Loading devices');
    }

    if (!isAuthenticated) {
      if (isVerboseLoggingEnabled) {
        _logger.i('DevicesProvider: Skipping load (not authenticated)');
      }
      _latestDevices = null;
      return [];
    }

    try {
      // Try to get from cache first with stale-while-revalidate
      // Use list fields for optimized loading
      final cacheKey = DeviceFieldSets.getCacheKey(
        'devices_list',
        DeviceFieldSets.listFields,
      );
      final devices = await _cacheManager.get<List<Device>>(
        key: cacheKey,
        fetcher: () async {
          final getDevices = _getDevices;
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
              if (isVerboseLoggingEnabled) {
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

      final fetchedDevices = devices ?? [];
      final latestDevices = _latestDevices;

      // WebSocket stream is the real-time source of truth.
      // Always prefer stream data when available since it reflects the current server state.
      // The fetched/cached data is only used as a fallback for initial load before stream delivers.
      if (latestDevices != null) {
        if (isVerboseLoggingEnabled) {
          _logger.d(
            'DevicesProvider: Using stream data (${latestDevices.length}) - real-time source',
          );
        }
        return latestDevices;
      }

      return fetchedDevices;
    } on Exception catch (e, stack) {
      _logger.e(
        'DevicesProvider: Exception in build(): $e',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  void _attachDevicesStream() {
    if (_devicesStreamAttached) {
      return;
    }

    final repository = ref.read(deviceRepositoryProvider);
    if (repository is! device_impl.DeviceRepositoryImpl) {
      return;
    }

    _devicesStreamAttached = true;

    // Check for any devices that arrived before subscription (broadcast stream race fix)
    final currentDevices = repository.currentDevices;
    if (currentDevices != null && currentDevices.isNotEmpty) {
      _logger.d(
        'DevicesProvider: Found ${currentDevices.length} existing devices on stream attach',
      );
      _latestDevices = currentDevices;
    }

    _devicesStreamSub = repository.devicesStream.listen((devices) {
      _latestDevices = devices;
      final authStatus = ref.read(authStatusProvider);
      if (authStatus?.isUnauthenticated ?? false) {
        return;
      }
      state = AsyncValue.data(devices);
    });

    ref.onDispose(() {
      _devicesStreamSub?.cancel();
      _devicesStreamSub = null;
      _devicesStreamAttached = false;
    });
  }

  /// User-triggered refresh with loading state
  Future<void> userRefresh() async {
    if (isVerboseLoggingEnabled) {
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
      final devices = await _cacheManager.get<List<Device>>(
        key: cacheKey,
        fetcher: () async {
          final getDevices = _getDevices;
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
    if (isVerboseLoggingEnabled) {
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
      final devices = await _cacheManager.get<List<Device>>(
        key: cacheKey,
        fetcher: () async {
          final getDevices = _getDevices;
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

  Future<void> rebootDevice(String deviceId) async {
    if (isVerboseLoggingEnabled) {
      _logger.i('DevicesProvider: Rebooting device: $deviceId');
    }

    try {
      final rebootDevice = _rebootDevice;
      final result = await rebootDevice(RebootDeviceParams(deviceId: deviceId));

      await result.fold(
        (failure) {
          _logger.e('DevicesProvider: Reboot failed: ${failure.message}');
          return Future<void>.error(Exception(failure.message));
        },
        (_) {
          if (isVerboseLoggingEnabled) {
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
  Logger get _logger => ref.read(loggerProvider);
  StreamSubscription<CacheInvalidationEvent>? _cacheInvalidationSub;
  StreamSubscription<DeviceUpdateEvent>? _deviceUpdateSub;
  Timer? _refreshDebounceTimer;

  /// Debounce duration for coalescing rapid update events
  static const _refreshDebounceDuration = Duration(milliseconds: 500);

  GetDevice get _getDevice => GetDevice(ref.read(deviceRepositoryProvider));

  @override
  Future<Device?> build(String deviceId) async {
    // Subscribe to cache invalidation events for this device
    // This enables automatic UI refresh after image uploads from FDK
    final eventBus = ref.watch(imageUploadEventBusProvider);
    _cacheInvalidationSub?.cancel();
    _cacheInvalidationSub = eventBus.cacheInvalidated
        .where((event) => event.deviceId == deviceId)
        .listen((event) {
      _logger.i(
        'DeviceNotifier: Cache invalidated for $deviceId, refreshing...',
      );
      _debouncedSilentRefresh();
    });

    // Subscribe to WebSocket device updates for external changes
    // This enables automatic UI refresh when external apps modify device data
    final deviceUpdateBus = ref.watch(deviceUpdateEventBusProvider);
    _deviceUpdateSub?.cancel();
    _deviceUpdateSub = deviceUpdateBus.updates
        .where((event) => event.deviceId == deviceId)
        .listen((event) {
      _logger.i(
        'DeviceNotifier: External update for $deviceId (action: ${event.action})',
      );

      if (event.action == DeviceUpdateAction.destroyed) {
        // Handle device deletion - show error state immediately
        _refreshDebounceTimer?.cancel();
        state = AsyncValue.error('Device has been removed', StackTrace.current);
      } else {
        // Debounce refresh to coalesce rapid updates (e.g., multi-image uploads)
        _debouncedSilentRefresh();
      }
    });

    ref.onDispose(() {
      _cacheInvalidationSub?.cancel();
      _cacheInvalidationSub = null;
      _deviceUpdateSub?.cancel();
      _deviceUpdateSub = null;
      _refreshDebounceTimer?.cancel();
      _refreshDebounceTimer = null;
    });

    // For detail view, fetch all fields
    final getDevice = _getDevice;
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
    try {
      final getDevice = _getDevice;
      final result = await getDevice(
        GetDeviceParams(
          id: deviceId,
          fields: DeviceFieldSets
              .detailFields, // Refresh with all fields for detail view
          forceRefresh: true, // Bypass cache to get latest data from server
        ),
      );

      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        AsyncValue.data,
      );
    } on Object catch (e, stack) {
      _logger.e('DeviceNotifier: Unexpected error in refresh: $e');
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Silent refresh without showing loading state.
  /// Used for automatic updates after image upload.
  Future<void> _silentRefresh() async {
    try {
      final getDevice = _getDevice;
      final result = await getDevice(
        GetDeviceParams(
          id: deviceId,
          fields: DeviceFieldSets.detailFields,
          forceRefresh: true, // Bypass cache to get latest data from server
        ),
      );

      result.fold(
        (failure) {
          _logger.w('DeviceNotifier: Silent refresh failed: ${failure.message}');
        },
        (device) {
          // Only update if we still have data (avoid overwriting error states)
          if (state.hasValue) {
            state = AsyncValue.data(device);
            _logger.i('DeviceNotifier: Silent refresh completed for $deviceId');
          }
        },
      );
    } on Object catch (e) {
      _logger.w('DeviceNotifier: Silent refresh exception: $e');
    }
  }

  /// Debounced version of _silentRefresh to coalesce rapid update events.
  /// This prevents multiple refreshes when receiving burst updates (e.g., multi-image uploads).
  void _debouncedSilentRefresh() {
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(_refreshDebounceDuration, () {
      _refreshDebounceTimer = null;
      _silentRefresh();
    });
  }

  /// Deletes an image from the device by its signed ID
  Future<bool> deleteDeviceImage(String signedIdToDelete) async {
    try {
      final repository = ref.read(deviceRepositoryProvider);
      final result = await repository.deleteDeviceImage(deviceId, signedIdToDelete);

      return result.fold(
        (failure) {
          _logger.e('Failed to delete image: ${failure.message}');
          return false;
        },
        (Device updatedDevice) {
          // Update the state with the new device data
          state = AsyncValue.data(updatedDevice);
          _logger.i('Successfully deleted image from device $deviceId');
          return true;
        },
      );
    } on Exception catch (e) {
      _logger.e('Exception deleting image: $e');
      return false;
    }
  }

  /// Updates the device note via WebSocket
  /// Uses dedicated updateDeviceNote method that only sends the note field
  Future<bool> updateNote(String note) async {
    final currentDevice = state.valueOrNull;
    if (currentDevice == null) {
      _logger.e('Cannot update note: device not loaded');
      return false;
    }

    try {
      final repository = ref.read(deviceRepositoryProvider);
      // Use dedicated note update method that only sends the note field
      // Pass empty string directly to clear the note on the backend
      final result = await repository.updateDeviceNote(
        deviceId,
        note,
      );

      return result.fold(
        (failure) {
          _logger.e('Failed to update note: ${failure.message}');
          return false;
        },
        (Device device) {
          // Update the state with the new device data
          state = AsyncValue.data(device);
          _logger.i('Successfully updated note for device $deviceId');
          return true;
        },
      );
    } on Exception catch (e) {
      _logger.e('Exception updating note: $e');
      return false;
    }
  }
}

// Search provider
@Riverpod(keepAlive: true)
class DeviceSearchNotifier extends _$DeviceSearchNotifier {
  SearchDevices get _searchDevices =>
      SearchDevices(ref.read(deviceRepositoryProvider));

  @override
  Future<List<Device>> build(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final searchDevices = _searchDevices;
    final result = await searchDevices(SearchDevicesParams(query: query));

    return result.fold(
      (failure) => throw Exception(failure.message),
      (devices) => devices,
    );
  }
}
