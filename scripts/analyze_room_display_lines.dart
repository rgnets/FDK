#!/usr/bin/env dart

/// Analyze why development shows 3 lines while staging shows 2 lines
void main() {
  print('=' * 80);
  print('ANALYZING ROOM LIST DISPLAY LINES');
  print('=' * 80);
  
  print('\n1. UI STRUCTURE (rooms_screen.dart lines 148-161)');
  print('-' * 40);
  print('The UnifiedListItem shows:');
  print('  Line 1: title (roomVm.name)');
  print('  Line 2+: subtitleLines array');
  print('');
  print('subtitleLines construction:');
  print('  IF roomVm.locationDisplay.isNotEmpty THEN');
  print('    ADD line with locationDisplay');
  print('  ALWAYS ADD line with device count');
  
  print('\n2. LOCATION DISPLAY LOGIC (room_view_models.dart lines 34-43)');
  print('-' * 40);
  print('locationDisplay getter:');
  print('  IF building != null → adds building');
  print('  IF floor != null → adds "Floor \$floor"');
  print('  Returns: parts.join(" ")');
  print('');
  print('Example outputs:');
  print('  building="North Tower", floor=1 → "North Tower Floor 1"');
  print('  building=null, floor=1 → "Floor 1"');
  print('  building="North Tower", floor=null → "North Tower"');
  print('  building=null, floor=null → "" (empty string)');
  
  print('\n3. DATA FLOW ANALYSIS');
  print('-' * 40);
  
  print('DEVELOPMENT (after our fix):');
  print('  RoomMockDataSource parses JSON:');
  print('    - Sets name: "(North Tower) 101"');
  print('    - Sets building: "North Tower"');
  print('    - Sets floor: "1" (extracted from room number)');
  print('  RoomViewModel gets:');
  print('    - name: "(North Tower) 101"');
  print('    - building: "North Tower"');
  print('    - floor: "1"');
  print('    - locationDisplay: "North Tower Floor 1" ← NOT EMPTY!');
  print('  UI shows 3 lines:');
  print('    1. "(North Tower) 101"');
  print('    2. "North Tower Floor 1" ← EXTRA LINE!');
  print('    3. "X/Y devices online"');
  
  print('\nSTAGING:');
  print('  RemoteDataSource parses JSON:');
  print('    - Sets name: "(Interurban) 803"');
  print('    - Sets building: "" (empty or null)');
  print('    - Sets floor: "" (empty or null)');
  print('  RoomViewModel gets:');
  print('    - name: "(Interurban) 803"');
  print('    - building: null or empty');
  print('    - floor: null or empty');
  print('    - locationDisplay: "" ← EMPTY!');
  print('  UI shows 2 lines:');
  print('    1. "(Interurban) 803"');
  print('    2. "X/Y devices online"');
  
  print('\n4. THE PROBLEM');
  print('-' * 40);
  print('Development sets building and floor fields, causing locationDisplay');
  print('to return a non-empty string, which adds an extra line to the UI.');
  print('');
  print('Staging does NOT set building and floor (or sets them empty),');
  print('so locationDisplay returns empty string and no extra line is added.');
  
  print('\n5. WHY THIS HAPPENS');
  print('-' * 40);
  print('In RoomMockDataSource (after our fix):');
  print('  building: propertyName ?? "" → "North Tower"');
  print('  floor: _extractFloor(roomNumber) → "1"');
  print('');
  print('In RemoteDataSource:');
  print('  building: roomData["building"]?.toString() ?? ""');
  print('  floor: roomData["floor"]?.toString() ?? ""');
  print('  → The API likely does NOT return building/floor fields!');
  
  print('\n6. THE ROOT CAUSE');
  print('-' * 40);
  print('The real API (staging) does not include "building" or "floor" fields');
  print('in the room data, so these remain empty/null.');
  print('');
  print('Our mock data source is setting these fields from the parsed data,');
  print('causing the extra location line to appear.');
  print('');
  print('Since the room name already contains "(Building) Room" format,');
  print('the separate building/floor fields are redundant!');
  
  print('\n7. SOLUTION');
  print('-' * 40);
  print('RoomMockDataSource should NOT set building and floor fields');
  print('(or set them to empty) to match staging behavior.');
  print('');
  print('The display name already contains all needed information:');
  print('  "(North Tower) 101" - no need for separate location line');
  
  print('\n' + '=' * 80);
  print('ANALYSIS COMPLETE');
  print('=' * 80);
}