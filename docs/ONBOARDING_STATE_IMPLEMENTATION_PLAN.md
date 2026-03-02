# Onboarding State Tracking System Implementation Plan

## Overview

Implement a device onboarding state tracking system for the fdk_websocket project, mirroring the architecture from ATT-FE-Tool. The system will track onboarding progress for ONT (6 stages) and AP (6 stages) devices, detect overdue stages, and provide UI-ready display data.

## Current State

- **fdk_websocket**: Uses `DeviceModelSealed` (Freezed sealed class) - needs typed `OnboardingStatusPayload` instead of `Map<String, dynamic>`
- **ATT-FE-Tool**: Reference implementation with OnboardingState, DeviceOnboardingService

## Data Flow (WebSocket Architecture)

```
WebSocket payload (ont_onboarding_status / ap_onboarding_status)
      ↓
WebSocketCacheIntegration._mapToDeviceModel()
      ↓
DeviceModelSealed (APModel.onboardingStatus / ONTModel.onboardingStatus)
      ↓  (typed as OnboardingStatusPayload)
DeviceOnboardingNotifier.getOnboardingState()
      ↓
OnboardingState
```

**Key Source Model:**
- `lib/features/devices/data/models/device_model_sealed.dart`
- **APModel**: `@JsonKey(name: 'ap_onboarding_status') OnboardingStatusPayload? onboardingStatus`
- **ONTModel**: `@JsonKey(name: 'ont_onboarding_status') OnboardingStatusPayload? onboardingStatus`

The `DeviceOnboardingNotifier` should:
1. Accept `DeviceModelSealed` to access `onboardingStatus` directly (typed)
2. Rebuild OnboardingState when device data changes via WebSocket
3. Use backend's `lastUpdateAgeSecs` for timing (no local persistence needed)

## Field Mapping (WebSocket Payload)

The `ont_onboarding_status` / `ap_onboarding_status` maps to OnboardingState as follows:

| API Field | Type | OnboardingState Field | Notes |
|-----------|------|----------------------|-------|
| `stage` | int | `currentStage` | 1-6 (ONT) or 1-6 (AP), 0 = not started |
| `max_stages` | int | `maxStages` | 6 (ONT) or 6 (AP) |
| `status` | string | `statusText` | Human-readable status |
| `stage_display` | string | `stageDisplay` | Display text for current stage |
| `next_action` | string | `nextAction` | Suggested next action |
| `error` | string | `errorText` | Error message if any |
| `last_update` | ISO8601 | `lastUpdate` | Last update timestamp |
| `last_seen_at` | ISO8601 | `lastSeenAt` | AP only - last seen time |
| `last_update_age_secs` | int | `lastUpdateAgeSecs` | Seconds since last update |
| `onboarding_complete` | bool | `onboardingComplete` | Explicit completion flag |

**Completion Logic (priority order):**
1. If `onboarding_complete` is true → complete
2. If `stage` == `success_stage` from config → complete
3. If `stage` >= `max_stages` → complete
4. Otherwise → incomplete

## OnboardingStatusPayload Model

This typed Freezed model replaces `Map<String, dynamic>?` for type safety:

```dart
@freezed
class OnboardingStatusPayload with _$OnboardingStatusPayload {
  const factory OnboardingStatusPayload({
    int? stage,
    @JsonKey(name: 'max_stages') int? maxStages,
    String? status,
    @JsonKey(name: 'stage_display') String? stageDisplay,
    @JsonKey(name: 'next_action') String? nextAction,
    String? error,
    @JsonKey(name: 'last_update') DateTime? lastUpdate,
    @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
    @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,
    @JsonKey(name: 'onboarding_complete') bool? onboardingComplete,
  }) = _OnboardingStatusPayload;

  factory OnboardingStatusPayload.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusPayloadFromJson(json);
}
```

**Key benefits:**
- Compile-time type safety
- Null safety enforced by Dart
- IDE autocompletion for field access
- No runtime casting errors
- Freezed generates `copyWith`, `==`, `hashCode`, and JSON serialization

## Timing Strategy (Local Stage Tracking)

**Local persistence IS required.** The backend's `last_update_age_secs` does NOT reset when the onboarding stage changes - it only tracks when the device was last seen/updated. To accurately measure time spent in the current stage, we need:

