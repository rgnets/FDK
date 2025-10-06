# Unified Architecture Implementation Plan

## Executive Summary

This document outlines a comprehensive plan to unify the code paths between development and staging/production environments in the RGNets Field Deployment Kit, while strictly adhering to Clean Architecture principles, MVVM pattern, and best practices for dependency injection using Riverpod.

## Current Problem Analysis

### 1. Different Code Paths
- **Development**: `MockDataService.getMockDevices()` returns `Device` entities directly
- **Staging/Production**: API → JSON → `DeviceModel` → `Device` entity
- **Impact**: Bugs only appear in staging (e.g., missing location in notifications)

### 2. Clean Architecture Violations
- `Device` entity (domain layer) contains JSON parsing logic
- Domain layer has knowledge of external data formats
- Violates dependency rule: domain should not depend on data layer

### 3. Missing Location Data in Staging
- `DeviceRemoteDataSource` extracts location from wrong fields
- Doesn't check `pms_room.name` field where location is actually stored
- Development mock bypasses this bug by setting location directly

## Proposed Solution Architecture

### Core Principles
1. **Single Code Path**: All environments use JSON → DeviceModel → Device
2. **Clean Architecture**: Domain entities have no JSON knowledge
3. **Dependency Injection**: Environment switching through DI container
4. **Interface Segregation**: Data sources implement common interface
5. **MVVM Pattern**: Clear separation between data, logic, and UI

### Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│  DeviceScreen → DeviceViewModel → DeviceState               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                          │
│  Device (entity) ← DeviceRepository (interface)             │
│  * No JSON knowledge                                         │
│  * Pure business entities                                    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         DATA LAYER                           │
│  DeviceRepositoryImpl → DeviceDataSource (interface)        │
│                              ↓                               │
│          ┌───────────────────┴───────────────────┐          │
│          ↓                                       ↓          │
│  DeviceRemoteDataSource              DeviceMockDataSource   │
│  (API → JSON → DeviceModel)          (JSON → DeviceModel)   │
│                                                              │
│  DeviceModel.fromJson() ← Handles all JSON parsing          │
│  DeviceModel.toEntity() → Converts to domain entity         │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Phases

### Phase 1: Create Data Source Interface (2-3 hours)
**Goal**: Establish contract without breaking existing code

#### Step 1.1: Create Abstract Interface
```dart
// lib/features/devices/data/datasources/device_data_source.dart
abstract class DeviceDataSource {
  Future<List<DeviceModel>> getDevices();
  Future<DeviceModel> getDevice(String id);
  Future<List<DeviceModel>> getDevicesByRoom(String roomId);
  Future<List<DeviceModel>> searchDevices(String query);
  Future<DeviceModel> updateDevice(DeviceModel device);
  Future<void> rebootDevice(String deviceId);
  Future<void> resetDevice(String deviceId);
}
```

#### Step 1.2: Update RemoteDataSource
- Rename class to `DeviceRemoteDataSourceImpl`
- Implement `DeviceDataSource` interface
- Add `_extractLocation()` helper method to fix location bug

#### Step 1.3: Fix Location Extraction
```dart
String _extractLocation(Map<String, dynamic> deviceMap) {
  // Primary: Extract from pms_room.name
  if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
    final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
    final pmsRoomName = pmsRoom['name']?.toString();
    if (pmsRoomName != null && pmsRoomName.isNotEmpty) {
      return pmsRoomName;
    }
  }
  // Fallback: Try other fields
  return deviceMap['location']?.toString() ?? 
         deviceMap['room']?.toString() ?? '';
}
```

**Validation**: Staging notifications immediately show location

### Phase 2: Implement Mock Data Source (3-4 hours)
**Goal**: Create mock that uses same JSON parsing as production

#### Step 2.1: Create DeviceMockDataSource
```dart
// lib/features/devices/data/datasources/device_mock_data_source.dart
class DeviceMockDataSourceImpl implements DeviceDataSource {
  final MockDataService mockDataService;
  
  @override
  Future<List<DeviceModel>> getDevices() async {
    final devices = <DeviceModel>[];
    
    // Get JSON from MockDataService
    final apJson = mockDataService.getMockAccessPointsJson();
    final switchJson = mockDataService.getMockSwitchesJson();
    final ontJson = mockDataService.getMockMediaConvertersJson();
    
    // Parse through DeviceModel.fromJson()
    for (final json in apJson['results']) {
      devices.add(_parseAccessPoint(json));
    }
    // ... similar for switches and ONTs
    
    return devices;
  }
  
  DeviceModel _parseAccessPoint(Map<String, dynamic> json) {
    // Extract pms_room data
    int? pmsRoomId;
    String location = '';
    
    if (json['pms_room'] != null && json['pms_room'] is Map) {
      final pmsRoom = json['pms_room'] as Map<String, dynamic>;
      pmsRoomId = pmsRoom['id'] as int?;
      location = pmsRoom['name']?.toString() ?? '';
    }
    
    return DeviceModel.fromJson({
      'id': 'ap_${json['id']}',
      'name': json['name'],
      'type': 'access_point',
      'status': json['online'] == true ? 'online' : 'offline',
      'pms_room_id': pmsRoomId,
      'location': location,
      // ... other fields
    });
  }
}
```

