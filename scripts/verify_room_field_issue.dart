#!/usr/bin/env dart

/// Verify the room field vs name field issue
void main() {
  print('=' * 80);
  print('CRITICAL DISCOVERY: ROOM FIELD vs NAME FIELD');
  print('=' * 80);
  
  print('\n1. WHAT THE STAGING API ACTUALLY RETURNS:');
  print('-' * 40);
  print('Room 128 from API:');
  print('{');
  print('  "id": 128,');
  print('  "room": "803",  <-- NOT "name", but "room"!');
  print('  "pms_property": {"id": 1, "name": "Interurban"},');
  print('  ...');
  print('}');
  
  print('\n2. WHAT OUR PARSER IS LOOKING FOR:');
  print('-' * 40);
  print('From room_remote_data_source.dart line 90:');
  print('  name: (roomData["name"] ?? "Room \${roomData["id"]}").toString()');
  print('');
  print('The parser looks for "name" field, which DOES NOT EXIST!');
  print('So it always falls back to "Room 128"');
  
  print('\n3. THE REAL PROBLEM:');
  print('-' * 40);
  print('API field: "room" = "803"');
  print('Parser expects: "name" (does not exist)');
  print('Result: Falls back to "Room 128"');
  
  print('\n4. WHAT WE SIMPLIFIED INCORRECTLY:');
  print('-' * 40);
  print('OLD parser (before simplification):');
  print('  name: (roomData["room"] ?? roomData["name"] ?? roomData["room_number"] ?? "Room \${id}").toString()');
  print('  This would have worked! It checks "room" first!');
  print('');
  print('NEW parser (after simplification):');
  print('  name: (roomData["name"] ?? "Room \${id}").toString()');
  print('  This fails! Only checks "name" which doesn\'t exist!');
  
  print('\n5. THE FIX:');
  print('-' * 40);
  print('We need to check "room" field, not "name":');
  print('  name: (roomData["room"] ?? "Room \${roomData["id"]}").toString()');
  print('');
  print('Or restore the original logic:');
  print('  name: (roomData["room"] ?? roomData["name"] ?? "Room \${roomData["id"]}").toString()');
  
  print('\n6. WHY THE MOCK WORKS:');
  print('-' * 40);
  print('Mock generates: {"id": 1000, "name": "(North Tower) 101"}');
  print('Parser checks: roomData["name"] - EXISTS in mock!');
  print('Result: Works in development');
  print('');
  print('But staging returns: {"id": 128, "room": "803"}');
  print('Parser checks: roomData["name"] - DOES NOT EXIST!');
  print('Result: Falls back in staging');
  
  print('\n7. PROPER DISPLAY FORMAT:');
  print('-' * 40);
  print('The staging API returns just "803" in the "room" field');
  print('We should display it as "(Interurban) 803" by combining:');
  print('  Building: pms_property.name = "Interurban"');
  print('  Room: room = "803"');
  print('  Display: "(Interurban) 803"');
  
  print('\n' + '=' * 80);
  print('ISSUE IDENTIFIED: Parser checks wrong field name!');
  print('=' * 80);
}