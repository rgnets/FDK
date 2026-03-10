import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/onboarding/data/config/onboarding_config.dart';
import 'package:rgnets_fdk/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_status_payload.dart';
import 'package:rgnets_fdk/features/onboarding/data/resolvers/message_resolver.dart';
import 'package:rgnets_fdk/features/onboarding/data/services/stage_timestamp_tracker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_onboarding_provider.g.dart';

/// Provider for StageTimestampTracker service
@Riverpod(keepAlive: true)
StageTimestampTracker stageTimestampTracker(StageTimestampTrackerRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final logger = ref.watch(loggerProvider);
  return StageTimestampTracker(prefs: prefs, logger: logger);
}

/// Provider for MessageResolver
@riverpod
MessageResolver messageResolver(MessageResolverRef ref) {
  return const MessageResolver();
}

/// Main provider for device onboarding state.
/// Transforms DeviceModelSealed into OnboardingState with timing information.
@Riverpod(keepAlive: true)
class DeviceOnboardingNotifier extends _$DeviceOnboardingNotifier {
  StageTimestampTracker get _tracker => ref.read(stageTimestampTrackerProvider);
  MessageResolver get _resolver => ref.read(messageResolverProvider);

  @override
  Map<String, OnboardingState> build() {
    return {};
  }

  /// Get onboarding state for a device
  OnboardingState? getOnboardingState(String deviceId) {
    return state[deviceId];
  }

  /// Update onboarding state from a DeviceModelSealed
  Future<void> updateFromDevice(DeviceModelSealed device) async {
    final deviceId = device.deviceId;
    final deviceType = _getDeviceType(device);
    final payload = _getOnboardingPayload(device);

    if (payload == null) {
      // Device has no onboarding data
      _removeState(deviceId);
      return;
    }

    final currentStage = payload.stage ?? 1;
    final maxStages = payload.maxStages ??
        OnboardingConfig.instance.getMaxStages(deviceType);

    // Record stage transition if stage changed
    final existingState = state[deviceId];
    if (existingState == null || existingState.currentStage != currentStage) {
      await _tracker.recordStageTransition(
        deviceType: deviceType,
        deviceId: deviceId,
        stage: currentStage,
        maxStages: maxStages,
      );
    }

    // Get timestamp from tracker
    final stageEnteredAt = _tracker.getStageEnteredAt(deviceType, deviceId);
    final elapsedTime = _tracker.getElapsedTime(deviceType, deviceId);

    // Determine if complete
    final isComplete = _isComplete(deviceType, payload);

    // Determine if overdue
    final isOverdue = !isComplete && _resolver.isStageOverdue(
      deviceType: deviceType,
      stage: currentStage,
      elapsedTime: elapsedTime,
    );

    // Build new state
    final newState = OnboardingState(
      deviceId: deviceId,
      deviceType: deviceType,
      currentStage: currentStage,
      maxStages: maxStages,
      statusText: payload.status,
      stageDisplay: payload.stageDisplay,
      nextAction: payload.nextAction,
      errorText: payload.error,
      stageEnteredAt: stageEnteredAt,
      lastUpdate: payload.lastUpdate,
      lastUpdateAgeSecs: payload.lastUpdateAgeSecs,
      isComplete: isComplete,
      isOverdue: isOverdue,
      typicalDurationMinutes: _resolver.getTypicalDurationMinutes(
        deviceType,
        currentStage,
      ),
    );

    // Update state map
    state = {...state, deviceId: newState};
  }

  /// Update multiple devices at once
  Future<void> updateFromDevices(List<DeviceModelSealed> devices) async {
    for (final device in devices) {
      await updateFromDevice(device);
    }
  }

  /// Remove state for a device
  void _removeState(String deviceId) {
    if (state.containsKey(deviceId)) {
      final newState = Map<String, OnboardingState>.from(state);
      newState.remove(deviceId);
      state = newState;
    }
  }

  /// Clear state for a device
  Future<void> clearDeviceState(String deviceId) async {
    _removeState(deviceId);

    // Also clear from tracker - need to determine device type
    // For simplicity, try both types
    await _tracker.clearTrackingData('AP', deviceId);
    await _tracker.clearTrackingData('ONT', deviceId);
  }

  /// Cleanup stale tracking records
  Future<int> cleanupStaleRecords() async {
    return _tracker.cleanupStaleRecords();
  }

  /// Get device type string from DeviceModelSealed
  String _getDeviceType(DeviceModelSealed device) {
    return device.map(
      ap: (_) => 'AP',
      ont: (_) => 'ONT',
      switchDevice: (_) => 'SWITCH',
      wlan: (_) => 'WLAN',
    );
  }

