#!/usr/bin/env dart

import 'dart:io';

void _write([String? message]) => stdout.writeln(message ?? '');

/// Analyze why development shows 3 lines while staging shows 2 lines
void main() {
  _write('=' * 80);
  _write('ANALYZING ROOM LIST DISPLAY LINES');
  _write('=' * 80);

  _write();
  _write('1. UI STRUCTURE (rooms_screen.dart lines 148-161)');
  _write('-' * 40);
  _write('The UnifiedListItem shows:');
  _write('  Line 1: title (roomVm.name)');
  _write('  Line 2+: subtitleLines array');
  _write();
  _write('subtitleLines construction:');
  _write('  IF roomVm.locationDisplay.isNotEmpty THEN');
  _write('    ADD line with locationDisplay');
  _write('  ALWAYS ADD line with device count');

  _write();
  _write('2. LOCATION DISPLAY LOGIC (room_view_models.dart lines 34-43)');
  _write('-' * 40);
  _write('locationDisplay getter:');
  _write('  IF building != null → adds building');
  _write(r'  IF floor != null → adds "Floor $floor"');
  _write('  Returns: parts.join(" ")');
  _write();
  _write('Example outputs:');
  _write('  building="North Tower", floor=1 → "North Tower Floor 1"');
  _write('  building=null, floor=1 → "Floor 1"');
  _write('  building="North Tower", floor=null → "North Tower"');
  _write('  building=null, floor=null → "" (empty string)');

  _write();
  _write('3. DATA FLOW ANALYSIS');
  _write('-' * 40);

  _write('DEVELOPMENT (after our fix):');
  _write('  RoomMockDataSource parses JSON:');
  _write('    - Sets name: "(North Tower) 101"');
  _write('    - Sets building: "North Tower"');
  _write('    - Sets floor: "1" (extracted from room number)');
  _write('  RoomViewModel gets:');
  _write('    - name: "(North Tower) 101"');
  _write('    - building: "North Tower"');
  _write('    - floor: "1"');
  _write('    - locationDisplay: "North Tower Floor 1" ← NOT EMPTY!');
  _write('  UI shows 3 lines:');
  _write('    1. "(North Tower) 101"');
  _write('    2. "North Tower Floor 1" ← EXTRA LINE!');
  _write('    3. "X/Y devices online"');

  _write();
  _write('STAGING:');
  _write('  RemoteDataSource parses JSON:');
  _write('    - Sets name: "(Interurban) 803"');
  _write('    - Sets building: "" (empty or null)');
  _write('    - Sets floor: "" (empty or null)');
  _write('  RoomViewModel gets:');
  _write('    - name: "(Interurban) 803"');
  _write('    - building: null or empty');
  _write('    - floor: null or empty');
  _write('    - locationDisplay: "" ← EMPTY!');
  _write('  UI shows 2 lines:');
  _write('    1. "(Interurban) 803"');
  _write('    2. "X/Y devices online"');

  _write();
  _write('4. THE PROBLEM');
  _write('-' * 40);
  _write('Development sets building and floor fields, causing locationDisplay');
  _write('to return a non-empty string, which adds an extra line to the UI.');
  _write();
  _write('Staging does NOT set building and floor (or sets them empty),');
  _write('so locationDisplay returns empty string and no extra line is added.');

  _write();
  _write('5. WHY THIS HAPPENS');
  _write('-' * 40);
  _write('In RoomMockDataSource (after our fix):');
  _write('  building: propertyName ?? "" → "North Tower"');
  _write('  floor: _extractFloor(roomNumber) → "1"');
  _write();
  _write('In RemoteDataSource:');
  _write('  building: roomData["building"]?.toString() ?? ""');
  _write('  floor: roomData["floor"]?.toString() ?? ""');
  _write('  → The API likely does NOT return building/floor fields!');

  _write();
  _write('6. THE ROOT CAUSE');
  _write('-' * 40);
  _write('The real API (staging) does not include "building" or "floor" fields');
  _write('in the room data, so these remain empty/null.');
  _write();
  _write('Our mock data source is setting these fields from the parsed data,');
  _write('causing the extra location line to appear.');
  _write();
  _write('Since the room name already contains "(Building) Room" format,');
  _write('the separate building/floor fields are redundant!');

  _write();
  _write('7. SOLUTION');
  _write('-' * 40);
  _write('RoomMockDataSource should NOT set building and floor fields');
  _write('(or set them to empty) to match staging behavior.');
  _write();
  _write('The display name already contains all needed information:');
  _write('  "(North Tower) 101" - no need for separate location line');

  _write();
  _write('=' * 80);
  _write('ANALYSIS COMPLETE');
  _write('=' * 80);
}
