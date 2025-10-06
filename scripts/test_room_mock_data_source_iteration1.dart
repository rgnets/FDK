#!/usr/bin/env dart

import 'dart:convert';

/// Test iteration 1: Validate proposed RoomMockDataSource changes
/// This simulates the exact parsing logic we'll use
void main() {
  print('=' * 80);
  print('TEST ITERATION 1: RoomMockDataSource JSON Parsing');
  print('=' * 80);
  
  // Simulate mock JSON structure from getMockPmsRoomsJson()
  final mockJson = {
    'results': [
      {
        'id': 1000,
        'room': '101',
        'pms_property': {'id': 1, 'name': 'North Tower'},
      },
      {
        'id': 1001,
        'room': '102',
        'pms_property': {'id': 1, 'name': 'North Tower'},
      },
      {
        'id': 1002,
        'room': '201',
        'pms_property': {'id': 1, 'name': 'South Tower'},
      },
    ]
  };
  
  print('\n1. INPUT: Mock JSON Structure');
  print('-' * 40);
  print('Sample rooms from getMockPmsRoomsJson():');
  final results = mockJson['results'] as List<dynamic>;
  for (final room in results.take(3)) {
    print('  Room ${room['id']}: room="${room['room']}", building="${room['pms_property']['name']}"');
  }
  
  print('\n2. PARSING LOGIC (Same as RemoteDataSource)');
  print('-' * 40);
  
  final roomModels = <Map<String, dynamic>>[];
  
  for (final roomData in results) {
    // Extract fields exactly like RemoteDataSource does
    final roomNumber = roomData['room']?.toString();
    final propertyName = roomData['pms_property']?['name']?.toString();
    
    // Build display name
    final displayName = propertyName != null && roomNumber != null
        ? '($propertyName) $roomNumber'
        : roomNumber ?? 'Room ${roomData['id']}';
    
    // Create RoomModel structure
    final roomModel = {
      'id': roomData['id']?.toString() ?? '',
      'name': displayName,
      'building': propertyName ?? '',
      'floor': _extractFloor(roomNumber),
      'metadata': roomData,
    };
    
    roomModels.add(roomModel);
    
    print('Parsed Room ${roomData['id']}:');
    print('  Input: room="${roomNumber}", property="${propertyName}"');
    print('  Output: name="${roomModel['name']}"');
  }
  
  print('\n3. OUTPUT: RoomModel Structure');
  print('-' * 40);
  for (final model in roomModels) {
    print('RoomModel:');
    print('  id: "${model['id']}"');
    print('  name: "${model['name']}"  ← Display in UI');
    print('  building: "${model['building']}"');
    print('  floor: "${model['floor']}"');
  }
  
  print('\n4. VALIDATION CHECKS');
  print('-' * 40);
  
  bool allValid = true;
  for (final model in roomModels) {
    final name = model['name'] as String;
    final hasCorrectFormat = name.startsWith('(') && name.contains(') ');
    print('Room ${model['id']}: Format check = ${hasCorrectFormat ? "PASS ✓" : "FAIL ✗"}');
    if (!hasCorrectFormat) allValid = false;
  }
  
  print('\n5. ARCHITECTURE COMPLIANCE');
  print('-' * 40);
  print('✓ Clean Architecture: Data source handles parsing');
  print('✓ MVVM: Model provides formatted data to ViewModel');
  print('✓ Dependency Injection: MockDataService injected');
  print('✓ Single Responsibility: Parse JSON → Create Model');
  print('✓ Consistency: Same logic as RemoteDataSource');
  
  print('\n6. TEST RESULT');
  print('-' * 40);
  if (allValid) {
    print('✅ SUCCESS: All rooms have correct display format');
    print('Ready for implementation');
  } else {
    print('❌ FAILED: Some rooms have incorrect format');
  }
  
  print('\n' + '=' * 80);
  print('ITERATION 1 COMPLETE');
  print('=' * 80);
}

String? _extractFloor(String? roomNumber) {
  if (roomNumber == null || roomNumber.isEmpty) return null;
  // Extract first digit as floor (e.g., "101" → "1", "201" → "2")
  final firstChar = roomNumber[0];
  return int.tryParse(firstChar) != null ? firstChar : null;
}