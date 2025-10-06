# Mock Data Alignment Plan - Comprehensive Implementation Strategy

## Executive Summary
Transform all mock data generators to return JSON matching the staging API format exactly, ensuring development environment tests the same JSON parsing logic as staging/production.

## Critical Issue Identified
**Current State**: Mock data returns Dart entities directly, bypassing JSON parsing
**Problem**: JSON parsing bugs only discovered in staging/production
**Solution**: Mock data must return JSON that goes through same parsing as API responses

## Implementation Plan

### Phase 1: Core MockDataService Transformation

#### 1.1 Add JSON Generation Methods
**File**: `lib/core/services/mock_data_service.dart`

**New Methods Required**:
```dart
// Generate JSON for access point matching API exactly
Map<String, dynamic> generateAccessPointJson(int id, Room room)
Map<String, dynamic> generateSwitchJson(int id, Room room)  
Map<String, dynamic> generateMediaConverterJson(int id, Room room)

// Wrap in API response format
Map<String, dynamic> wrapApiResponse(List<dynamic> results)

// Main JSON getters
Map<String, dynamic> getMockAccessPointsJson()
Map<String, dynamic> getMockSwitchesJson()
Map<String, dynamic> getMockMediaConvertersJson()
Map<String, dynamic> getMockRoomsJson()
```

**JSON Structure Requirements**:
- Integer IDs (not strings)
- Snake_case field names (mac, ip, serial_number)
- Boolean `online` field (not string status)
- Nested `pms_room` object with {id, name, room_number, building, floor}
- ISO 8601 timestamps as strings
- Wrapped in {count, results} structure

#### 1.2 Data Variations for Testing
- 1920 total devices (vs ~100 in staging for better coverage)
- 680 rooms across 5 buildings
- 15% devices offline
- 10% devices with notes  
- 30% devices missing images
- Mix of device types (AP, Switch, ONT)
- Edge cases: null fields, empty arrays, special characters

### Phase 2: Update Mock Data Sources

#### 2.1 Device Mock Data Source
**File**: `lib/features/devices/data/datasources/device_mock_data_source.dart`

**Change**: Parse JSON through Device factory methods
```dart
Future<List<DeviceModel>> getDevices() async {
  final apJson = MockDataService().getMockAccessPointsJson();
  final switchJson = MockDataService().getMockSwitchesJson();
  final ontJson = MockDataService().getMockMediaConvertersJson();
  
  // Parse through Device.fromAccessPointJson(), etc.
  // This tests the exact same parsing logic as staging
}
```

#### 2.2 Room Mock Data Source  
**File**: `lib/features/rooms/data/datasources/room_mock_data_source.dart`

**Change**: Parse JSON for rooms
```dart
Future<List<RoomModel>> getRooms() async {
  final roomsJson = MockDataService().getMockRoomsJson();
  
  // Parse JSON matching API structure
  // Test date parsing, nested arrays, etc.
}
```

### Phase 3: Field Mapping Updates

#### 3.1 Required Field Mappings
| API Field | Current Mock Field | Action Required |
|-----------|-------------------|-----------------|
| id (int) | id (String) | Convert to integer |
| mac | macAddress | Rename to snake_case |
| ip | ipAddress | Rename to snake_case |
| serial_number | serialNumber | Rename to snake_case |
| online (bool) | status (String) | Change type and field |
| pms_room (object) | flat fields | Create nested object |
| last_seen (ISO string) | DateTime object | Convert to ISO string |

#### 3.2 Response Structure
```json
{
  "count": 1234,
  "results": [
    {
      "id": 123,  // Integer
      "name": "AP-WE-801",
      "mac": "00:11:22:33:44:55",  // snake_case
      "ip": "10.0.1.101",  // snake_case
      "online": true,  // Boolean
      "pms_room": {  // Nested object
        "id": 801,
        "name": "(West Wing) 801",
        "room_number": "801",
        "building": "West Wing",
        "floor": 8
      }
    }
  ]
}
```

### Phase 4: Testing & Validation

#### 4.1 Validation Checklist
- [ ] JSON structure matches staging exactly
- [ ] All field names are snake_case
- [ ] IDs are integers
- [ ] online is boolean
- [ ] pms_room is nested object
- [ ] Timestamps are ISO 8601 strings
- [ ] Response has {count, results} wrapper
- [ ] Device.fromAccessPointJson() parses correctly
- [ ] Device.fromSwitchJson() parses correctly
- [ ] Device.fromMediaConverterJson() parses correctly
- [ ] Room parsing works correctly
- [ ] Relationships maintained (device.pms_room.id == room.id)

#### 4.2 Test Scenarios
1. Normal devices with all fields
2. Offline devices
3. Devices with notes
4. Devices without images
5. Null/empty fields
6. Special characters in text fields
7. Large dataset performance (1920 devices)
8. Date parsing edge cases

### Phase 5: Implementation Order

1. **Week 1**: MockDataService JSON generation
   - Add JSON generation methods
   - Add response wrapper
   - Test JSON structure

2. **Week 2**: Update data sources
   - Update device mock data source
   - Update room mock data source
   - Verify parsing works

3. **Week 3**: Add variations & edge cases
   - Add offline devices
   - Add devices with notes
   - Add missing images
   - Test edge cases

4. **Week 4**: Final validation
   - Compare with staging API
   - Performance testing
   - Bug fixes

## Architectural Compliance

### MVVM Pattern
- ✅ Changes only in Model layer
- ✅ ViewModels unaffected
- ✅ Views unchanged

### Clean Architecture
- ✅ Data sources properly return models
- ✅ Domain entities unchanged
- ✅ Use cases unaffected
- ✅ Layer separation maintained

### Dependency Injection
- ✅ Mock sources implement same interfaces
- ✅ Can be swapped via DI
- ✅ No hardcoded dependencies

### Riverpod State Management
- ✅ Providers work with both mock and real data
- ✅ State management unchanged
- ✅ Reactive updates preserved

### go_router
- ✅ No routing changes needed
- ✅ Navigation unaffected

## Risk Assessment

**Risk Level**: LOW

**Mitigations**:
- Changes isolated to mock data layer
- No impact on production code
- Gradual rollout possible
- Easy rollback if issues

## Benefits

1. **Early Bug Detection**: JSON parsing issues caught in development
2. **Better Testing**: Same code path as production
3. **Improved Parity**: Development matches staging/production
4. **More Test Coverage**: 1920 devices vs ~100 in staging
5. **Edge Case Testing**: Variations not present in staging

## Success Metrics

- Zero JSON parsing bugs reaching staging
- 100% of Device.fromJson methods tested
- All field mappings verified
- Type conversion issues eliminated
- Nested structure parsing working
- Date parsing tested

## Conclusion

This comprehensive plan will align mock data with the staging API format, ensuring that development environment tests the exact same JSON parsing logic as staging/production. This will catch bugs earlier, improve development/staging parity, and provide more comprehensive testing with greater data variation.