#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Complete test of room data flow
void main() {
  print('=' * 80);
  print('COMPLETE ROOM DATA FLOW TEST');
  print('=' * 80);
  
  final mockService = MockDataService();
  
  print('\n1. MOCK DATA GENERATION TEST:');
  print('-' * 40);
  
  final pmsRoomsJson = mockService.getMockPmsRoomsJson();
  final results = pmsRoomsJson['results'] as List<dynamic>;
  
  print('Total rooms: ${results.length}');
  print('Response structure: {count: ${pmsRoomsJson['count']}, results: [...]}');
  
  // Check for ID uniqueness
  final ids = <int>{};
  final duplicateIds = <int>[];
  for (final room in results) {
    final id = room['id'] as int;
    if (!ids.add(id)) {
      duplicateIds.add(id);
    }
  }
  print('Unique IDs: ${ids.length}');
  print('Duplicate IDs: ${duplicateIds.isEmpty ? "None ✓" : duplicateIds}');
  
  print('\n2. ROOM NAME FORMAT CHECK:');
  print('-' * 40);
  
  int nullNameCount = 0;
  int emptyNameCount = 0;
  int buildingFormatCount = 0;
  
  for (final room in results) {
    final name = room['name'];
    if (name == null) {
      nullNameCount++;
      print('  ✗ Room ${room['id']} has null name!');
    } else if (name.toString().isEmpty) {
      emptyNameCount++;
      print('  ✗ Room ${room['id']} has empty name!');
    } else if (name.toString().startsWith('(') && name.toString().contains(')')) {
      buildingFormatCount++;
    }
  }
  
  print('Summary:');
  print('  Null names: $nullNameCount');
  print('  Empty names: $emptyNameCount');
  print('  Building format "(Building) Room": $buildingFormatCount');
  
  print('\n3. SAMPLE DATA VERIFICATION:');
  print('-' * 40);
  
  // Show some special rooms
  print('Special rooms (first 3):');
  for (int i = 0; i < 3 && i < results.length; i++) {
    final room = results[i];
    print('  ${room['id']}: "${room['name']}"');
  }
  
  // Show some standard rooms
  print('\nStandard rooms (starting at 40):');
  for (int i = 40; i < 43 && i < results.length; i++) {
    final room = results[i];
    print('  ${room['id']}: "${room['name']}"');
  }
  
  print('\n4. SIMULATING PARSER:');
  print('-' * 40);
  
  // Simulate what the parser would do
  for (int i = 0; i < 5; i++) {
    final roomData = results[i] as Map<String, dynamic>;
    final parsedName = (roomData['name'] ?? 'Room ${roomData['id']}').toString();
    final wouldFallback = roomData['name'] == null;
    
    print('Room ${roomData['id']}:');
    print('  Raw name: ${roomData['name']}');
    print('  Parsed: "$parsedName"');
    print('  Falls back: ${wouldFallback ? "YES ✗" : "NO ✓"}');
  }
  
  print('\n5. FIELD STRUCTURE CHECK:');
  print('-' * 40);
  
  if (results.isNotEmpty) {
    final firstRoom = results.first as Map<String, dynamic>;
    print('Fields in first room: ${firstRoom.keys.toList()}');
    print('Expected fields: [id, name]');
    
    final hasOnlyExpected = firstRoom.keys.length == 2 && 
                            firstRoom.containsKey('id') && 
                            firstRoom.containsKey('name');
    print('Matches expected: ${hasOnlyExpected ? "YES ✓" : "NO ✗"}');
  }
  
  print('\n6. DEVELOPMENT vs STAGING COMPARISON:');
  print('-' * 40);
  print('Development (mock):');
  print('  Format: "(Building) Room" e.g., "(North Tower) 101"');
  print('  All rooms have names: ${nullNameCount == 0 ? "YES ✓" : "NO ✗"}');
  print('');
  print('Staging (real API):');
  print('  Expected: "(Interurban) 803"');
  print('  Issue: Some show "Room 128" (fallback)');
  print('  Cause: API returns null/missing name for some rooms');
  
  print('\n' + '=' * 80);
  print('TEST COMPLETE');
  print('=' * 80);
}