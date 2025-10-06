# Complete Mock Data Alignment Plan with Locations/PMS_Room Strategy

## Executive Summary
Transform all mock data generators to return JSON matching the staging API format exactly, including proper handling of locations/pms_room relationships. This ensures the development environment tests the same JSON parsing logic as staging/production.

## Critical Questions Requiring Answers

Before implementation, we need clarification on:

### 1. PMS_Room Endpoint
**Question**: Is there a separate `GET /api/pms_rooms` endpoint?
- If YES: What is the exact response format?
- If NO: Is pms_room data ONLY available nested in device responses and through `/api/rooms`?

### 2. Null PMS_Room Handling
**Question**: Can devices have null pms_room in production?
- What percentage of devices have null pms_room?
- What does null pms_room mean business-wise?
- Should we simulate this for testing?

### 3. Data Synchronization Rules
**Question**: Must pms_room always match room data exactly?
- Can they diverge (e.g., room renamed but pms_room not updated)?
- Should we test mismatched scenarios?
- Is this a bug or a feature?

### 4. Empty Rooms
**Question**: Should we include rooms with no devices?
- What percentage is realistic?
- Do empty rooms appear in production?
- Are they pre-configured for future use?

### 5. Special Room Types
**Question**: Are there special room types to simulate?
- MDF/IDF rooms (network infrastructure)
- Storage rooms
- Public areas (lobbies, hallways)
- Service rooms

### 6. Authentication Simulation
**Question**: Should mock data simulate authentication?
- You mentioned BEARER header authentication
- Is this handled at the mock data layer or elsewhere?

## Complete Implementation Plan

### Phase 1: Room Data Generation

#### 1.1 Room JSON Structure
```json
{
  "id": 801,
  "name": "(West Wing) 801",
  "room_number": "801",
  "building": "West Wing",
  "floor": 8,
  "description": "Standard Room",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z",
  "devices": [
    {
      "id": 123,
      "name": "AP-WE-801",
      "type": "access_point",
      "online": true
    }
  ]
}
```

#### 1.2 Room Generation Strategy
```dart
Map<String, dynamic> generateRoomJson(int id, String building, int floor, int roomNum) {
  final roomNumber = '${floor}${roomNum.toString().padLeft(2, '0')}';
  return {
    'id': id,
    'name': '($building) $roomNumber',
    'room_number': roomNumber,
    'building': building,
    'floor': floor,
    'description': _getRoomDescription(floor, roomNum),
    'created_at': DateTime.now().subtract(Duration(days: 365)).toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'devices': []  // Populated after device generation
  };
}
```

### Phase 2: Device Data Generation with PMS_Room

#### 2.1 Device JSON with Nested PMS_Room
```json
{
  "id": 123,
  "name": "AP-WE-801",
  "mac": "00:11:22:33:44:55",
  "ip": "10.0.1.101",
  "online": true,
  "model": "RG-AP-520",
  "serial_number": "SN123456",
  "firmware": "3.2.1",
  "last_seen": "2024-01-15T10:30:00Z",
  "pms_room": {
    "id": 801,
    "name": "(West Wing) 801",
    "room_number": "801",
    "building": "West Wing",
    "floor": 8
  }
}
```

#### 2.2 Device Generation with Room Assignment
```dart
Map<String, dynamic> generateDeviceWithRoom(
  int deviceId, 
  Map<String, dynamic> room,
  String deviceType
) {
  return {
    'id': deviceId,
    'name': _generateDeviceName(deviceType, room),
    'mac': _generateMac(deviceId),
    'ip': _generateIp(deviceId),
    'online': _random.nextDouble() > 0.15,  // 85% online
    // ... other fields ...
    'pms_room': room != null ? {
      'id': room['id'],
      'name': room['name'],
      'room_number': room['room_number'],
      'building': room['building'],
      'floor': room['floor']
    } : null  // 5% devices with null pms_room for edge testing
  };
}
```

### Phase 3: Data Variations and Edge Cases

#### 3.1 Distribution Strategy
- **680 rooms** across 5 buildings:
  - North Tower: 150 rooms
  - South Tower: 150 rooms
  - East Wing: 150 rooms
  - West Wing: 150 rooms
  - Central Hub: 80 rooms

- **1920 devices** with variations:
  - 15% offline (`online: false`)
  - 10% with notes
  - 30% missing images (`images: []`)
  - 5% without pms_room (`pms_room: null`)
  - 10% rooms with no devices

#### 3.2 Edge Cases to Test
```dart
void addEdgeCases(List<Map> devices, List<Map> rooms) {
  // Null pms_room (5%)
  final nullPmsCount = (devices.length * 0.05).round();
  for (int i = 0; i < nullPmsCount; i++) {
    devices[i]['pms_room'] = null;
  }
  
  // Empty rooms (10%)
  final emptyRoomCount = (rooms.length * 0.10).round();
  for (int i = 0; i < emptyRoomCount; i++) {
    rooms[i]['devices'] = [];
  }
  
  // Room with many devices (stress test)
  if (rooms.isNotEmpty) {
    final stressRoom = rooms.first;
    for (int i = 0; i < 50; i++) {
      (stressRoom['devices'] as List).add({
        'id': 9000 + i,
        'name': 'STRESS-TEST-$i',
        'type': 'access_point',
        'online': true
      });
    }
  }
}
```