- **StageTimestampTracker** with SharedPreferences
- Record timestamp when device enters a new stage
- Calculate elapsed time locally per stage
- Handle stage regressions (log warning, reset timestamp)
- 7-day auto-cleanup for stale records

### Storage Schema (StageTimestampTracker)

**SharedPreferences Key Format:**
```
onboarding_stage_{deviceType}_{deviceId}
```
Example: `onboarding_stage_ONT_123`

**Value (JSON):**
```json
{
  "stage": 3,
  "max_stages": 6,
  "entered_at": "2024-01-15T10:30:00Z",
  "last_updated": "2024-01-15T10:35:00Z"
}
```

**Cleanup:** Data older than 7 days is auto-purged on app startup.

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Missing JSON config | Throw `StateError` - app cannot start |
| Invalid stage in config | Throw during validation - app cannot start |
| Unknown stage at runtime | Return fallback message: "Stage {n} - Unknown status" |
| Null onboardingStatus | Return `OnboardingState.empty()` - device not yet onboarding |
| Parse error in payload | Freezed handles with null safety - invalid fields become null |
| Stage regression detected | Log warning, clear timestamp cache, re-record new stage |

## Files to Create

### 1. Configuration
| File | Purpose |
|------|---------|
| `FDK/assets/config/onboarding_messages.json` | Stage definitions (copy from ATT-FE-Tool) |

### 2. Models (Freezed)
| File | Purpose |
|------|---------|
| `FDK/lib/features/onboarding/data/models/onboarding_status_payload.dart` | **NEW** - Typed model for WebSocket payload (replaces Map<String, dynamic>) |
| `FDK/lib/features/onboarding/data/models/onboarding_state.dart` | Core state (currentStage, maxStages, isComplete, isOverdue, etc.) |
| `FDK/lib/features/onboarding/data/models/onboarding_display_data.dart` | UI-ready display data with context awareness |
| `FDK/lib/features/onboarding/data/models/onboarding_message.dart` | Stage message (title, description, resolution) |

### 3. Services
| File | Purpose |
|------|---------|
| `FDK/lib/features/onboarding/data/config/onboarding_config.dart` | Configuration loader singleton |
| `FDK/lib/features/onboarding/data/resolvers/message_resolver.dart` | Stage message lookup |
| `FDK/lib/core/utils/safe_parser.dart` | Safe type conversion utilities |

### 4. Providers (Riverpod)
| File | Purpose |
|------|---------|
| `FDK/lib/features/onboarding/presentation/providers/device_onboarding_provider.dart` | Main orchestrator with caching |
| `FDK/lib/features/onboarding/presentation/providers/onboarding_providers.dart` | Supporting providers |

### 5. UI Widgets
| File | Purpose |
|------|---------|
| `FDK/lib/features/onboarding/presentation/widgets/onboarding_status_card.dart` | Card showing stage progress with title/resolution |
| `FDK/lib/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart` | Visual progress bar (currentStage/maxStages) |
| `FDK/lib/features/onboarding/presentation/widgets/onboarding_stage_badge.dart` | Compact badge for device lists |
| `FDK/lib/features/onboarding/presentation/widgets/onboarding_elapsed_time.dart` | Elapsed time display with overdue styling |

## Files to Modify

| File | Changes |
|------|---------|
| `FDK/pubspec.yaml` | Add assets/config/onboarding_messages.json |
| `FDK/lib/main.dart` | Initialize OnboardingConfig |
| `FDK/lib/features/devices/data/models/device_model_sealed.dart` | **CRITICAL FIX**: Remove duplicate `onboardingStatus` field (lines 107-108 have both Map and OnboardingStatusPayload). Keep only the typed `OnboardingStatusPayload?` version. |

### device_model_sealed.dart Fix Details

**Current (BROKEN - duplicate fields):**
```dart
// Lines 107-108 in APModel
@JsonKey(name: 'ap_onboarding_status') Map<String, dynamic>? onboardingStatus,
@JsonKey(name: 'ap_onboarding_status') OnboardingStatusPayload? onboardingStatus,
```

