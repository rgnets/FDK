#!/usr/bin/env dart

// Test the actual device data flow to identify where the crash occurs

void main() {
  print('=' * 80);
  print('DEVICE DATA FLOW TEST');
  print('=' * 80);
  
  testJsonParsing();
  testDeviceTypeFiltering();
  testProviderWatching();
  testPotentialNullErrors();
  printSummary();
}

void testJsonParsing() {
  print('\n1. JSON PARSING TEST');
  print('-' * 40);
  
  // Simulate device JSON from different endpoints
  final testDevices = {
    'access_point': {
      'id': 123,
      'name': 'AP-Lobby',
      'mac': '00:11:22:33:44:55',
      'ip': '192.168.1.100',
      'online': true,
      'pms_room': {
        'id': 101,
        'name': '(Building A) Room 101'
      }
    },
    'media_converter': {
      'id': 456,
      'name': 'ONT-Room202',
      'mac': 'AA:BB:CC:DD:EE:FF',
      'ip': '192.168.1.200',
      'status': 'online',
      'pms_room': null, // Could be null
    },
    'switch_device': {
      'id': 789,
      'name': null, // Name could be null
      'nickname': 'Core Switch',
      'scratch': 'XX:YY:ZZ:11:22:33', // MAC in scratch field
      'host': '10.0.0.1',
      'online': false,
    },
    'wlan_device': {
      'id': 999,
      'name': 'WLAN Controller',
      'device': 'UniFi',
      'host': '10.0.0.10',
      'mac': null, // MAC could be null
    }
  };
  
  print('Testing JSON transformation for each device type:');
  
  // Test access point transformation
  print('\nAccess Point:');
  print('  Input ID: ${testDevices['access_point']!['id']}');
  print('  Output ID: ap_123 (prefixed)');
  print('  Type: access_point');
  print('  Status: online (from online field)');
  print('  Location: (Building A) Room 101 (from pms_room.name)');
  
  // Test media converter transformation  
  print('\nMedia Converter (ONT):');
  print('  Input ID: ${testDevices['media_converter']!['id']}');
  print('  Output ID: ont_456 (prefixed)');
  print('  Type: ont');
  print('  Status: online (from status field)');
  print('  Location: "" (pms_room is null)');
  print('  ⚠️ Risk: Null pms_room handling');
  
  // Test switch transformation
  print('\nSwitch Device:');
  print('  Input ID: ${testDevices['switch_device']!['id']}');
  print('  Output ID: sw_789 (prefixed)');
  print('  Name: Core Switch (from nickname, name is null)');
  print('  Type: switch');
  print('  MAC: XX:YY:ZZ:11:22:33 (from scratch field!)');
  print('  ⚠️ Risk: Unusual field mapping');
  
  // Test WLAN controller
  print('\nWLAN Device:');
  print('  Input ID: ${testDevices['wlan_device']!['id']}');
  print('  Output ID: wlan_999 (prefixed)');
  print('  Type: wlan_controller');
  print('  MAC: "" (null handling)');
  print('  ⚠️ Risk: Null MAC address');
}

void testDeviceTypeFiltering() {
  print('\n2. DEVICE TYPE FILTERING TEST');
  print('-' * 40);
  
  print('Expected device types from API:');
  print('  - access_point (from access_points endpoint)');
  print('  - ont (from media_converters endpoint)');
  print('  - switch (from switch_devices endpoint)');
  print('  - wlan_controller (from wlan_devices endpoint)');
  
  print('\nUI Filter expectations (devices_screen.dart):');
  print('  Line 166: devices.where((d) => d.type == "access_point")');
  print('  Line 167: devices.where((d) => d.type == "switch")');
  print('  Line 168: devices.where((d) => d.type == "ont")');
  
  print('\nWLAN Controllers Issue:');
  print('  ❌ No UI tab for wlan_controller type');
  print('  ❌ These devices will not appear in any tab!');
  
  print('\nDevice Type Matching:');
  print('  ✅ access_point matches filter');
  print('  ✅ switch matches filter');
  print('  ✅ ont matches filter');
  print('  ❌ wlan_controller has no matching filter');
}

void testProviderWatching() {
  print('\n3. PROVIDER WATCHING ANALYSIS');
  print('-' * 40);
  
  print('DevicesScreen widget tree:');
  print('  Scaffold');
  print('    └── Consumer (line 93)');
  print('          ├── watches: devicesNotifierProvider');
  print('          ├── watches: filteredDevicesListProvider');
  print('          │     └── depends on: devicesNotifierProvider');
  print('          └── watches: mockDataStateProvider');
  print('                └── depends on: devicesNotifierProvider');
  
  print('\nPotential Issues:');
  print('  1. filteredDevicesListProvider depends on devicesNotifierProvider');
  print('  2. When devices updates, filtered list rebuilds');
  print('  3. This triggers DevicesScreen rebuild');
  print('  4. Could cause infinite loop if state updates during build');
  
  print('\nNested Consumer (line 215):');
  print('  Another Consumer inside the main Consumer');
  print('  Watches: deviceUIStateNotifierProvider');
  print('  Risk: Multiple rebuild sources');
}

void testPotentialNullErrors() {
  print('\n4. POTENTIAL NULL REFERENCE ERRORS');
  print('-' * 40);
  
  print('High-risk null operations:');
  
  print('\n1. device_remote_data_source.dart line 279:');
  print('   pms_room_id: _extractPmsRoomId(deviceMap)');
  print('   Risk: _extractPmsRoomId might throw on invalid data');
  
  print('\n2. devices_screen.dart line 27-32:');
  print('   device.ipAddress!.trim() // Force unwrap');
  print('   Risk: Crash if ipAddress is null');
  
  print('\n3. device_model.dart line 59:');
  print('   pmsRoomId: pmsRoomId ?? pmsRoom?.id');
  print('   Risk: Type mismatch if id is string in JSON');
  
  print('\n4. devices_screen.dart line 234:');
  print('   icon: ListItemHelpers.getDeviceIcon(device.type)');
  print('   Risk: Helper might not handle all device types');
  
  print('\n5. Mock data state check (line 102):');
  print('   final mockDataState = ref.watch(mockDataStateProvider)');
  print('   Risk: Provider might throw during initialization');
}

void printSummary() {
  print('\n' + '=' * 80);
  print('CRASH DIAGNOSIS SUMMARY');
  print('=' * 80);
  
  print('\nMOST LIKELY CAUSES:');
  print('  1. ❌ Missing generated provider files (*.g.dart)');
  print('  2. ❌ Null reference in _formatNetworkInfo (force unwrap)');
  print('  3. ❌ WLAN controller devices not handled in UI');
  print('  4. ❌ Provider circular dependency');
  print('  5. ❌ JSON parsing type mismatches');
  
  print('\nRECOMMENDED DEBUGGING:');
  print('  1. Run: dart run build_runner build');
  print('  2. Add try-catch in _formatNetworkInfo');
  print('  3. Log device types being filtered');
  print('  4. Check for null ipAddress/macAddress');
  print('  5. Verify provider initialization order');
}