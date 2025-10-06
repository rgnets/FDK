#!/usr/bin/env dart

import 'dart:convert';
import '../lib/core/services/mock_data_service.dart';

/// Diagnose what room data is actually being shown vs what we expect
void main() {
  print('=' * 80);
  print('DIAGNOSING ROOM DISPLAY ISSUE IN DEVELOPMENT MODE');
  print('=' * 80);
  
  final mockService = MockDataService();
  
  print('\n1. CHECKING MOCK ROOMS (Entity Level)');
  print('-' * 40);
  
  // Get the Room entities that mock_data_source uses
  final mockRooms = mockService.getMockRooms();
  print('Total Room entities: ${mockRooms.length}');
  
  // Show first 5 Room entities
  print('\nFirst 5 Room entities:');
  for (int i = 0; i < 5 && i < mockRooms.length; i++) {
    final room = mockRooms[i];
    print('Room ${i + 1}:');
    print('  id: "${room.id}"');
    print('  name: "${room.name}"');
    print('  building: "${room.building}"');
    print('  location: "${room.location}"');
    print('  description: "${room.description}"');
    print('  deviceIds: ${room.deviceIds}');
  }
  
  print('\n2. CHECKING PMS ROOMS JSON (API Response Level)');
  print('-' * 40);
  
  // Get the JSON that remote_data_source would parse
  final pmsRoomsJson = mockService.getMockPmsRoomsJson();
  final results = pmsRoomsJson['results'] as List<dynamic>;
  print('Total PMS room JSON objects: ${results.length}');
  
  // Show first 5 PMS room JSON objects
  print('\nFirst 5 PMS room JSON objects:');
  for (int i = 0; i < 5 && i < results.length; i++) {
    final roomJson = results[i] as Map<String, dynamic>;
    print('Room ${i + 1}:');
    print('  id: ${roomJson['id']}');
    print('  room: "${roomJson['room']}"');
    if (roomJson['pms_property'] != null) {
      final property = roomJson['pms_property'] as Map<String, dynamic>;
      print('  pms_property.name: "${property['name']}"');
    }
    
    // Show what display name SHOULD be
    final roomNumber = roomJson['room']?.toString();
    final propertyName = roomJson['pms_property']?['name']?.toString();
    final displayName = propertyName != null && roomNumber != null
        ? '($propertyName) $roomNumber'
        : roomNumber ?? 'Room ${roomJson['id']}';
    print('  Expected display: "$displayName"');
  }
  
  print('\n3. COMPARING ENTITY vs JSON DATA');
  print('-' * 40);
  
  // Check if Room entity names match expected display format
  int matchingFormat = 0;
  int notMatchingFormat = 0;
  
  for (int i = 0; i < 5 && i < mockRooms.length && i < results.length; i++) {
    final room = mockRooms[i];
    final roomJson = results[i] as Map<String, dynamic>;
    
    // Calculate expected display from JSON
    final roomNumber = roomJson['room']?.toString();
    final propertyName = roomJson['pms_property']?['name']?.toString();
    final expectedDisplay = propertyName != null && roomNumber != null
        ? '($propertyName) $roomNumber'
        : roomNumber ?? 'Room ${roomJson['id']}';
    
    final matches = room.name == expectedDisplay;
    
    print('Room ${room.id}:');
    print('  Entity name: "${room.name}"');
    print('  Expected: "$expectedDisplay"');
    print('  Match: ${matches ? "YES ✓" : "NO ✗"}');
    
    if (matches) {
      matchingFormat++;
    } else {
      notMatchingFormat++;
    }
  }
  
  print('\n4. DATA FLOW PATH IN DEVELOPMENT');
  print('-' * 40);
  
  print('Development mode data flow:');
  print('1. RoomRepositoryImpl.getRooms() → checks isDevelopment');
  print('2. If true → calls mockDataSource.getRooms()');
  print('3. RoomMockDataSource uses mockDataService.getMockRooms()');
  print('4. Returns Room entities directly (NOT parsing JSON)');
  print('5. Room entities have .name field that should be displayed');
  
  print('\n5. PROBLEM IDENTIFICATION');
  print('-' * 40);
  
  if (notMatchingFormat > 0) {
    print('❌ PROBLEM FOUND:');
    print('Room entities have different names than expected display format!');
    print('');
    print('The issue is that:');
    print('- getMockRooms() returns Room entities with .name field');
    print('- These names may not be in "(Building) Room" format');
    print('- The mock_data_source uses these entities DIRECTLY');
    print('- It does NOT parse the JSON from getMockPmsRoomsJson()');
    print('');
    print('Solution: The Room entities in getMockRooms() need to have');
    print('their .name field formatted as "(Building) Room"');
  } else if (mockRooms.isEmpty) {
    print('❌ PROBLEM: No mock rooms found!');
  } else {
    print('✓ Room entity names appear to match expected format');
  }
  
  print('\n6. SAMPLE OF ROOM ENTITY NAMES');
  print('-' * 40);
  
  // Show a wider sample to see the pattern
  print('Sample of actual Room entity names:');
  for (int i = 0; i < 20 && i < mockRooms.length; i += 4) {
    final room = mockRooms[i];
    print('  ${room.id}: "${room.name}"');
  }
  
  print('\n' + '=' * 80);
  print('DIAGNOSIS COMPLETE');
  print('=' * 80);
}