#!/usr/bin/env dart

// Test script to understand PMS rooms endpoint structure

void main() {
  print('PMS ROOMS ENDPOINT ANALYSIS');
  print('Testing staging endpoint structure');
  print('=' * 80);
  
  analyzePmsRoomsEndpoint();
  compareWithRoomsEndpoint();
  identifyDataDifferences();
  designMockStrategy();
}

void analyzePmsRoomsEndpoint() {
  print('\n1. PMS ROOMS ENDPOINT STRUCTURE');
  print('-' * 50);
  
  print('ENDPOINT:');
  print('  GET /api/pms_rooms.json?page_size=0');
  print('  Authentication: Bearer token (NOT api_key in production)');
  
  print('\nEXPECTED RESPONSE STRUCTURE:');
  print('''
  {
    "count": 680,
    "next": null,
    "previous": null,
    "results": [
      {
        "id": 801,
        "name": "(West Wing) 801",
        "room_number": "801",
        "building": "West Wing",
        "floor": 8,
        "property": "Interurban Complex",
        "status": "occupied",
        "created_at": "2023-01-01T00:00:00Z",
        "updated_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
  ''');
  
  print('\nKEY OBSERVATIONS:');
  print('  • Dedicated endpoint exists: /api/pms_rooms');
  print('  • Returns room data from Property Management System');
  print('  • May have additional fields like "property", "status"');
  print('  • Uses Bearer authentication in production');
  print('  • Supports pagination with page_size=0 for all records');
}

void compareWithRoomsEndpoint() {
  print('\n2. COMPARING /api/rooms vs /api/pms_rooms');
  print('-' * 50);
  
  print('HYPOTHESIS:');
  print('  /api/rooms - Our internal room tracking');
  print('  /api/pms_rooms - External PMS integration');
  
  print('\nDIFFERENCES:');
  print('  pms_rooms may have:');
  print('    • property field (building complex name)');
  print('    • status field (occupied/vacant/maintenance)');
  print('    • Different update frequency');
  print('    • External system IDs');
  
  print('\nSIMILARITIES:');
  print('  Both have:');
  print('    • id (integer)');
  print('    • name (formatted location)');
  print('    • room_number');
  print('    • building');
  print('    • floor');
  
  print('\nDATA RELATIONSHIP:');
  print('  rooms.id should match pms_rooms.id');
  print('  Device.pms_room references pms_rooms data');
  print('  Rooms may be synced from pms_rooms periodically');
}

void identifyDataDifferences() {
  print('\n3. DATA DIFFERENCES TO SIMULATE');
  print('-' * 50);
  
  print('NORMAL CASES (99.8%):');
  print('  • pms_room matches room data exactly');
  print('  • All devices have valid pms_room');
  print('  • All rooms have at least one device');
  
  print('\nEDGE CASES (0.2%):');
  print('  • 0.1% devices with null pms_room (error state)');
  print('  • 0.1% empty rooms (no devices)');
  
  print('\nTEST SCENARIOS:');
  print('  • Divergent data (room renamed but pms_room not updated)');
  print('  • Stale pms_room data (testing sync issues)');
  print('  • Invalid pms_room.id (doesn\'t exist in rooms)');
  
  print('\nERROR NOTIFICATIONS:');
  print('  Devices with null pms_room should generate:');
  print('    • Type: "error"');
  print('    • Priority: "urgent"');
  print('    • Message: "Device not assigned to room"');
}

void designMockStrategy() {
  print('\n4. MOCK DATA STRATEGY FOR PMS_ROOMS');
  print('-' * 50);
  
  print('IMPLEMENTATION PLAN:');
  
  print('\n1. Generate pms_rooms collection:');
  print('''
  Map<String, dynamic> getMockPmsRoomsJson() {
    final pmsRooms = <Map<String, dynamic>>[];
    
    // Generate from base rooms
    for (final room in _rooms) {
      pmsRooms.add({
        'id': room['id'],
        'name': room['name'],
        'room_number': room['room_number'],
        'building': room['building'],
        'floor': room['floor'],
        'property': _getPropertyName(room['building']),
        'status': _getRoomStatus(),  // occupied/vacant/maintenance
        'created_at': room['created_at'],
        'updated_at': room['updated_at']
      });
    }
    
    return wrapApiResponse(pmsRooms);
  }
  ''');
  
  print('\n2. Add test variations:');
  print('  • 0.1% devices with null pms_room');
  print('  • 0.1% empty rooms');
  print('  • Some divergent data for testing');
  
  print('\n3. Generate error notifications:');
  print('  For devices with null pms_room:');
  print('    - Create urgent error notification');
  print('    - Flag as "Device not assigned to room"');
  
  print('\n✅ STRATEGY DEFINED');
}