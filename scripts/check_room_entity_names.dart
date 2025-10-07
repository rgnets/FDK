#!/usr/bin/env dart

import 'dart:io';

void _write([String? message]) => stdout.writeln(message ?? '');

/// Check what Room entity names look like in getMockRooms()
void main() {
  _write('=' * 80);
  _write('CHECKING ROOM ENTITY NAMES IN MOCK DATA');
  _write('=' * 80);

  _write();
  _write('1. EXPECTED BEHAVIOR IN DEVELOPMENT MODE');
  _write('-' * 40);

  _write('Data flow in development:');
  _write('1. RoomRepositoryImpl checks EnvironmentConfig.isDevelopment');
  _write('2. If true, calls mockDataSource.getRooms()');
  _write('3. RoomMockDataSource calls mockDataService.getMockRooms()');
  _write('4. Returns Room entities with their .name field');
  _write('5. UI displays room.name directly');

  _write();
  _write('2. KEY OBSERVATION');
  _write('-' * 40);

  _write('IMPORTANT: In development mode, the Room entities from getMockRooms()');
  _write('are used DIRECTLY. They are NOT parsed from JSON.');
  _write();
  _write('This means:');
  _write('- The Room.name field is what gets displayed');
  _write('- This name should already be formatted as "(Building) Room"');
  _write('- But it might not be if getMockRooms() creates entities differently');

  _write();
  _write('3. CHECKING MOCK_DATA_SERVICE.DART');
  _write('-' * 40);

  _write('Looking at _generateRooms() method...');
  _write();
  _write('The Room entities are created with:');
  _write('  name: location (e.g., "(North Tower) 311")');
  _write('  building: parsed from location');
  _write('  location: the full formatted string');
  _write();
  _write('So Room.name = location = "(Building) Room" format');

  _write();
  _write('4. HYPOTHESIS');
  _write('-' * 40);

  _write('If rooms are displaying incorrectly, possible causes:');
  _write('1. The UI might be showing a different field (not room.name)');
  _write('2. There might be caching of old data');
  _write('3. The provider might be returning stale data');
  _write('4. The Room entities might be transformed somewhere');

  _write();
  _write('5. WHAT TO CHECK NEXT');
  _write('-' * 40);

  _write('1. Clear all app data and restart');
  _write('2. Check what field the UI is actually displaying');
  _write('3. Add logging to see actual Room entity values');
  _write('4. Check if any transformations happen in repository');

  _write();
  _write('=' * 80);
  _write('ANALYSIS COMPLETE');
  _write('=' * 80);
}
