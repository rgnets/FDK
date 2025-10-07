#!/usr/bin/env dart

import 'dart:io';

void _write([String? message]) => stdout.writeln(message ?? '');

/// Deep analysis of why staging might be falling back to stringified IDs
void main() {
  _write('=' * 80);
  _write('DEEP ANALYSIS: STAGING FALLBACK TO STRINGIFIED ID');
  _write('=' * 80);

  _write();
  _write('1. UNDERSTANDING THE FALLBACK:');
  _write('-' * 40);
  _write('When we see "Room 128" instead of "(Interurban) 803", it means:');
  _write('  - The parser received roomData["name"] as null or undefined');
  _write(r'  - It fell back to: "Room ${roomData["id"]}"');

  _write();
  _write('2. KEY OBSERVATION:');
  _write('-' * 40);
  _write('The fallback uses the CORRECT ID (128), which means:');
  _write('  ✓ The API response contains the room');
  _write('  ✓ The room has the correct ID');
  _write('  ✗ But the name field is missing or null');

  _write();
  _write('3. CRITICAL CODE PATH:');
  _write('-' * 40);
  _write('room_remote_data_source.dart line 45-46:');
  _write('  final response = await apiService.get<dynamic>(');
  _write('    "/api/pms_rooms.json?page_size=0",');
  _write('  );');
  _write();
  _write('Notice: NO field selection for rooms!');
  _write('Unlike devices which might use &only=... parameter');

  _write();
  _write('4. HYPOTHESIS TESTING:');
  _write('-' * 40);

  _write();
  _write('Hypothesis A: API returns different format with page_size=0');
  _write('  - Maybe returns: [{"id": 128}] without name field');
  _write('  - Test: Need to log raw API response');

  _write();
  _write('Hypothesis B: Room parser gets wrong data structure');
  _write('  - Maybe room data is nested differently');
  _write('  - Test: Log roomData before parsing');

  _write();
  _write('Hypothesis C: Some rooms genuinely have null names in DB');
  _write('  - Staging DB might have incomplete data');
  _write('  - Test: Check specific room IDs that show fallback');

  _write();
  _write('Hypothesis D: Field extraction issue');
  _write('  - The metadata field includes devices which complicates parsing');
  _write('  - Test: Check if _extractDeviceIds affects the room data');

  _write();
  _write('5. LOGGING NEEDED:');
  _write('-' * 40);
  _write('Add these logs to room_remote_data_source.dart:');
  _write();
  _write('1. After line 46 (API call):');
  _write(r'   _logger.d("Raw API response type: ${response.data.runtimeType}");');
  _write(r'   _logger.d("Raw API response: ${response.data}");');
  _write();
  _write('2. Before line 69 (parsing each room):');
  _write(r'   _logger.d("Parsing room data: $roomData");');
  _write(r'   _logger.d("Room name field: ${roomData["name"]}");');

  _write();
  _write('6. POTENTIAL FIXES:');
  _write('-' * 40);

  _write();
  _write('Fix 1: Add defensive logging (temporary)');
  _write('  if (roomData["name"] == null) {');
  _write(r'    _logger.w("Room ${roomData["id"]} has null name!");');
  _write('  }');

  _write();
  _write('Fix 2: Check for empty string as well as null');
  _write('  final rawName = roomData["name"]?.toString();');
  _write('  final name = (rawName?.isNotEmpty == true) ');
  _write('      ? rawName ');
  _write(r'      : "Room ${roomData["id"]}";');

  _write();
  _write('Fix 3: Add more detailed fallback');
  _write('  name: roomData["name"]?.toString() ??');
  _write('        roomData["room_number"]?.toString() ??');
  _write(r'        "Room ${roomData["id"]}";');

  _write();
  _write('=' * 80);
  _write('RECOMMENDATION: Add logging first to understand actual data');
  _write('=' * 80);
}
