# Device Model Architecture Refactoring Plan

## Overview
Refactor from single `DeviceModel` to sealed class hierarchy with 4 subclasses (`APModel`, `ONTModel`, `SwitchModel`, `WLANModel`), each with a dedicated typed list cache. Domain layer `Device` remains unified.

---

## Current vs Planned Architecture Comparison

### Data Model Layer

| Aspect | CURRENT | PLANNED |
|--------|---------|---------|
| **Model Structure** | Single `DeviceModel` class with all fields | Sealed `DeviceModelSealed` with 4 subclasses |
| **Type Safety** | String `type` field ("access_point", "ont", etc.) | Compile-time type safety via sealed class |
| **Type-Specific Fields** | All fields in one class (many nullable) | Each subclass has only relevant fields |
| **JSON Parsing** | Single `fromJson` factory | Discriminated union via `device_type` key |

```
CURRENT:                              PLANNED:
┌─────────────────────┐               ┌─────────────────────────┐
│     DeviceModel     │               │  DeviceModelSealed      │
├─────────────────────┤               │       (sealed)          │
│ id                  │               ├─────────────────────────┤
│ name                │               │ ┌─────────┐ ┌─────────┐ │
│ type: String        │      →        │ │ APModel │ │ONTModel │ │
│ status              │               │ ├─────────┤ ├─────────┤ │
│ connectionState?    │               │ │ ssid    │ │isRegistered│
│ isRegistered?       │               │ │ channel │ │ ports   │ │
│ ports?              │               │ └─────────┘ └─────────┘ │
│ lastConfigSync?     │               │ ┌──────────┐ ┌─────────┐│
│ ... 40+ fields      │               │ │SwitchModel│WLANModel ││
└─────────────────────┘               │ ├──────────┤ ├─────────┤│
                                      │ │ ports    │ │managedAPs││
                                      │ │configSync│ │ vlan    ││
                                      │ └──────────┘ └─────────┘│
                                      └─────────────────────────┘
```

### Cache Layer - Typed Lists Approach

| Aspect | CURRENT | PLANNED |
|--------|---------|---------|
| **Number of Caches** | 1 unified cache | 4 typed list caches |
| **In-Memory Structure** | `List<DeviceModel>` | `List<APModel>`, `List<ONTModel>`, etc. |
| **Storage Keys** | `device_index` + `cached_device_{id}` per device | 4 simple keys: `cached_ap_devices`, etc. |
| **Storage Format** | Index + individual device entries | Single JSON array per type |
| **Lookup by ID** | Search single list | Use ID-to-Type Index to route to correct list |

```
CURRENT:                              PLANNED:
┌─────────────────────┐               ┌─────────────────────────────────┐
│ DeviceLocalDataSource│              │    4 Typed Data Sources         │
├─────────────────────┤               ├─────────────────────────────────┤
│ In-Memory:          │               │ In-Memory:                      │
│  List<DeviceModel>  │               │  List<APModel> apDevices        │
│                     │      →        │  List<ONTModel> ontDevices      │
│ Storage:            │               │  List<SwitchModel> switchDevices│
│  device_index       │               │  List<WLANModel> wlanDevices    │
│  cached_device_1    │               │                                 │
│  cached_device_2    │               │ Storage (4 keys total):         │
│  cached_device_3    │               │  cached_ap_devices     → [...]  │
│  ...                │               │  cached_ont_devices    → [...]  │
└─────────────────────┘               │  cached_switch_devices → [...]  │
                                      │  cached_wlan_devices   → [...]  │
                                      └─────────────────────────────────┘
```

### Storage Structure Comparison

| Aspect | CURRENT | PLANNED |
|--------|---------|---------|
| **Keys per 100 devices** | 101 keys (1 index + 100 device keys) | 4 keys (1 per type) |
| **Update one device** | Write 1 key | Update in-memory list (storage write on sync/background) |
| **Load all devices** | Read index, then read N device keys | Read 4 JSON arrays |
| **Complexity** | Index management, batch loading | Simple list operations |

### ID-to-Type Index

Since device IDs from the backend are kept unchanged (no prefixes), we maintain a separate index to route lookups:

