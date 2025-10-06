#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/rooms/data/models/room_model.dart';

/// Compare pms_room endpoint structure between mock and expected API format
void main() {
  print('=' * 80);
  print('PMS_ROOM ENDPOINT STRUCTURE COMPARISON');
  print('=' * 80);
  
  // Initialize mock service
  final mockService = MockDataService();
  
  print('\n1. MOCK PMS_ROOM ENDPOINT STRUCTURE:');
  print('-' * 40);
  
  // Get mock PMS rooms JSON
  final mockPmsRoomsJson = mockService.getMockPmsRoomsJson();
  final mockResults = mockPmsRoomsJson['results'] as List<dynamic>;
  
  // Show first room structure
  if (mockResults.isNotEmpty) {
    final firstRoom = mockResults.first as Map<String, dynamic>;
    print('First room from mock:');
    for (final entry in firstRoom.entries) {
      print('  ${entry.key}: ${entry.value}');
    }
  }
  
  print('\n2. REMOTE DATA SOURCE PARSING LOGIC:');
  print('-' * 40);
  print('From room_remote_data_source.dart (line 71):');
  print('  name: (roomData["room"] ?? roomData["name"] ?? roomData["room_number"] ?? "Room \${id}").toString()');
  print('');
  print('Priority order for room name:');
  print('  1. roomData["room"]');
  print('  2. roomData["name"]');
  print('  3. roomData["room_number"]');
  print('  4. Fallback: "Room \${id}"');
  
  print('\n3. WHAT MOCK IS GENERATING vs WHAT WILL BE DISPLAYED:');
  print('-' * 40);
  
  for (int i = 0; i < 5 && i < mockResults.length; i++) {
    final roomData = mockResults[i] as Map<String, dynamic>;
    
    // Simulate remote data source parsing
    final parsedName = (roomData['room'] ?? 
                       roomData['name'] ?? 
                       roomData['room_number'] ?? 
                       'Room ${roomData['id']}').toString();
    
    print('Room ${i + 1}:');
    print('  Mock generates:');
    print('    id: ${roomData['id']}');
    print('    name: "${roomData['name']}"');
    print('    room_number: "${roomData['room_number']}"');
    print('    building: "${roomData['building']}"');
    print('  Remote data source will parse as:');
    print('    Room.name: "$parsedName"');
    print('');
  }
  
  print('\n4. ROOM DISPLAY IN UI:');
  print('-' * 40);
  print('The RoomViewModel displays room.name directly');
  print('So rooms will show as:');
  
  for (int i = 0; i < 3 && i < mockResults.length; i++) {
    final roomData = mockResults[i] as Map<String, dynamic>;
    final parsedName = (roomData['room'] ?? 
                       roomData['name'] ?? 
                       roomData['room_number'] ?? 
                       'Room ${roomData['id']}').toString();
    print('  • "$parsedName"');
  }
  
  print('\n5. PROBLEM IDENTIFIED:');
  print('-' * 40);
  print('Mock is setting:');
  print('  name: "(North Tower) 101" // Full location format');
  print('  room_number: "101" // Just the number');
  print('');
  print('Remote data source looks for "name" field first, so gets "(North Tower) 101"');
  print('User wants just "101" to be displayed');
  
  print('\n6. POTENTIAL SOLUTIONS:');
  print('-' * 40);
  print('Option A: Change mock to put room number in "name" field');
  print('  Pros: Simple, matches what user wants');
  print('  Cons: Might not match real API structure');
  print('');
  print('Option B: Change remote data source parsing priority');
  print('  Look for room_number BEFORE name');
  print('  Pros: Would display just room number');
  print('  Cons: Might break real API compatibility');
  print('');
  print('Option C: Ask what the real API actually returns');
  print('  Need to know actual staging/production API response format');
  
  print('\n7. WHAT STAGING API PROBABLY RETURNS:');
  print('-' * 40);
  print('Based on the parsing logic checking multiple fields, the API likely:');
  print('  - Sometimes has "room" field');
  print('  - Sometimes has "name" field');
  print('  - Sometimes has "room_number" field');
  print('  - Format varies by deployment');
  
  print('\n' + '=' * 80);
  print('END OF COMPARISON');
  print('=' * 80);
}