**Fixed (single typed field):**
```dart
// APModel (line ~107)
@JsonKey(name: 'ap_onboarding_status') OnboardingStatusPayload? onboardingStatus,

// ONTModel (line ~139)
@JsonKey(name: 'ont_onboarding_status') OnboardingStatusPayload? onboardingStatus,
```

## Implementation Phases

### Phase 1: Foundation
1. Create `onboarding_messages.json` (copy from ATT-FE-Tool)
2. Create `OnboardingStatusPayload` Freezed model (typed WebSocket payload)
3. Update `device_model_sealed.dart` to use `OnboardingStatusPayload?`
4. Create Freezed models: OnboardingState, OnboardingDisplayData, OnboardingMessage
5. Update `pubspec.yaml` assets
6. Run `build_runner` to generate code

### Phase 2: Services
1. Create `SafeParser` utility
2. Create `OnboardingConfig` loader (singleton, loads JSON, validates)
3. Create `MessageResolver` for stage message lookup

### Phase 3: Providers
1. Create `DeviceOnboardingNotifier` (main Riverpod provider)
2. Create supporting providers for per-device state/display
3. Access typed `OnboardingStatusPayload` from `DeviceModelSealed`

### Phase 4: UI Widgets
1. Create `OnboardingStatusCard` - full card with title, stage progress, resolution text
2. Create `OnboardingProgressIndicator` - visual progress bar
3. Create `OnboardingStageBadge` - compact badge for device list items
4. Create `OnboardingElapsedTime` - elapsed time with overdue warning styling

### Phase 5: Integration
1. Initialize OnboardingConfig in `main.dart`
2. Integration testing

## Key Architecture Decisions

- **Typed WebSocket payload**: Use `OnboardingStatusPayload` Freezed model instead of `Map<String, dynamic>` for type safety at data layer
- **Use Riverpod providers** (not singleton ChangeNotifier like ATT-FE-Tool) to match existing fdk_websocket patterns
- **Use Freezed** for all models (immutable, with JSON serialization)
- **No local persistence**: Use backend's `lastUpdateAgeSecs` directly (no SharedPreferences needed)
- **Per-stage overdue thresholds**: Use `typical_duration_minutes` from config (6 min for most stages, null for success stages)
- **10-second refresh interval** for elapsed time updates (configurable via JSON)
- **Configuration loaded at app startup only** (no hot reload - requires restart for config changes)

## Overdue Detection Logic

```dart
bool get isOverdue {
  if (isComplete) return false;  // Never overdue if complete

  // Use per-stage typical_duration_minutes from config
  final typicalMinutes = config.getMessage(deviceType, stage).typicalDurationMinutes ?? 6;

  // Use backend's lastUpdateAgeSecs directly
  if (lastUpdateAgeSecs != null) {
    return lastUpdateAgeSecs! > (typicalMinutes * 60);
  }

  return false;
}
```

## Reference Files
- `/Users/dominicpham/rgnets/ATT-FE-Tool/lib/services/device_onboarding_service.dart` - Main reference (lines 717-777 for OnboardingState)
- `/Users/dominicpham/rgnets/ATT-FE-Tool/assets/config/onboarding_messages.json` - Configuration to copy

## Test Plan

### Unit Tests
| Layer | Tests |
|-------|-------|
| **OnboardingStatusPayload** | Correct JSON deserialization, null handling for optional fields |
| **Config parsing** | Valid JSON loads, missing fields throw, wrong stage count throws |
| **OnboardingState** | Correct mapping from payload fields, empty state for null/missing data |
| **Overdue computation** | Per-stage thresholds using lastUpdateAgeSecs |
| **Completion logic** | onboardingComplete flag priority, config success stage, numeric fallback |
| **Provider** | Correct state transformation from DeviceModelSealed |

### Integration Tests
1. Load app with valid config → no crashes
2. Device with onboardingStatus → shows correct stage in UI
3. Device without onboardingStatus → no onboarding UI shown
4. WebSocket update with new stage → UI reflects change

## Verification
1. Run `flutter pub run build_runner build` after creating Freezed models
2. Verify OnboardingConfig loads JSON successfully
3. Verify DeviceOnboardingNotifier returns correct state for ONT/AP devices
4. Verify UI widgets render correctly for different stages (in-progress, complete, overdue)
5. Test OnboardingStatusCard with mock data for both ONT and AP device types