```dart
// Stored in SharedPreferences
'device_id_to_type_index' → {
  "123": "access_point",
  "456": "ont",
  "789": "switch",
  "abc": "wlan_controller"
}
```

This index is updated when devices are cached and used by the repository to route `getDevice(id)` calls to the correct typed cache.

### Data Flow

```
CURRENT:                                    PLANNED:

WebSocket                                   WebSocket
    │                                           │
    ▼                                           ▼
┌──────────────────────┐                   ┌──────────────────────┐
│ _handleDeviceSnapshot│                   │ _handleDeviceSnapshot│
├──────────────────────┤                   ├──────────────────────┤
│ _deviceSnapshots:    │                   │ switch(resourceType) │
│  access_points: [...]│                   │   'access_points' →  │
│  media_converters:[..]                   │     apCache.update() │
│  switch_devices: [...]                   │   'media_converters'→│
│  wlan_devices: [...]  │                  │     ontCache.update()│
└──────────┬───────────┘                   │   'switch_devices' → │
           │                               │     swCache.update() │
           ▼                               │   'wlan_devices' →   │
    All 4 arrived?                         │     wlanCache.update()│
           │                               └──────────────────────┘
           ▼                                         │
┌──────────────────────┐                            ▼
│ Combine all → cache  │                   Each type updates its
│ to single data source│                   in-memory list immediately
└──────────────────────┘                   Storage persisted on sync complete
```

### Repository Layer

| Aspect | CURRENT | PLANNED |
|--------|---------|---------|
| **Dependencies** | 1 local data source | 4 typed local data sources |
| **getDevices()** | Return single list | Combine 4 typed lists |
| **getDevice(id)** | Search single list | Use ID-to-Type Index → query correct typed list |
| **getDevicesByType()** | Filter in memory | Return typed list directly |

```
CURRENT:                              PLANNED:
┌─────────────────────┐               ┌─────────────────────┐
│  DeviceRepository   │               │   DeviceRepository  │
├─────────────────────┤               ├─────────────────────┤
│                     │               │ apDataSource        │
│ localDataSource ────┼──┐            │ ontDataSource       │
│                     │  │            │ switchDataSource    │
└─────────────────────┘  │            │ wlanDataSource      │
                         │            │ idToTypeIndex       │
                         ▼            └──────────┬──────────┘
              ┌──────────────────┐               │
              │ List<DeviceModel>│               ▼
              └──────────────────┘    ┌──────────────────────┐
                                      │ getDevices():        │
                                      │   [...apDataSource,  │
                                      │    ...ontDataSource, │
                                      │    ...switchDataSource│
                                      │    ...wlanDataSource]│
                                      │                      │
                                      │ getDevice(id):       │
                                      │   type = index[id]   │
                                      │   → query typed cache│
                                      └──────────────────────┘
```

---

## Benefits of Planned Architecture

| Benefit | Description |
|---------|-------------|
| **Type Safety** | Compile-time guarantees - can't access AP-only fields on Switch |
| **Cleaner Models** | Each subclass has only relevant fields, fewer nullable fields |
| **Simple Storage** | 4 JSON arrays instead of 100+ individual keys |
| **Fast In-Memory Updates** | WebSocket updates modify typed lists directly |
| **Independent Type Operations** | Can refresh/clear AP cache without touching Switch cache |
| **Efficient Type Queries** | `getAPDevices()` returns typed list directly, no filtering |
| **Easier Testing** | Test each device type and cache independently |
| **Future Extensibility** | Easy to add new device type (just add subclass + data source) |

## Trade-offs

| Trade-off | Mitigation |
|-----------|------------|
| More files to maintain | Clear naming convention, shared base class |
| Migration complexity | One-time migration service at app startup |
| ID-to-Type Index overhead | Updated during cache operations, minimal overhead |
| More provider dependencies | Clean DI structure via Riverpod |

---

## Phase 1: Create Sealed DeviceModelSealed ✅ COMPLETE

**File:** `FDK/lib/features/devices/data/models/device_model_sealed.dart`

