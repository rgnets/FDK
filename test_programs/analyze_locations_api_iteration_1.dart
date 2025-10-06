#!/usr/bin/env dart

// Iteration 1: Analyze Locations/pms_room API structure and relationships

void main() {
  print('LOCATIONS/PMS_ROOM API ANALYSIS - ITERATION 1');
  print('Understanding location data structure and flow');
  print('=' * 80);
  
  analyzeCurrentUnderstanding();
  identifyLocationEndpoints();
  mapDataRelationships();
  generateQuestions();
}

void analyzeCurrentUnderstanding() {
  print('\n1. CURRENT UNDERSTANDING OF LOCATIONS');
  print('-' * 50);
  
  print('WHAT WE KNOW:');
  print('  • pms_room appears nested in device responses');
  print('  • Contains: id, name, room_number, building, floor');
  print('  • Format: name = "(Building) RoomNumber"');
  print('  • Links devices to physical locations');
  
  print('\nWHAT WE NEED TO CLARIFY:');
  print('  ? Is there a separate /api/locations endpoint?');
  print('  ? Is there a separate /api/pms_rooms endpoint?');
  print('  ? Are locations and pms_rooms the same thing?');
  print('  ? How are rooms different from pms_rooms?');
  print('  ? What is the source of truth for location data?');
}

void identifyLocationEndpoints() {
  print('\n2. POTENTIAL LOCATION ENDPOINTS');
  print('-' * 50);
  
  print('OBSERVED ENDPOINTS:');
  print('  • GET /api/rooms - Returns room data');
  print('  • Device endpoints include pms_room nested');
  
  print('\nPOSSIBLE ADDITIONAL ENDPOINTS:');
  print('  ? GET /api/pms_rooms - Dedicated PMS room endpoint?');
  print('  ? GET /api/locations - Generic locations endpoint?');
  print('  ? GET /api/buildings - Building hierarchy?');
  print('  ? GET /api/floors - Floor management?');
  
  print('\nQUESTION FOR USER:');
  print('  Are there separate endpoints for locations/pms_rooms?');
  print('  Or is location data only available through:');
  print('    1. Nested in device responses (pms_room)');
  print('    2. The /api/rooms endpoint');
}

void mapDataRelationships() {
  print('\n3. DATA RELATIONSHIP MAPPING');
  print('-' * 50);
  
  print('CURRENT RELATIONSHIP MODEL:');
  print('''
  Room (from /api/rooms)
    ├── id: 801 (integer)
    ├── name: "(West Wing) 801"
    ├── room_number: "801"
    ├── building: "West Wing"
    ├── floor: 8
    └── devices: [...]
  
  Device (from /api/access_points)
    ├── id: 123
    ├── name: "AP-WE-801"
    └── pms_room: {
          ├── id: 801  // Matches Room.id
          ├── name: "(West Wing) 801"
          ├── room_number: "801"
          ├── building: "West Wing"
          └── floor: 8
        }
  ''');
  
  print('\nKEY OBSERVATIONS:');
  print('  • pms_room.id == room.id (integer match)');
  print('  • pms_room seems to be a subset/copy of room data');
  print('  • Denormalized for convenience in device responses');
  
  print('\nQUESTIONS:');
  print('  1. Is Room the primary entity or is it PmsRoom?');
  print('  2. Should mock data have a separate pms_rooms collection?');
  print('  3. Or should pms_room always be derived from rooms?');
}

void generateQuestions() {
  print('\n4. CRITICAL QUESTIONS FOR USER');
  print('-' * 50);
  
  print('API STRUCTURE QUESTIONS:');
  print('  1. Is there a GET /api/pms_rooms endpoint?');
  print('     - If yes, what is its response format?');
  print('     - If no, pms_room only exists nested in devices?');
  
  print('\n  2. Is there a GET /api/locations endpoint?');
  print('     - If yes, how does it differ from rooms?');
  print('     - Does it return hierarchical data (buildings/floors)?');
  
  print('\n  3. What is the relationship between:');
  print('     - Rooms (from /api/rooms)');
  print('     - PMS Rooms (pms_room in devices)');
  print('     - Locations (if separate concept)');
  
  print('\nDATA CONSISTENCY QUESTIONS:');
  print('  4. Should pms_room data always match room data?');
  print('     - Same id, name, building, floor?');
  print('     - Or can they diverge?');
  
  print('\n  5. In mock data, should we:');
  print('     - Generate pms_room from rooms dynamically?');
  print('     - Maintain separate pms_room collection?');
  print('     - Always keep them in sync?');
  
  print('\nBUSINESS LOGIC QUESTIONS:');
  print('  6. Can a device exist without a pms_room?');
  print('     - Is pms_room nullable in production?');
  print('     - What does null pms_room mean?');
  
  print('\n  7. Can a pms_room exist without devices?');
  print('     - Empty rooms in the system?');
  print('     - Pre-configured for future use?');
  
  print('\nMOCK DATA QUESTIONS:');
  print('  8. For comprehensive testing, should mock data include:');
  print('     - Devices with null pms_room?');
  print('     - Rooms with no devices?');
  print('     - Mismatched room/pms_room data (for error testing)?');
  print('     - Invalid references (device.pms_room.id not in rooms)?');
  
  print('\n🎯 ITERATION 1 COMPLETE');
  print('  Need answers to proceed with complete plan');
}