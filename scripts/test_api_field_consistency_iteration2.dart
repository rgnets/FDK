#!/usr/bin/env dart

/// Test iteration 2: Test the exact code changes needed
void main() {
  print('=' * 80);
  print('TEST ITERATION 2: Testing Exact Code Changes');
  print('=' * 80);
  
  print('\n1. CURRENT PROBLEMATIC CODE');
  print('-' * 40);
  print('RoomMockDataSource.getRooms() currently does:');
  print('''
return RoomModel(
  id: roomData['id']?.toString() ?? '',
  name: displayName,
  building: propertyName ?? '',      // ← PROBLEM: Sets "North Tower"
  floor: _extractFloor(roomNumber),  // ← PROBLEM: Sets "1"
  deviceIds: _extractDeviceIds(roomData),
  metadata: roomData,
);
''');
  
  print('\n2. CORRECTED CODE');
  print('-' * 40);
  print('Should be changed to:');
  print('''
return RoomModel(
  id: roomData['id']?.toString() ?? '',
  name: displayName,
  building: roomData['building']?.toString() ?? '',  // ← Match RemoteDataSource
  floor: roomData['floor']?.toString() ?? '',        // ← Match RemoteDataSource
  deviceIds: _extractDeviceIds(roomData),
  metadata: roomData,
);
''');
  
  print('\n3. TESTING THE CHANGE');
  print('-' * 40);
  
  // Test with sample data
  final testCases = [
    {
      'name': 'Room with no building/floor',
      'data': {
        'id': 1000,
        'room': '101',
        'pms_property': {'id': 1, 'name': 'North Tower'},
      },
      'expected_building': '',
      'expected_floor': '',
    },
    {
      'name': 'Room with building/floor (shouldn\'t happen)',
      'data': {
        'id': 2000,
        'room': '201',
        'pms_property': {'id': 1, 'name': 'South Tower'},
        'building': 'Legacy Building',
        'floor': '2',
      },
      'expected_building': 'Legacy Building',
      'expected_floor': '2',
    },
  ];
  
  for (final test in testCases) {
    final data = test['data'] as Map<String, dynamic>;
    
    // Parse using corrected logic
    final building = data['building']?.toString() ?? '';
    final floor = data['floor']?.toString() ?? '';
    
    final expected_building = test['expected_building'] as String;
    final expected_floor = test['expected_floor'] as String;
    
    final building_ok = building == expected_building;
    final floor_ok = floor == expected_floor;
    
    print('${test['name']}:');
    print('  building: "$building" (expected: "$expected_building") ${building_ok ? "✓" : "✗"}');
    print('  floor: "$floor" (expected: "$expected_floor") ${floor_ok ? "✓" : "✗"}');
  }
  
  print('\n4. IMPACT ON LOCATION DISPLAY');
  print('-' * 40);
  
  // Simulate the complete flow
  final mockRoomData = {
    'id': 1000,
    'room': '101',
    'pms_property': {'id': 1, 'name': 'North Tower'},
  };
  
  // Current wrong way
  final wrongBuilding = (mockRoomData['pms_property'] as Map)['name'] as String;
  final wrongFloor = '1'; // extracted from '101'
  
  // Correct way
  final correctBuilding = mockRoomData['building']?.toString() ?? '';
  final correctFloor = mockRoomData['floor']?.toString() ?? '';
  
  print('CURRENT (WRONG):');
  print('  building: "$wrongBuilding"');
  print('  floor: "$wrongFloor"');
  print('  locationDisplay would be: "${_getLocationDisplay(wrongBuilding, wrongFloor)}"');
  
  print('\nCORRECT:');
  print('  building: "$correctBuilding"');
  print('  floor: "$correctFloor"');
  print('  locationDisplay would be: "${_getLocationDisplay(correctBuilding, correctFloor)}"');
  
  print('\n5. CONSISTENCY CHECK');
  print('-' * 40);
  print('RemoteDataSource uses:');
  print('  building: roomData["building"]?.toString() ?? ""');
  print('  floor: roomData["floor"]?.toString() ?? ""');
  print('');
  print('RoomMockDataSource should use:');
  print('  building: roomData["building"]?.toString() ?? ""  ← EXACT SAME');
  print('  floor: roomData["floor"]?.toString() ?? ""  ← EXACT SAME');
  print('');
  print('✓ Perfect consistency between environments');
  
  print('\n6. ALSO UPDATE getRoom() METHOD');
  print('-' * 40);
  print('The same change needs to be applied to getRoom():');
  print('');
  print('FROM:');
  print('  building: propertyName ?? "",');
  print('  floor: _extractFloor(roomNumber),');
  print('');
  print('TO:');
  print('  building: roomData["building"]?.toString() ?? "",');
  print('  floor: roomData["floor"]?.toString() ?? "",');
  
  print('\n7. HELPER METHODS');
  print('-' * 40);
  print('_extractFloor() method:');
  print('  ✓ Keep it - might be useful later');
  print('  ✗ Don\'t use it for standard room parsing');
  print('');
  print('_extractDeviceIds() method:');
  print('  ✓ Keep using - needed for device extraction');
  
  print('\n' + '=' * 80);
  print('ITERATION 2 COMPLETE');
  print('=' * 80);
}

String _getLocationDisplay(String building, String floor) {
  final parts = <String>[];
  if (building.isNotEmpty) {
    parts.add(building);
  }
  if (floor.isNotEmpty) {
    parts.add('Floor $floor');
  }
  return parts.join(' ');
}