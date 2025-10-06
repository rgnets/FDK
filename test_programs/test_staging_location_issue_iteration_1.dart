#!/usr/bin/env dart

// Test Iteration 1: Analyze staging location data flow issue

void main() {
  print('STAGING LOCATION ISSUE ANALYSIS - ITERATION 1');
  print('Analyzing why location is not passed to display in staging');
  print('=' * 80);
  
  analyzeCurrentImplementation();
  identifyDataFlow();
  traceStagingApiStructure();
  identifyRootCause();
}

void analyzeCurrentImplementation() {
  print('\n1. CURRENT IMPLEMENTATION ANALYSIS');
  print('-' * 50);
  
  print('DEVICE ENTITY LOCATION EXTRACTION:');
  print('  Line 66: location: json["room"]?.toString() ?? json["location"]?.toString()');
  print('  Line 106: location: json["room"]?.toString() ?? json["location"]?.toString()');
  
  print('\nPROBLEM IDENTIFIED:');
  print('  ❌ Looking for location in json["room"] or json["location"]');
  print('  ❌ NOT extracting from pms_room.name where API provides it');
  
  print('\nDEVELOPMENT WORKS BECAUSE:');
  print('  ✅ MockDataService directly sets device.location');
  print('  ✅ No parsing from JSON required');
  
  print('\nSTAGING FAILS BECAUSE:');
  print('  ❌ API provides location in pms_room.name');
  print('  ❌ Code looks for it in wrong JSON fields');
  print('  ❌ Result: device.location is null or empty');
}

void identifyDataFlow() {
  print('\n2. DATA FLOW IDENTIFICATION');
  print('-' * 50);
  
  print('EXPECTED API STRUCTURE:');
  print('''
  {
    "id": 123,
    "name": "AP-001",
    "pms_room": {
      "id": 1001,
      "name": "(North Tower) 101"  // <-- Location is HERE
    },
    "room": null,                   // <-- NOT here
    "location": null                // <-- NOT here
  }
  ''');
  
  print('\nCURRENT CODE FLOW:');
  print('1. API Response → Device.fromAccessPointJson()');
  print('2. Extracts pmsRoomId from pms_room.id ✅');
  print('3. Extracts location from json["room"] ❌ WRONG');
  print('4. Falls back to json["location"] ❌ ALSO WRONG');
  print('5. Result: location is null');
  print('6. NotificationGenerationService gets null location');
  print('7. Display shows no location');
}

void traceStagingApiStructure() {
  print('\n3. STAGING API STRUCTURE TRACE');
  print('-' * 50);
  
  print('EVIDENCE FROM device_remote_data_source.dart:');
  print('  Lines 235-237: Extracts pms_room as Map');
  print('  Line 237: Gets pms_room["id"] for pmsRoomId');
  print('  MISSING: Should also get pms_room["name"] for location!');
  
  print('\nCORRECT EXTRACTION PATTERN:');
  print('''
  if (json['pms_room'] != null && json['pms_room'] is Map) {
    final pmsRoom = json['pms_room'] as Map<String, dynamic>;
    pmsRoomId = pmsRoom['id'];           // ✅ Already doing this
    location = pmsRoom['name'];          // ❌ MISSING THIS!
  }
  ''');
}

void identifyRootCause() {
  print('\n4. ROOT CAUSE IDENTIFICATION');
  print('-' * 50);
  
  print('ROOT CAUSE:');
  print('  The Device factory constructors are not extracting location');
  print('  from pms_room.name where the staging API provides it.');
  
  print('\nFIX REQUIRED:');
  print('  Update Device.fromAccessPointJson() to extract location from pms_room.name');
  print('  Update Device.fromSwitchJson() to extract location from pms_room.name');
  print('  Update Device.fromMediaConverterJson() to extract location from pms_room.name');
  
  print('\nIMPACT:');
  print('  • Staging will correctly show location in notifications');
  print('  • Production will also work correctly');
  print('  • Development continues to work (uses different path)');
  
  print('\n🎯 SOLUTION IDENTIFIED:');
  print('  Extract location from pms_room.name in Device factory constructors');
}