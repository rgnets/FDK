#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Test what mock data is actually being generated and how it flows
void main() {
  print('=' * 80);
  print('INVESTIGATING ROOM DATA FLOW ISSUE');
  print('=' * 80);
  
  final mockService = MockDataService();
  
  print('\n1. CHECKING MOCK PMS ROOMS DATA:');
  print('-' * 40);
  
  final pmsRoomsJson = mockService.getMockPmsRoomsJson();
  final results = pmsRoomsJson['results'] as List<dynamic>;
  
  print('Total rooms: ${results.length}');
  print('\nFirst 5 rooms:');
  for (int i = 0; i < 5 && i < results.length; i++) {
    final room = results[i] as Map<String, dynamic>;
    print('\nRoom ${i + 1}:');
    print('  Raw data: $room');
    print('  ID: ${room['id']} (type: ${room['id'].runtimeType})');
    print('  Name: ${room['name']} (type: ${room['name'].runtimeType})');
  }
  
  print('\n\n2. CHECKING STANDARD ROOMS (after special rooms):');
  print('-' * 40);
  
  if (results.length > 40) {
    for (int i = 40; i < 45 && i < results.length; i++) {
      final room = results[i] as Map<String, dynamic>;
      print('\nRoom at index $i:');
      print('  ID: ${room['id']}');
      print('  Name: "${room['name']}"');
    }
  }
  
  print('\n\n3. ANALYZING ROOM NAME FORMAT:');
  print('-' * 40);
  
  // Check what format the names are in
  final sampleRooms = results.take(50).toList();
  int buildingFormatCount = 0;
  int simpleNumberCount = 0;
  
  for (final room in sampleRooms) {
    final name = room['name'] as String;
    if (name.startsWith('(') && name.contains(')')) {
      buildingFormatCount++;
      print('  Building format: "$name"');
      if (buildingFormatCount >= 3) break;
    } else if (RegExp(r'^\d+$').hasMatch(name)) {
      simpleNumberCount++;
      print('  Simple number: "$name"');
    }
  }
  
  print('\nFormat analysis:');
  print('  Building format "(Building) Room": $buildingFormatCount rooms');
  print('  Simple number format: $simpleNumberCount rooms');
  
  print('\n\n4. TRACING THE ISSUE:');
  print('-' * 40);
  
  // Let's check what the underlying Room entities look like
  print('Checking underlying room generation...');
  
  // The mock service generates rooms internally - let's see what format they use
  // We need to check the _generateRooms() method
  
  print('\n' + '=' * 80);
  print('END OF INVESTIGATION');
  print('=' * 80);
}