```dart
@Freezed(unionKey: 'device_type')
sealed class DeviceModelSealed with _$DeviceModelSealed {
  const DeviceModelSealed._();

  // Device type constants
  static const String typeAccessPoint = 'access_point';
  static const String typeONT = 'ont';
  static const String typeSwitch = 'switch';
  static const String typeWLAN = 'wlan_controller';

  // Resource type mappings (WebSocket → device type)
  static const Map<String, String> resourceTypeToDeviceType = {
    'access_points': typeAccessPoint,
    'media_converters': typeONT,
    'switch_devices': typeSwitch,
    'wlan_devices': typeWLAN,
  };

  // Storage key for ID-to-Type index
  static const String idTypeIndexKey = 'device_id_to_type_index';

  @FreezedUnionValue('access_point')
  const factory DeviceModelSealed.ap({...}) = APModel;

  @FreezedUnionValue('ont')
  const factory DeviceModelSealed.ont({...}) = ONTModel;

  @FreezedUnionValue('switch')
  const factory DeviceModelSealed.switchDevice({...}) = SwitchModel;

  @FreezedUnionValue('wlan_controller')
  const factory DeviceModelSealed.wlan({...}) = WLANModel;

  factory DeviceModelSealed.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelSealedFromJson(json);
}
```

**Common fields (all types):**
- id, name, status, pmsRoom, pmsRoomId, ipAddress, macAddress, location, lastSeen, metadata, model, serialNumber, firmware, note, images, healthNotices, hnCounts

**Type-specific fields:**
| APModel | ONTModel | SwitchModel | WLANModel |
|---------|----------|-------------|-----------|
| connectionState | isRegistered | host | controllerType |
| signalStrength | switchPort | ports | managedAPs |
| connectedClients | onboardingStatus | lastConfigSync | vlan |
| ssid, channel | ports | lastConfigSyncAttempt | totalUpload/Download |
| maxClients | uptime, phase | cpuUsage, memoryUsage | packetLoss, latency |
| currentUpload/Download | | temperature | restartCount |
| onboardingStatus | | | |

---

## Phase 2: Create Typed List Data Sources

### 2.1 Generic Base Class

**New file:** `FDK/lib/features/devices/data/datasources/typed_device_local_data_source.dart`

```dart
/// Generic base class for type-specific device caches.
/// Uses simple typed lists - no complex indexing.
abstract class TypedDeviceLocalDataSource<T extends DeviceModelSealed> {
  TypedDeviceLocalDataSource({
    required this.storageService,
    required this.storageKey,
    required this.timestampKey,
    this.cacheValidityDuration = const Duration(minutes: 30),
  });

  final StorageService storageService;
  final String storageKey;      // e.g., 'cached_ap_devices'
  final String timestampKey;    // e.g., 'ap_cache_timestamp'
  final Duration cacheValidityDuration;

  /// In-memory typed list - primary working data
  List<T> _devices = [];

  /// Expose immutable view of devices
  List<T> get devices => List.unmodifiable(_devices);

  // Abstract: subclass provides JSON conversion
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T model);

  /// Load from storage into memory
  Future<void> loadFromStorage() async {
    final jsonStr = storageService.getString(storageKey);
    if (jsonStr != null) {
      final list = json.decode(jsonStr) as List<dynamic>;
      _devices = list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  /// Persist current in-memory list to storage
  Future<void> persistToStorage() async {
    final jsonStr = json.encode(_devices.map(toJson).toList());
    await storageService.setString(storageKey, jsonStr);
    await storageService.setString(timestampKey, DateTime.now().toIso8601String());
  }

  /// Update in-memory list (called by WebSocket sync)
  void updateDevices(List<T> devices) {
    _devices = devices;
  }

  /// Update single device in memory
  void updateDevice(T device) {
    final index = _devices.indexWhere((d) => d.deviceId == device.deviceId);
    if (index >= 0) {
      _devices[index] = device;
    } else {
      _devices.add(device);
    }
  }

  /// Get device by ID from memory
  T? getDevice(String id) {
    return _devices.where((d) => d.deviceId == id).firstOrNull;
  }

  /// Remove device from memory
  void removeDevice(String id) {
    _devices.removeWhere((d) => d.deviceId == id);
  }

  /// Clear all devices
  Future<void> clear() async {
    _devices.clear();
    await storageService.remove(storageKey);
    await storageService.remove(timestampKey);
  }

  /// Check if cache is valid
  Future<bool> isCacheValid() async {
    final timestampStr = storageService.getString(timestampKey);
    if (timestampStr == null) return false;
    final timestamp = DateTime.parse(timestampStr);
    return DateTime.now().difference(timestamp) < cacheValidityDuration;
  }
}
```