  /// Get onboarding payload from device
  OnboardingStatusPayload? _getOnboardingPayload(DeviceModelSealed device) {
    return device.map(
      ap: (d) => d.onboardingStatus,
      ont: (d) => d.onboardingStatus,
      switchDevice: (_) => null, // Switches don't have onboarding
      wlan: (_) => null, // WLAN controllers don't have onboarding
    );
  }

  /// Determine if onboarding is complete
  bool _isComplete(String deviceType, OnboardingStatusPayload payload) {
    // Priority 1: Explicit completion flag
    if (payload.onboardingComplete == true) return true;

    // Priority 2: Check against config success stage
    final stage = payload.stage ?? 1;
    if (stage > 0) {
      final successStage = OnboardingConfig.instance.getSuccessStage(deviceType);
      if (stage >= successStage) return true;
    }

    // Priority 3: Check if at or past max stages
    final maxStages = payload.maxStages;
    if (maxStages != null && stage >= maxStages) return true;

    return false;
  }
}

/// Provider for a single device's onboarding state.
/// Falls back to WebSocket cache if not in notifier state.
@riverpod
OnboardingState? deviceOnboardingState(
  DeviceOnboardingStateRef ref,
  String deviceId,
) {
  final states = ref.watch(deviceOnboardingNotifierProvider);

  // Watch device cache updates so this provider re-evaluates when
  // broadcasts or show responses update onboarding data in the cache.
  ref.watch(webSocketDeviceLastUpdateProvider);

  // Always check the WebSocket cache for the latest device data and push
  // it into the notifier. Without this, the notifier holds stale onboarding
  // state after broadcasts update the cache.
  final wsCache = ref.watch(webSocketCacheIntegrationProvider);
  final allDevices = wsCache.getAllCachedDeviceModels();
  final device = allDevices.where((d) => d.deviceId == deviceId).firstOrNull;

  if (device != null) {
    final payload = device.map(
      ap: (d) => d.onboardingStatus,
      ont: (d) => d.onboardingStatus,
      switchDevice: (_) => null,
      wlan: (_) => null,
    );

    if (payload != null) {
      // Push updated device data into the notifier (async to avoid modifying
      // provider state during build). The notifier update will trigger a
      // rebuild via the watch on deviceOnboardingNotifierProvider above.
      Future.microtask(() {
        ref
            .read(deviceOnboardingNotifierProvider.notifier)
            .updateFromDevice(device);
      });

      // Return notifier state if available (will have timing data etc.)
      if (states.containsKey(deviceId)) {
        return states[deviceId];
      }

      // Return a temporary state for immediate display on first load
      final deviceType = device.map(
        ap: (_) => 'AP',
        ont: (_) => 'ONT',
        switchDevice: (_) => 'SWITCH',
        wlan: (_) => 'WLAN',
      );
      final currentStage = payload.stage ?? 1;
      final maxStages = payload.maxStages ??
          OnboardingConfig.instance.getMaxStages(deviceType);

      return OnboardingState(
        deviceId: deviceId,
        deviceType: deviceType,
        currentStage: currentStage,
        maxStages: maxStages,
        statusText: payload.status,
        stageDisplay: payload.stageDisplay,
        nextAction: payload.nextAction,
        errorText: payload.error,
        lastUpdate: payload.lastUpdate,
        lastUpdateAgeSecs: payload.lastUpdateAgeSecs,
        isComplete: payload.onboardingComplete ?? (currentStage >= maxStages),
        isOverdue: false, // Will be updated by notifier
      );
    }
  }

  // No device in cache or no onboarding data — return notifier state if any
  return states[deviceId];
}

/// Provider to check if a device has onboarding data
@riverpod
bool hasOnboardingData(HasOnboardingDataRef ref, String deviceId) {
  final state = ref.watch(deviceOnboardingStateProvider(deviceId));
  return state != null && state.hasStarted;
}

/// Provider to check if a device's onboarding is complete
@riverpod
bool isOnboardingComplete(IsOnboardingCompleteRef ref, String deviceId) {
  final state = ref.watch(deviceOnboardingStateProvider(deviceId));
  return state?.isComplete ?? false;
}

/// Provider to check if a device's onboarding is overdue
@riverpod
bool isOnboardingOverdue(IsOnboardingOverdueRef ref, String deviceId) {
  final state = ref.watch(deviceOnboardingStateProvider(deviceId));
  return state?.isOverdue ?? false;
}
