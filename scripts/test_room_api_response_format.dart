#!/usr/bin/env dart

/// Test to understand room API response format issues
void main() {
  print('=' * 80);
  print('ANALYZING ROOM API RESPONSE FORMAT ISSUE');
  print('=' * 80);
  
  print('\n1. EXPECTED STAGING API RESPONSE:');
  print('-' * 40);
  print('According to docs, with page_size=0, API might return:');
  print('');
  print('Option A - Direct List (like devices):');
  print('[');
  print('  {"id": 128, "name": "(Interurban) 803"},');
  print('  {"id": 129, "name": "(Interurban) 804"},');
  print('  ...');
  print(']');
  print('');
  print('Option B - Map with results (paginated format):');
  print('{');
  print('  "count": 141,');
  print('  "results": [');
  print('    {"id": 128, "name": "(Interurban) 803"},');
  print('    ...');
  print('  ]');
  print('}');
  
  print('\n2. CURRENT PARSER LOGIC:');
  print('-' * 40);
  print('From room_remote_data_source.dart:');
  print('  if (response.data is List) {');
  print('    results = response.data as List<dynamic>;');
  print('  } else if (response.data is Map && response.data["results"] != null) {');
  print('    results = response.data["results"] as List<dynamic>;');
  print('  }');
  
  print('\n3. SIMULATING DIFFERENT RESPONSE SCENARIOS:');
  print('-' * 40);
  
  // Scenario 1: Proper room data
  print('\nScenario 1 - Normal room with name:');
  final room1 = {'id': 128, 'name': '(Interurban) 803'};
  final name1 = (room1['name'] ?? 'Room ${room1['id']}').toString();
  print('  Input: $room1');
  print('  Output: "$name1"');
  
  // Scenario 2: Room without name (causes fallback)
  print('\nScenario 2 - Room missing name field:');
  final room2 = {'id': 129};
  final name2 = (room2['name'] ?? 'Room ${room2['id']}').toString();
  print('  Input: $room2');
  print('  Output: "$name2" <-- FALLBACK!');
  
  // Scenario 3: Room with null name
  print('\nScenario 3 - Room with null name:');
  final room3 = {'id': 130, 'name': null};
  final name3 = (room3['name'] ?? 'Room ${room3['id']}').toString();
  print('  Input: $room3');
  print('  Output: "$name3" <-- FALLBACK!');
  
  // Scenario 4: Empty name (edge case)
  print('\nScenario 4 - Room with empty string name:');
  final room4 = {'id': 131, 'name': ''};
  final name4 = (room4['name'] ?? 'Room ${room4['id']}').toString();
  print('  Input: $room4');
  print('  Output: "$name4" <-- Empty string is truthy, no fallback');
  
  print('\n4. HYPOTHESIS FOR STAGING ISSUE:');
  print('-' * 40);
  print('Possible causes for "Room 128" appearing:');
  print('');
  print('1. API returns rooms without name field');
  print('2. API returns name as null');
  print('3. Response parsing fails before reaching room parser');
  print('4. Different response format than expected');
  print('5. Field selection issue (if only=id is somehow being sent)');
  
  print('\n5. DEBUGGING STEPS:');
  print('-' * 40);
  print('1. Add logging to show raw API response');
  print('2. Log each room data before parsing');
  print('3. Check if page_size=0 behavior differs from paginated');
  print('4. Verify field selection isn\'t stripping name field');
  
  print('\n' + '=' * 80);
  print('END OF ANALYSIS');
  print('=' * 80);
}