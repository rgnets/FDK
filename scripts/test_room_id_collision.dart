#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Test for room ID collisions
void main() {
  print('=' * 80);
  print('TESTING ROOM ID COLLISIONS');
  print('=' * 80);
  
  final mockService = MockDataService();
  final pmsRoomsJson = mockService.getMockPmsRoomsJson();
  final results = pmsRoomsJson['results'] as List<dynamic>;
  
  print('\n1. CHECKING FOR DUPLICATE IDS:');
  print('-' * 40);
  
  final idMap = <int, List<String>>{};
  
  for (int i = 0; i < results.length; i++) {
    final room = results[i] as Map<String, dynamic>;
    final id = room['id'] as int;
    final name = room['name'] as String;
    
    if (!idMap.containsKey(id)) {
      idMap[id] = [];
    }
    idMap[id]!.add('Index $i: "$name"');
  }
  
  // Find duplicates
  final duplicates = idMap.entries.where((e) => e.value.length > 1).toList();
  
  if (duplicates.isEmpty) {
    print('✓ No duplicate IDs found');
  } else {
    print('✗ Found ${duplicates.length} duplicate IDs!');
    print('');
    for (final dup in duplicates.take(10)) {
      print('ID ${dup.key} appears ${dup.value.length} times:');
      for (final location in dup.value) {
        print('  - $location');
      }
    }
  }
  
  print('\n2. ID RANGES ANALYSIS:');
  print('-' * 40);
  
  // Check ID ranges for special vs standard rooms
  final specialRooms = results.take(40).toList();
  final standardRooms = results.skip(40).toList();
  
  final specialIds = specialRooms.map((r) => r['id'] as int).toList();
  final standardIds = standardRooms.map((r) => r['id'] as int).toList();
  
  print('Special rooms (first 40):');
  print('  ID range: ${specialIds.reduce((a, b) => a < b ? a : b)} - ${specialIds.reduce((a, b) => a > b ? a : b)}');
  print('  First 5 IDs: ${specialIds.take(5).toList()}');
  
  print('\nStandard rooms (remaining ${standardRooms.length}):');
  if (standardIds.isNotEmpty) {
    print('  ID range: ${standardIds.reduce((a, b) => a < b ? a : b)} - ${standardIds.reduce((a, b) => a > b ? a : b)}');
    print('  First 5 IDs: ${standardIds.take(5).toList()}');
  }
  
  print('\n3. PROBLEM DIAGNOSIS:');
  print('-' * 40);
  
  print('Special rooms start at ID: 1000 (hardcoded in _generateSpecialRooms)');
  print('Standard rooms also start at ID: 1000 (from _generateRooms)');
  print('This causes ID collisions!');
  
  print('\n4. EXPECTED BEHAVIOR:');
  print('-' * 40);
  print('Special rooms should use IDs: 1000-1039 (40 rooms)');
  print('Standard rooms should use IDs: 1040+ (640 rooms)');
  print('Total unique IDs needed: 680');
  
  print('\n' + '=' * 80);
  print('END OF TEST');
  print('=' * 80);
}