### 2.2 Lightweight Type-Specific Implementations

Each implementation is minimal - just specifies storage keys and JSON conversion:

```dart
// ap_local_data_source.dart
class APLocalDataSource extends TypedDeviceLocalDataSource<APModel> {
  APLocalDataSource({required super.storageService})
      : super(
          storageKey: 'cached_ap_devices',
          timestampKey: 'ap_cache_timestamp',
        );

  @override
  APModel fromJson(Map<String, dynamic> json) => APModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(APModel model) => model.toJson();
}

// ont_local_data_source.dart
class ONTLocalDataSource extends TypedDeviceLocalDataSource<ONTModel> {
  ONTLocalDataSource({required super.storageService})
      : super(
          storageKey: 'cached_ont_devices',
          timestampKey: 'ont_cache_timestamp',
        );

  @override
  ONTModel fromJson(Map<String, dynamic> json) => ONTModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ONTModel model) => model.toJson();
}

// switch_local_data_source.dart
class SwitchLocalDataSource extends TypedDeviceLocalDataSource<SwitchModel> {
  SwitchLocalDataSource({required super.storageService})
      : super(
          storageKey: 'cached_switch_devices',
          timestampKey: 'switch_cache_timestamp',
        );

  @override
  SwitchModel fromJson(Map<String, dynamic> json) => SwitchModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(SwitchModel model) => model.toJson();
}

// wlan_local_data_source.dart
class WLANLocalDataSource extends TypedDeviceLocalDataSource<WLANModel> {
  WLANLocalDataSource({required super.storageService})
      : super(
          storageKey: 'cached_wlan_devices',
          timestampKey: 'wlan_cache_timestamp',
        );

  @override
  WLANModel fromJson(Map<String, dynamic> json) => WLANModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(WLANModel model) => model.toJson();
}
```

### 2.3 Storage Keys (Simple!)

| Type | Devices Key | Timestamp Key |
|------|-------------|---------------|
| AP | `cached_ap_devices` | `ap_cache_timestamp` |
| ONT | `cached_ont_devices` | `ont_cache_timestamp` |
| Switch | `cached_switch_devices` | `switch_cache_timestamp` |
| WLAN | `cached_wlan_devices` | `wlan_cache_timestamp` |
| Index | `device_id_to_type_index` | - |

---

## Phase 3: Update WebSocketDataSyncService

**File:** `FDK/lib/core/services/websocket_data_sync_service.dart`

1. Inject 4 typed data sources in constructor
2. Route snapshots by resourceType to update in-memory lists:
   ```dart
   void _handleDeviceSnapshot(String resourceType, List<dynamic> data) {
     final deviceType = DeviceModelSealed.getDeviceTypeFromResourceType(resourceType);

     switch (deviceType) {
       case DeviceModelSealed.typeAccessPoint:
         final models = data.map((d) => _normalizeToAPModel(d)).toList();
         _apDataSource.updateDevices(models);
       case DeviceModelSealed.typeONT:
         final models = data.map((d) => _normalizeToONTModel(d)).toList();
         _ontDataSource.updateDevices(models);
       // ... etc
     }

     // Update ID-to-Type index
     _updateIdTypeIndex();
   }
   ```
3. Persist all caches on sync complete or app background:
   ```dart
   Future<void> _persistAllCaches() async {
     await Future.wait([
       _apDataSource.persistToStorage(),
       _ontDataSource.persistToStorage(),
       _switchDataSource.persistToStorage(),
       _wlanDataSource.persistToStorage(),
       _persistIdTypeIndex(),
     ]);
   }
   ```

---

## Phase 4: Update DeviceRepository

**File:** `FDK/lib/features/devices/data/repositories/device_repository.dart`

1. Inject 4 typed data sources
2. Maintain ID-to-Type index for routing
3. Aggregate all devices:
   ```dart
   List<Device> getDevices() {
     return [
       ..._apDataSource.devices.map((d) => d.toEntity()),
       ..._ontDataSource.devices.map((d) => d.toEntity()),
       ..._switchDataSource.devices.map((d) => d.toEntity()),
       ..._wlanDataSource.devices.map((d) => d.toEntity()),
     ];
   }
   ```
