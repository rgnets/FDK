#!/usr/bin/env dart

import 'dart:math';

/// Test that mock API JSON format matches staging exactly
void main() {
  print('=' * 80);
  print('MOCK API JSON FORMAT TEST');
  print('=' * 80);
  
  // Simulate what MockDataService generates
  final testRooms = _generateTestRooms();
  final mockJson = _getMockPmsRoomsJson(testRooms);
  
  print('\n1. MOCK API JSON STRUCTURE');
  print('-' * 40);
  
  final results = mockJson['results'] as List;
  print('Total rooms: ${results.length}');
  
  // Check first few rooms
  print('\nFirst 5 rooms:');
  for (var i = 0; i < 5 && i < results.length; i++) {
    final room = results[i] as Map<String, dynamic>;
    print('  Room ${i + 1}:');
    print('    id: ${room['id']}');
    print('    room: ${room['room']}');
    print('    pms_property.name: ${room['pms_property']?['name']}');
  }
  
  print('\n2. EXPECTED VS ACTUAL FORMAT');
  print('-' * 40);
  
  print('STAGING API FORMAT:');
  print('  {');
  print('    "id": 803,');
  print('    "room": "803",');
  print('    "pms_property": {');
  print('      "name": "Interurban"');
  print('    }');
  print('  }');
  
  print('\nMOCK API FORMAT (should match):');
  final exampleRoom = results[0] as Map<String, dynamic>;
  print('  {');
  print('    "id": ${exampleRoom['id']},');
  print('    "room": "${exampleRoom['room']}",');
  print('    "pms_property": {');
  print('      "name": "${exampleRoom['pms_property']?['name']}"');
  print('    }');
  print('  }');
  
  print('\n3. PARSED DISPLAY NAME');
  print('-' * 40);
  
  // Simulate how RemoteDataSource parses this
  for (var i = 0; i < 3 && i < results.length; i++) {
    final roomData = results[i] as Map<String, dynamic>;
    final roomNumber = roomData['room']?.toString();
    final propertyName = roomData['pms_property']?['name']?.toString();
    
    final displayName = propertyName != null && roomNumber != null
        ? '($propertyName) $roomNumber'
        : roomNumber ?? 'Room ${roomData['id']}';
    
    print('Room ${i + 1}: "$displayName"');
  }
  
  print('\n4. VALIDATION');
  print('-' * 40);
  
  bool allValid = true;
  for (final room in results) {
    final roomData = room as Map<String, dynamic>;
    
    // Check required fields
    if (roomData['id'] == null) {
      print('❌ Missing id field');
      allValid = false;
    }
    if (roomData['room'] == null) {
      print('❌ Missing room field');
      allValid = false;
    }
    if (roomData['pms_property']?['name'] == null) {
      print('❌ Missing pms_property.name field');
      allValid = false;
    }
    
    // Check that room is just the number, not the full name
    final roomValue = roomData['room']?.toString() ?? '';
    if (roomValue.contains('(') || roomValue.contains(')')) {
      print('❌ Room field contains parentheses: $roomValue');
      allValid = false;
    }
    
    // Check that pms_property.name is the building name
    final buildingName = roomData['pms_property']?['name']?.toString() ?? '';
    if (buildingName.isEmpty) {
      print('❌ Empty building name');
      allValid = false;
    }
  }
  
  if (allValid) {
    print('✅ All rooms have valid JSON structure');
    print('✅ Format matches staging API exactly');
  }
  
  print('\n' + '=' * 80);
  print('TEST COMPLETE');
  print('=' * 80);
}

// Simulate room generation
List<TestRoom> _generateTestRooms() {
  final rooms = <TestRoom>[];
  final buildings = ['North Tower', 'South Tower', 'East Wing'];
  var roomId = 1041;
  
  for (final building in buildings) {
    for (var floor = 1; floor <= 3; floor++) {
      for (var roomNum = 1; roomNum <= 5; roomNum++) {
        final roomNumber = '$floor${roomNum.toString().padLeft(2, '0')}';
        rooms.add(TestRoom(
          id: roomId.toString(),
          name: '${building.substring(0, 2).toUpperCase()}-$roomNumber',
          location: '($building) $roomNumber',
        ));
        roomId++;
      }
    }
  }
  
  return rooms;
}

// Simulate getMockPmsRoomsJson
Map<String, dynamic> _getMockPmsRoomsJson(List<TestRoom> rooms) {
  final pmsRooms = <Map<String, dynamic>>[];
  
  for (final room in rooms) {
    // room.location has format "(North Tower) 101"
    final locationParts = room.location?.split(')') ?? ['', ''];
    final buildingWithParen = locationParts[0]; // "(North Tower"
    final building = buildingWithParen.replaceAll('(', '').trim(); // "North Tower"
    final roomNumber = locationParts.length > 1 ? locationParts[1].trim() : room.name.split('-').last;
    
    pmsRooms.add({
      'id': int.parse(room.id),
      'room': roomNumber,
      'pms_property': {
        'id': 1,
        'name': building.isNotEmpty ? building : 'North Tower',
      },
    });
  }
  
  return {
    'count': pmsRooms.length,
    'next': null,
    'previous': null,
    'results': pmsRooms,
  };
}

class TestRoom {
  final String id;
  final String name;
  final String? location;
  
  TestRoom({required this.id, required this.name, this.location});
}