**Validation**: Development uses same JSON parsing as staging

### Phase 3: Refactor Repository (2-3 hours)
**Goal**: Remove environment checks from repository

#### Step 3.1: Update Repository Implementation
```dart
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceDataSource dataSource;  // Interface, not concrete class
  final DeviceLocalDataSource localDataSource;
  
  DeviceRepositoryImpl({
    required this.dataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, List<Device>>> getDevices() async {
    try {
      // No environment check!
      final deviceModels = await dataSource.getDevices();
      final devices = deviceModels.map((m) => m.toEntity()).toList();
      
      // Cache locally
      await localDataSource.cacheDevices(deviceModels);
      
      return Right(devices);
    } catch (e) {
      // Handle errors...
    }
  }
}
```

#### Step 3.2: Update Dependency Injection
```dart
// lib/core/providers/data_providers.dart
final deviceDataSourceProvider = Provider<DeviceDataSource>((ref) {
  if (EnvironmentConfig.isDevelopment) {
    return DeviceMockDataSourceImpl(
      mockDataService: ref.watch(mockDataServiceProvider),
    );
  } else {
    return DeviceRemoteDataSourceImpl(
      apiService: ref.watch(apiServiceProvider),
    );
  }
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(
    dataSource: ref.watch(deviceDataSourceProvider),
    localDataSource: ref.watch(deviceLocalDataSourceProvider),
  );
});
```

**Validation**: Repository is environment-agnostic

### Phase 4: Domain Layer Cleanup (4-5 hours)
**Goal**: Remove JSON knowledge from domain entities

#### Step 4.1: Remove JSON Methods from Device Entity
```dart
// lib/features/devices/domain/entities/device.dart
@freezed
class Device with _$Device {
  const factory Device({
    required String id,
    required String name,
    required String type,
    required String status,
    String? location,
    // ... other fields
  }) = _Device;
  
  // No fromJson methods!
  // No JSON knowledge!
}
```

#### Step 4.2: Move JSON Parsing to Data Layer
```dart
// lib/features/devices/data/mappers/device_json_mapper.dart
class DeviceJsonMapper {
  static DeviceModel fromAccessPointJson(Map<String, dynamic> json) {
    // All JSON parsing logic here
  }
  
  static DeviceModel fromSwitchJson(Map<String, dynamic> json) {
    // Switch-specific parsing
  }
  
  static DeviceModel fromMediaConverterJson(Map<String, dynamic> json) {
    // ONT-specific parsing
  }
}
```

**Validation**: Clean Architecture fully restored

## Testing Strategy

### Unit Tests
- Test each data source implementation independently
- Verify JSON parsing produces correct DeviceModel
- Ensure location extraction works for all device types
- Test repository with mocked data sources

### Integration Tests
- Test full flow: JSON → DeviceModel → Device → UI
- Verify both development and staging paths produce same results
- Test error handling and edge cases

### Regression Tests
- Ensure all existing features still work
- Verify notifications show location
- Check device list displays correctly
- Test search and filtering

## Risk Mitigation

### Gradual Migration
- Each phase can be deployed independently
- Rollback plan for each phase
- Feature flags to enable/disable new code

### Immediate Benefits
- Phase 1 fixes staging location bug immediately
- Each phase improves architecture incrementally
- No big-bang deployment required

## Timeline

| Phase | Duration | Dependencies | Risk Level |
|-------|----------|--------------|------------|
| Phase 1 | 2-3 hours | None | Low - Fixes bug |
| Phase 2 | 3-4 hours | Phase 1 | Low - New code |
| Phase 3 | 2-3 hours | Phase 2 | Medium - Changes DI |
| Phase 4 | 4-5 hours | Phase 3 | Low - Cleanup only |
| **Total** | **11-15 hours** | | |

## Success Criteria

1. **Unified Code Path**: Development and staging use identical parsing logic
2. **Clean Architecture**: Domain layer has no JSON knowledge
3. **Bug Resolution**: Staging shows location in notifications
4. **Maintainability**: Clear separation of concerns
5. **Testability**: Each component testable in isolation
6. **No Regressions**: All existing features continue working

## Recommendations

1. **Start with Phase 1**: Immediately fixes production bug
2. **Test each phase thoroughly**: Don't rush to next phase
3. **Document changes**: Update architecture docs as we go
4. **Monitor staging**: Watch for any unexpected behavior
5. **Consider feature flags**: Allow quick rollback if needed

## Conclusion

This plan provides a systematic approach to unifying our architecture while maintaining Clean Architecture principles. Each phase builds on the previous one, allowing for incremental improvements and reducing risk. The immediate benefit of fixing the staging location bug in Phase 1 provides value while we work on the longer-term architectural improvements.

The end result will be:
- Single, maintainable code path for all environments
- Proper separation of concerns following Clean Architecture
- Easier testing and debugging
- Reduced risk of environment-specific bugs
- Better adherence to MVVM, Riverpod, and dependency injection patterns