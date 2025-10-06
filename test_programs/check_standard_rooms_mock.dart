#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Check standard rooms (not special rooms) in mock data
void main() {
  print('=' * 80);
  print('STANDARD ROOMS IN MOCK DATA');
  print('=' * 80);
  
  final mockService = MockDataService();
  final mockPmsRoomsJson = mockService.getMockPmsRoomsJson();
  final mockResults = mockPmsRoomsJson['results'] as List<dynamic>;
  
  print('\nTotal rooms: ${mockResults.length}');
  print('First 40 are special rooms (lobby, amenities, etc.)');
  print('Remaining are standard rooms');
  
  print('\n1. SPECIAL ROOMS (first 5):');
  print('-' * 40);
  for (int i = 0; i < 5 && i < mockResults.length; i++) {
    final room = mockResults[i] as Map<String, dynamic>;
    print('Room ${i + 1}:');
    print('  id: ${room['id']}');
    print('  name: "${room['name']}"');
    print('  room_number: "${room['room_number']}"');
    print('  room_type: "${room['room_type']}"');
  }
  
  print('\n2. STANDARD ROOMS (starting from index 40):');
  print('-' * 40);
  for (int i = 40; i < 50 && i < mockResults.length; i++) {
    final room = mockResults[i] as Map<String, dynamic>;
    print('Room ${i + 1}:');
    print('  id: ${room['id']}');
    print('  name: "${room['name']}"');
    print('  room_number: "${room['room_number']}"');
    print('  building: "${room['building']}"');
    print('  floor: ${room['floor']}');
    print('  room_type: "${room['room_type']}"');
  }
  
  print('\n3. ANALYSIS OF STANDARD ROOMS:');
  print('-' * 40);
  if (mockResults.length > 40) {
    final standardRoom = mockResults[40] as Map<String, dynamic>;
    print('Example standard room:');
    print('  name field: "${standardRoom['name']}"');
    print('  room_number field: "${standardRoom['room_number']}"');
    print('');
    print('The "name" field contains: Full location like "(North Tower) 101"');
    print('The "room_number" field contains: Just the number like "101"');
    print('');
    print('Remote data source will use "name" field, showing "(North Tower) 101"');
    print('User wants just "101"');
  }
  
  print('\n4. THE REAL QUESTION:');
  print('-' * 40);
  print('What does the staging/production API actually return?');
  print('  - Does it have a "name" field?');
  print('  - Does it have a "room_number" field?');
  print('  - What format is each field in?');
  print('');
  print('The mock should match the real API structure!');
  
  print('\n' + '=' * 80);
  print('END OF ANALYSIS');
  print('=' * 80);
}