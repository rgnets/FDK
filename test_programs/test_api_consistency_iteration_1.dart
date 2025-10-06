#!/usr/bin/env dart

// Test Iteration 1: Analyze API field consistency

// Question: Why are we checking multiple fields for room ID?
// In Clean Architecture, the API should have a consistent structure

void analyzeCurrentCode() {
  print('CURRENT CODE ANALYSIS');
  print('=' * 80);
  
  print('\nIn device_remote_data_source.dart, we extract pmsRoomId like this:');
  print('1. For access_points (line 234-243):');
  print('   if (deviceMap[\'pms_room\'] != null && deviceMap[\'pms_room\'] is Map)');
  print('     pmsRoomId = pmsRoom[\'id\']');
  
  print('\n2. For media_converters (line 262-271):');
  print('   Same logic - checks pms_room.id');
  
  print('\n3. For switch_devices (line 290-299):');
  print('   Same logic - checks pms_room.id');
  
  print('\n4. For wlan_devices (no pmsRoomId extraction):');
  print('   Missing! No pmsRoomId field set');
  
  print('\nOBSERVATION:');
  print('- All device types use the SAME field: pms_room.id');
  print('- No alternate fields are actually being checked');
  print('- The code is consistent across device types');
  print('- EXCEPT: wlan_devices don\'t set pmsRoomId at all!');
}

void analyzeApiStructure() {
  print('\n\nEXPECTED API STRUCTURE');
  print('=' * 80);
  
  print('\nIf the API follows REST and Clean Architecture:');
  print('1. All devices should have the same field for room association');
  print('2. The field should be named consistently');
  print('3. The structure should be predictable');
  
  print('\nExpected structure for ALL device types:');
  print('{');
  print('  "id": 123,');
  print('  "name": "Device Name",');
  print('  "pms_room": {');
  print('    "id": 1,');
  print('    "name": "Room Name"');
  print('  }');
  print('}');
  
  print('\nThis is what the code ACTUALLY expects and handles.');
}

void identifyRealProblem() {
  print('\n\nREAL PROBLEM IDENTIFICATION');
  print('=' * 80);
  
  print('\nThe issue is NOT multiple field names!');
  print('The code consistently uses pms_room.id for all device types.');
  
  print('\nThe ACTUAL problems are:');
  print('1. ID Prefixing:');
  print('   - device_remote_data_source adds prefixes (ap_, ont_, sw_)');
  print('   - This breaks Clean Architecture (data transformation in data layer)');
  
  print('\n2. WLAN devices missing pmsRoomId:');
  print('   - Line 316-329: wlan_devices don\'t extract pms_room');
  print('   - They have no pmsRoomId field set');
  
  print('\n3. Possible API data issues:');
  print('   - Maybe pms_room is null/missing in staging API responses');
  print('   - Maybe room IDs don\'t match between rooms and devices');
}

void testDataFlow() {
  print('\n\nDATA FLOW TEST');
  print('=' * 80);
  
  // Simulate what happens with current code
  Map<String, dynamic> processDevice(Map<String, dynamic> apiData, String type) {
    // Extract pmsRoomId (current logic)
    int? pmsRoomId;
    if (apiData['pms_room'] != null && apiData['pms_room'] is Map) {
      final pmsRoom = apiData['pms_room'] as Map<String, dynamic>;
      final idValue = pmsRoom['id'];
      if (idValue is int) {
        pmsRoomId = idValue;
      } else if (idValue is String) {
        pmsRoomId = int.tryParse(idValue);
      }
    }
    
    // Current prefixing (WRONG)
    final prefix = {
      'access_point': 'ap_',
      'ont': 'ont_',
      'switch': 'sw_',
      'wlan': 'wlan_',
    }[type] ?? '';
    
    return {
      'id': '$prefix${apiData['id']}',  // Prefixed
      'pmsRoomId': pmsRoomId,
      'type': type,
    };
  }
  
  // Test cases
  final testCases = [
    {'id': 123, 'pms_room': {'id': 1}},
    {'id': 456, 'pms_room': null},  // Missing pms_room
    {'id': 789},  // No pms_room field at all
  ];
  
  print('\nProcessing devices with current logic:');
  for (final data in testCases) {
    final result = processDevice(data, 'access_point');
    print('Input: $data');
    print('Output: id="${result['id']}", pmsRoomId=${result['pmsRoomId']}');
    print('');
  }
}

void main() {
  print('API CONSISTENCY ANALYSIS - ITERATION 1');
  print('=' * 80);
  
  analyzeCurrentCode();
  analyzeApiStructure();
  identifyRealProblem();
  testDataFlow();
  
  print('\n' + '=' * 80);
  print('CONCLUSION');
  print('=' * 80);
  print('\nYou are RIGHT - we should NOT have alternate field names!');
  print('The code already uses a SINGLE field: pms_room.id');
  print('\nThe problems are:');
  print('1. ID prefixing (violates Clean Architecture)');
  print('2. WLAN devices missing pmsRoomId extraction');
  print('3. Possible null/missing pms_room in API responses');
}