### Phase 4: Response Wrapper Implementation

#### 4.1 API Response Format
```dart
Map<String, dynamic> wrapApiResponse(List<dynamic> results) {
  return {
    'count': results.length,
    'results': results,
  };
}

// Example usage
Map<String, dynamic> getMockRoomsJson() {
  final rooms = generateAllRooms();
  return wrapApiResponse(rooms);
}

Map<String, dynamic> getMockAccessPointsJson() {
  final aps = generateAllAccessPoints();
  return wrapApiResponse(aps);
}
```

### Phase 5: Mock Data Source Updates

#### 5.1 Device Mock Data Source
```dart
@override
Future<List<DeviceModel>> getDevices() async {
  // Get JSON from MockDataService (not entities!)
  final apJson = MockDataService().getMockAccessPointsJson();
  final switchJson = MockDataService().getMockSwitchesJson();
  final ontJson = MockDataService().getMockMediaConvertersJson();
  
  final devices = <DeviceModel>[];
  
  // Parse through proper factory methods
  for (final ap in apJson['results']) {
    final device = Device.fromAccessPointJson(ap);
    devices.add(DeviceModel.fromDomain(device));
  }
  
  // Same for switches and ONTs...
  
  return devices;
}
```

#### 5.2 Room Mock Data Source
```dart
@override
Future<List<RoomModel>> getRooms() async {
  // Get JSON from MockDataService
  final roomsJson = MockDataService().getMockRoomsJson();
  
  final rooms = <RoomModel>[];
  
  // Parse JSON properly
  for (final roomJson in roomsJson['results']) {
    final room = _parseRoomFromJson(roomJson);
    rooms.add(RoomModel.fromDomain(room));
  }
  
  return rooms;
}
```

## Validation Checklist

### Required Validations
- [ ] All field names are snake_case
- [ ] IDs are integers, not strings
- [ ] `online` is boolean, not string `status`
- [ ] `pms_room` is properly nested object
- [ ] `pms_room.id` always exists in rooms (except null cases)
- [ ] Timestamps are ISO 8601 strings
- [ ] Response has `{count, results}` wrapper
- [ ] `Device.fromAccessPointJson()` parses correctly
- [ ] `Device.fromSwitchJson()` parses correctly
- [ ] `Device.fromMediaConverterJson()` parses correctly
- [ ] Room parsing handles all fields
- [ ] Bi-directional relationships work (room→devices, device→pms_room)

### Edge Case Testing
- [ ] Devices with null pms_room parse correctly
- [ ] Rooms with empty devices array
- [ ] Rooms with 50+ devices (stress test)
- [ ] Special characters in names
- [ ] Very long location names
- [ ] Null vs empty string for optional fields
- [ ] Null vs empty array for collections

## Architecture Compliance

### MVVM Pattern ✓
- Changes only in Model layer
- JSON parsing in factory methods
- ViewModels unaffected
- Views unchanged

### Clean Architecture ✓
- Data sources return proper models
- Domain entities unchanged
- Use cases unaffected
- Proper layer separation

### Dependency Injection ✓
- Mock sources implement same interfaces
- Can be swapped via DI
- No hardcoded dependencies

### Riverpod State Management ✓
- Providers work with both mock and real data
- State management unchanged
- Reactive updates preserved

### go_router Navigation ✓
- No routing changes needed
- Navigation unaffected

## Risk Assessment

**Overall Risk: LOW**

### Risks and Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| JSON parsing bugs | Low | High | Extensive testing with edge cases |
| Performance issues | Low | Medium | Test with 1920 devices |
| Data inconsistency | Low | High | Validation checks for relationships |
| Breaking changes | Very Low | High | Changes isolated to mock layer |

## Implementation Timeline

### Week 1: Core Infrastructure
- Update MockDataService with JSON generation
- Implement room JSON generation
- Add response wrappers

### Week 2: Device Generation
- Implement device JSON generation
- Add pms_room nesting
- Ensure relationships work

### Week 3: Variations & Edge Cases
- Add offline devices
- Add devices with notes
- Add missing images
- Test null pms_room cases

### Week 4: Validation & Testing
- Compare with staging API
- Performance testing
- Edge case validation
- Bug fixes

## Success Metrics

- ✅ Zero JSON parsing bugs reaching staging
- ✅ 100% of Device.fromJson methods tested
- ✅ All field mappings verified
- ✅ Type conversion issues eliminated
- ✅ Nested pms_room structure working
- ✅ Date parsing tested
- ✅ Room-device relationships consistent
- ✅ Edge cases handled gracefully

## Benefits

1. **Early Bug Detection**: JSON parsing issues caught in development
2. **Complete Testing**: Same code path as production
3. **Better Coverage**: 1920 devices vs ~100 in staging
4. **Edge Case Testing**: Scenarios not present in staging
5. **Relationship Validation**: Room-device consistency guaranteed
6. **Performance Testing**: Large dataset handling verified

## Conclusion

This comprehensive plan aligns mock data with the staging API format, including proper handling of locations/pms_room relationships. The plan ensures that:

1. Development environment tests exact same JSON parsing as staging/production
2. Room-device relationships are properly maintained
3. Edge cases are thoroughly tested
4. All architectural patterns are followed

**Confidence Level: 95%** - The remaining 5% depends on answers to the critical questions above.

Once questions are answered, implementation can proceed with high confidence of success.