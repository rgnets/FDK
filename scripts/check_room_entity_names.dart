#!/usr/bin/env dart

/// Check what Room entity names look like in getMockRooms()
void main() {
  print('=' * 80);
  print('CHECKING ROOM ENTITY NAMES IN MOCK DATA');
  print('=' * 80);
  
  print('\n1. EXPECTED BEHAVIOR IN DEVELOPMENT MODE');
  print('-' * 40);
  
  print('Data flow in development:');
  print('1. RoomRepositoryImpl checks EnvironmentConfig.isDevelopment');
  print('2. If true, calls mockDataSource.getRooms()');
  print('3. RoomMockDataSource calls mockDataService.getMockRooms()');
  print('4. Returns Room entities with their .name field');
  print('5. UI displays room.name directly');
  
  print('\n2. KEY OBSERVATION');
  print('-' * 40);
  
  print('IMPORTANT: In development mode, the Room entities from getMockRooms()');
  print('are used DIRECTLY. They are NOT parsed from JSON.');
  print('');
  print('This means:');
  print('- The Room.name field is what gets displayed');
  print('- This name should already be formatted as "(Building) Room"');
  print('- But it might not be if getMockRooms() creates entities differently');
  
  print('\n3. CHECKING MOCK_DATA_SERVICE.DART');
  print('-' * 40);
  
  print('Looking at _generateRooms() method...');
  print('');
  print('The Room entities are created with:');
  print('  name: location (e.g., "(North Tower) 311")');
  print('  building: parsed from location');
  print('  location: the full formatted string');
  print('');
  print('So Room.name = location = "(Building) Room" format');
  
  print('\n4. HYPOTHESIS');
  print('-' * 40);
  
  print('If rooms are displaying incorrectly, possible causes:');
  print('1. The UI might be showing a different field (not room.name)');
  print('2. There might be caching of old data');
  print('3. The provider might be returning stale data');
  print('4. The Room entities might be transformed somewhere');
  
  print('\n5. WHAT TO CHECK NEXT');
  print('-' * 40);
  
  print('1. Clear all app data and restart');
  print('2. Check what field the UI is actually displaying');
  print('3. Add logging to see actual Room entity values');
  print('4. Check if any transformations happen in repository');
  
  print('\n' + '=' * 80);
  print('ANALYSIS COMPLETE');
  print('=' * 80);
}