4. Route single device lookups:
   ```dart
   Device? getDevice(String id) {
     final type = _idToTypeIndex[id];

     return switch (type) {
       DeviceModelSealed.typeAccessPoint => _apDataSource.getDevice(id)?.toEntity(),
       DeviceModelSealed.typeONT => _ontDataSource.getDevice(id)?.toEntity(),
       DeviceModelSealed.typeSwitch => _switchDataSource.getDevice(id)?.toEntity(),
       DeviceModelSealed.typeWLAN => _wlanDataSource.getDevice(id)?.toEntity(),
       _ => _searchAllCaches(id), // Fallback if not in index
     };
   }
   ```
5. Provide typed getters:
   ```dart
   List<APModel> get apDevices => _apDataSource.devices;
   List<ONTModel> get ontDevices => _ontDataSource.devices;
   List<SwitchModel> get switchDevices => _switchDataSource.devices;
   List<WLANModel> get wlanDevices => _wlanDataSource.devices;
   ```

---

## Phase 5: Update Providers

**File:** `FDK/lib/core/providers/repository_providers.dart`

Add 4 new providers:
```dart
final apLocalDataSourceProvider = Provider<APLocalDataSource>((ref) {
  return APLocalDataSource(storageService: ref.watch(storageServiceProvider));
});

final ontLocalDataSourceProvider = Provider<ONTLocalDataSource>((ref) {
  return ONTLocalDataSource(storageService: ref.watch(storageServiceProvider));
});

final switchLocalDataSourceProvider = Provider<SwitchLocalDataSource>((ref) {
  return SwitchLocalDataSource(storageService: ref.watch(storageServiceProvider));
});

final wlanLocalDataSourceProvider = Provider<WLANLocalDataSource>((ref) {
  return WLANLocalDataSource(storageService: ref.watch(storageServiceProvider));
});
```

Update `deviceRepositoryProvider` and `webSocketDataSyncServiceProvider` to inject all 4.

---

## Phase 6: Migration Service

**New file:** `FDK/lib/core/services/device_cache_migration_service.dart`

- Check if old cache exists (`device_index`, `cached_device_{id}` keys)
- Load old devices, parse type from each
- Distribute to new typed caches
- Persist new caches
- Clean up old cache keys
- Run once at app startup

---

## Files Summary

### Files to Modify
| File | Changes |
|------|---------|
| `websocket_data_sync_service.dart` | Inject 4 data sources, route by type |
| `device_repository.dart` | Aggregate from 4 caches, ID routing |
| `repository_providers.dart` | Add 4 data source providers |
| `websocket_providers.dart` | Update sync service provider |

### New Files to Create
| File | Purpose |
|------|---------|
| `device_model_sealed.dart` | ✅ DONE - Sealed model with 4 subclasses |
| `typed_device_local_data_source.dart` | Generic base class |
| `ap_local_data_source.dart` | AP typed list cache |
| `ont_local_data_source.dart` | ONT typed list cache |
| `switch_local_data_source.dart` | Switch typed list cache |
| `wlan_local_data_source.dart` | WLAN typed list cache |
| `device_cache_migration_service.dart` | One-time migration |

---

## Implementation Order

1. ✅ Phase 1 - Create sealed DeviceModelSealed (COMPLETE)
2. Phase 2 - Create generic base + 4 typed data sources
3. Phase 6 - Add migration service (before breaking changes)
4. Phase 3 - Update WebSocketDataSyncService
5. Phase 4 - Update DeviceRepository
6. Phase 5 - Update providers
7. Run `flutter pub run build_runner build`

---

## Verification

1. Run `flutter pub run build_runner build` to generate Freezed code
2. Run existing tests to verify no regressions
3. Test WebSocket connection - verify devices populate in all 4 typed lists
4. Test app restart - verify migration works and devices load from new caches
5. Verify device list shows all types (AP, ONT, Switch, WLAN)
6. Verify single device detail pages work for each type
7. Verify storage has only 5 keys (4 typed arrays + 1 index) instead of N+1 keys
