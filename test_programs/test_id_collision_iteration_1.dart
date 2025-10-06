#!/usr/bin/env dart

// Test Iteration 1: ID Collision Analysis

void analyzeIdCollisionRisk() {
  print('ID COLLISION ANALYSIS');
  print('=' * 80);
  
  print('\nWhy prefixes exist:');
  print('Different device types might have the SAME ID from API:');
  print('- Access Point: id=123');
  print('- Media Converter: id=123');
  print('- Switch: id=123');
  print('- WLAN Controller: id=123');
  
  print('\nWithout prefixes, they would collide:');
  print('Device list would have multiple devices with id="123"');
  print('This could cause:');
  print('- Wrong device displayed');
  print('- State management issues');
  print('- Incorrect updates');
  
  print('\nWith prefixes (current approach):');
  print('- ap_123');
  print('- ont_123');
  print('- sw_123');
  print('- wlan_123');
  print('All unique, no collisions!');
}

void testCollisionScenario() {
  print('\n\nCOLLISION TEST');
  print('=' * 80);
  
  // Simulate devices from different endpoints with same IDs
  final accessPoints = [
    {'id': 1, 'name': 'AP-1', 'type': 'access_point'},
    {'id': 2, 'name': 'AP-2', 'type': 'access_point'},
  ];
  
  final mediaConverters = [
    {'id': 1, 'name': 'ONT-1', 'type': 'ont'},  // Same ID as AP!
    {'id': 3, 'name': 'ONT-3', 'type': 'ont'},
  ];
  
  final switches = [
    {'id': 1, 'name': 'SW-1', 'type': 'switch'},  // Same ID again!
    {'id': 2, 'name': 'SW-2', 'type': 'switch'},  // Same ID as AP-2!
  ];
  
  print('Without prefixes - Using Map to store by ID:');
  final devicesById = <String, Map<String, dynamic>>{};
  
  // Add all devices
  for (final ap in accessPoints) {
    final id = ap['id'].toString();
    devicesById[id] = ap;
    print('Added AP with id=$id');
  }
  
  for (final ont in mediaConverters) {
    final id = ont['id'].toString();
    if (devicesById.containsKey(id)) {
      print('COLLISION! ONT id=$id overwrites ${devicesById[id]?['name']}');
    }
    devicesById[id] = ont;
  }
  
  for (final sw in switches) {
    final id = sw['id'].toString();
    if (devicesById.containsKey(id)) {
      print('COLLISION! Switch id=$id overwrites ${devicesById[id]?['name']}');
    }
    devicesById[id] = sw;
  }
  
  print('\nFinal device map:');
  devicesById.forEach((id, device) {
    print('  id=$id: ${device['name']} (${device['type']})');
  });
  
  print('\nLOST DEVICES: AP-1, AP-2, ONT-1 were overwritten!');
  
  print('\n' + '-' * 60);
  print('With prefixes - No collisions:');
  final prefixedDevices = <String, Map<String, dynamic>>{};
  
  for (final ap in accessPoints) {
    final id = 'ap_${ap['id']}';
    prefixedDevices[id] = ap;
    print('Added AP with id=$id');
  }
  
  for (final ont in mediaConverters) {
    final id = 'ont_${ont['id']}';
    prefixedDevices[id] = ont;
    print('Added ONT with id=$id');
  }
  
  for (final sw in switches) {
    final id = 'sw_${sw['id']}';
    prefixedDevices[id] = sw;
    print('Added Switch with id=$id');
  }
  
  print('\nAll devices preserved:');
  prefixedDevices.forEach((id, device) {
    print('  id=$id: ${device['name']} (${device['type']})');
  });
}

void main() {
  print('ID COLLISION RISK ASSESSMENT - ITERATION 1');
  print('=' * 80);
  
  analyzeIdCollisionRisk();
  testCollisionScenario();
  
  print('\n' + '=' * 80);
  print('CONCLUSION');
  print('=' * 80);
  print('\nYou are CORRECT! Removing prefixes would cause ID collisions.');
  print('The prefixes are NECESSARY to prevent data loss.');
  print('\nThe ID prefixing is NOT the problem.');
  print('We need to look at the actual display issue instead.');
}