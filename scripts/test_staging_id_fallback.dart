#!/usr/bin/env dart

/// Test why staging is falling back to stringified ID
void main() {
  print('=' * 80);
  print('INVESTIGATING STAGING ID FALLBACK ISSUE');
  print('=' * 80);
  
  print('\n1. ANALYZING THE PARSER CODE:');
  print('-' * 40);
  print('From room_remote_data_source.dart line 72:');
  print('  name: (roomData["name"] ?? "Room \${roomData["id"]}").toString()');
  print('');
  print('This means if roomData["name"] is null, it falls back to "Room <id>"');
  
  print('\n2. WHEN WOULD NAME BE NULL?');
  print('-' * 40);
  print('Possible scenarios:');
  print('  a) API returns null for name field');
  print('  b) API doesn\'t include name field at all');
  print('  c) API returns empty string for name (but empty string is truthy!)');
  
  print('\n3. TESTING FALLBACK LOGIC:');
  print('-' * 40);
  
  // Simulate different API responses
  final testCases = [
    {'id': 128, 'name': '(Interurban) 803'},  // Normal case
    {'id': 129, 'name': null},                 // Null name
    {'id': 130},                               // Missing name field
    {'id': 131, 'name': ''},                   // Empty string
  ];
  
  for (final roomData in testCases) {
    final parsedName = (roomData['name'] ?? 'Room ${roomData['id']}').toString();
    print('Input: $roomData');
    print('  Parsed name: "$parsedName"');
    print('  Falls back? ${roomData['name'] == null ? "YES" : "NO"}');
    print('');
  }
  
  print('\n4. WHAT DOES STAGING API ACTUALLY RETURN?');
  print('-' * 40);
  print('From api-discovery-report.md:');
  print('  Real API returns: {"id": 128, "name": "(Interurban) 803"}');
  print('');
  print('But what if the API sometimes returns incomplete data?');
  print('Or what if there\'s a parsing issue before it reaches the parser?');
  
  print('\n5. CHECKING DATA FLOW TO PARSER:');
  print('-' * 40);
  print('Data flow path:');
  print('  1. API returns JSON');
  print('  2. ApiService parses response');
  print('  3. RoomRemoteDataSource receives response.data');
  print('  4. Checks if response is List or Map with results');
  print('  5. Iterates through results');
  print('  6. Parses each room');
  
  print('\n6. POTENTIAL ISSUES IN STAGING:');
  print('-' * 40);
  print('a) Pagination handling - maybe page_size=0 returns different format?');
  print('b) Some rooms might actually have null names in staging DB');
  print('c) API might return different format under certain conditions');
  print('d) There might be a race condition or caching issue');
  
  print('\n' + '=' * 80);
  print('CONCLUSION: Need to log actual API responses in staging');
  print('=' * 80);
}