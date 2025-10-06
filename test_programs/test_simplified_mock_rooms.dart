#!/usr/bin/env dart

import 'dart:convert';

/// Test program to verify simplified mock room data structure
/// The mock should match what the real API returns: just id and name
void main() {
  print('=' * 80);
  print('TEST: SIMPLIFIED MOCK ROOM DATA STRUCTURE');
  print('=' * 80);
  
  print('\n1. REAL API RESPONSE (from docs):');
  print('-' * 40);
  print('From actual staging API pms_rooms.json:');
  print('{');
  print('  "id": 128,');
  print('  "name": "(Interurban) 803"');
  print('}');
  print('');
  print('That\'s it! Just two fields.');
  
  print('\n2. WHAT MOCK SHOULD GENERATE:');
  print('-' * 40);
  
  // Generate simplified mock data matching real API
  final simplifiedMockRooms = [
    {'id': 1000, 'name': '(North Tower) 101'},
    {'id': 1001, 'name': '(North Tower) 102'},
    {'id': 1002, 'name': '(North Tower) 103'},
    {'id': 1003, 'name': '(South Tower) 201'},
    {'id': 1004, 'name': '(South Tower) 202'},
    {'id': 1005, 'name': '(Central Hub) 301'},
    {'id': 1006, 'name': '(West Wing) 401'},
    {'id': 1007, 'name': '(East Wing) 501'},
  ];
  
  for (final room in simplifiedMockRooms) {
    print(json.encode(room));
  }
  
  print('\n3. PARSER SIMPLIFICATION:');
  print('-' * 40);
  print('OLD (complex with fallbacks):');
  print('  name: (roomData["room"] ?? roomData["name"] ?? roomData["room_number"] ?? "Room \${id}").toString()');
  print('');
  print('NEW (simple, matches API):');
  print('  name: (roomData["name"] ?? "Room \${id}").toString()');
  
  print('\n4. TESTING PARSER WITH SIMPLIFIED DATA:');
  print('-' * 40);
  
  for (final roomData in simplifiedMockRooms) {
    // Simulate the simplified parser
    final parsedName = (roomData['name'] ?? 'Room ${roomData['id']}').toString();
    print('Room ${roomData['id']}: "$parsedName"');
  }
  
  print('\n5. BENEFITS OF SIMPLIFICATION:');
  print('-' * 40);
  print('✓ Mock matches real API exactly');
  print('✓ No unnecessary fields (building, floor, room_number, etc.)');
  print('✓ Parser only checks fields that actually exist');
  print('✓ Display shows exactly what API returns');
  print('✓ No pattern matching or string manipulation');
  
  print('\n6. WHAT UI WILL DISPLAY:');
  print('-' * 40);
  print('Rooms will show exactly as API returns:');
  print('  • "(North Tower) 101"');
  print('  • "(South Tower) 201"');
  print('  • "(Central Hub) 301"');
  print('');
  print('This matches staging which shows "(Interurban) 803"');
  
  print('\n' + '=' * 80);
  print('TEST COMPLETED - Ready to implement');
  print('=' * 80);
}