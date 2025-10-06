#!/usr/bin/env dart

// ROOT CAUSE ANALYSIS: Why staging doesn't show location

void main() {
  print('ROOT CAUSE ANALYSIS - STAGING LOCATION ISSUE');
  print('=' * 80);
  
  analyzeRootCause();
  showCodePaths();
  demonstrateProblem();
  proposeSolution();
}

void analyzeRootCause() {
  print('\n🔍 ROOT CAUSE IDENTIFIED');
  print('-' * 50);
  
  print('THE PROBLEM:');
  print('  Staging and Development use DIFFERENT code paths!');
  print('  Device.fromAccessPointJson() is NEVER called in staging!');
  
  print('\nDEVELOPMENT PATH:');
  print('  1. MockDataService.getMockDevices()');
  print('  2. Returns Device entities directly with location set');
  print('  3. Location appears in notifications ✓');
  
  print('\nSTAGING PATH:');
  print('  1. RemoteDeviceDataSource.getDevices()');
  print('  2. Fetches from API endpoints');
  print('  3. Creates DeviceModel.fromJson() (NOT Device.fromAccessPointJson!)');
  print('  4. DeviceModel has location from wrong fields');
  print('  5. DeviceModel.toEntity() → Device');
  print('  6. Location is empty/null ✗');
  
  print('\nWHY OUR FIX DIDN\'T WORK:');
  print('  We fixed Device.fromAccessPointJson() to extract pms_room.name');
  print('  But staging never calls this factory!');
  print('  Staging uses DeviceModel.fromJson() instead');
}

void showCodePaths() {
  print('\n📂 CODE PATH COMPARISON');
  print('-' * 50);
  
  print('DEVELOPMENT (MockDataService):');
  print('''
  // In mock_data_service.dart
  List<Device> getMockDevices() {
    // Creates Device entities directly
    return devices.map((d) => Device(
      location: d.location,  // ✓ Location set
      // ...
    )).toList();
  }
  ''');
  
  print('\nSTAGING (RemoteDeviceDataSource):');
  print('''
  // In device_remote_data_source.dart (line 245-258)
  case 'access_points':
    return DeviceModel.fromJson({
      'id': 'ap_\${deviceMap['id']}',
      'name': deviceMap['name'],
      'type': 'access_point',
      'location': deviceMap['location'] ??   // ← These fields don't exist!
                  deviceMap['room'] ??      // ← in staging API
                  deviceMap['room_id'],     // ← so location is empty
      // ...
    });
  ''');
  
  print('\nTHE MISSING LINK:');
  print('  RemoteDeviceDataSource should extract location from pms_room.name');
  print('  Just like Device.fromAccessPointJson() does');
}

void demonstrateProblem() {
  print('\n⚠️ PROBLEM DEMONSTRATION');
  print('-' * 50);
  
  print('STAGING API RESPONSE:');
  print('''
  {
    "id": 123,
    "name": "AP-WE-801",
    "online": true,
    "pms_room": {
      "id": 801,
      "name": "(West Wing) 801",  // ← Location is HERE
      "building": "West Wing",
      "floor": 8
    }
    // No "location" field at top level!
  }
  ''');
  
  print('\nREMOTE DATA SOURCE LOOKS FOR:');
  print('  deviceMap["location"] → null');
  print('  deviceMap["room"] → null');
  print('  deviceMap["room_id"] → null');
  print('  Result: location = ""');
  
  print('\nSHOULD EXTRACT FROM:');
  print('  deviceMap["pms_room"]["name"] → "(West Wing) 801"');
}

void proposeSolution() {
  print('\n✅ SOLUTION');
  print('-' * 50);
  
  print('FIX LOCATION IN RemoteDeviceDataSource:');
  print('''
  // In device_remote_data_source.dart
  case 'access_points':
    // Extract location from pms_room.name
    String? location;
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      location = pmsRoom['name']?.toString();
    }
    
    return DeviceModel.fromJson({
      'id': 'ap_\${deviceMap['id']}',
      'name': deviceMap['name'],
      'type': 'access_point',
      'location': location ?? '',  // ← Use extracted location!
      // ...
    });
  ''');
  
  print('\nAPPLY SAME FIX TO:');
  print('  • media_converters (line 260-286)');
  print('  • switch_devices (line 288-314)');
  print('  • wlan_devices if needed');
  
  print('\nALTERNATIVE: USE Device FACTORIES');
  print('  Instead of DeviceModel.fromJson()');
  print('  Use Device.fromAccessPointJson() directly');
  print('  Then convert Device → DeviceModel if needed');
  
  print('\n🎯 SUMMARY');
  print('  The issue is in RemoteDeviceDataSource');
  print('  It doesn\'t extract location from pms_room.name');
  print('  Fix the location extraction there');
}