#!/usr/bin/env dart

// Test Iteration 1: IP Address Display Difference

class Device {
  final String? ipAddress;
  final String? macAddress;
  
  Device({this.ipAddress, this.macAddress});
}

String formatNetworkInfoCurrent(Device device) {
  final ip = device.ipAddress ?? 'No IP';
  final mac = device.macAddress ?? 'No MAC';
  
  // Special case: IPv6 addresses are too long to show with MAC
  if (device.ipAddress != null && 
      device.ipAddress!.contains(':') && 
      device.ipAddress!.length > 20) {
    return device.ipAddress!;
  }
  
  return '$ip • $mac';
}

void testScenario(String name, Device device) {
  print('\n$name:');
  print('  Device: ipAddress="${device.ipAddress}", macAddress="${device.macAddress}"');
  print('  Display: "${formatNetworkInfoCurrent(device)}"');
}

void main() {
  print('IP ADDRESS DISPLAY ANALYSIS - ITERATION 1');
  print('=' * 80);
  
  print('CURRENT DISPLAY LOGIC:');
  print('1. If IP is null: shows "No IP"');
  print('2. If MAC is null: shows "No MAC"');
  print('3. If IP is IPv6 (contains ":" and length > 20): shows IP only');
  print('4. Otherwise: shows "IP • MAC"');
  
  print('\n' + '=' * 80);
  print('TEST SCENARIOS');
  print('=' * 80);
  
  // Development scenarios (mock data likely has values)
  testScenario('Dev: Full data', 
    Device(ipAddress: '192.168.1.100', macAddress: 'AA:BB:CC:DD:EE:FF'));
  
  testScenario('Dev: IPv6', 
    Device(ipAddress: '2001:0db8:85a3:0000:0000:8a2e:0370:7334', macAddress: 'AA:BB:CC:DD:EE:FF'));
  
  // Staging scenarios (API might return empty strings or nulls)
  testScenario('Staging: Null IP and MAC', 
    Device(ipAddress: null, macAddress: null));
  
  testScenario('Staging: Empty strings', 
    Device(ipAddress: '', macAddress: ''));
  
  testScenario('Staging: Only MAC', 
    Device(ipAddress: null, macAddress: 'AA:BB:CC:DD:EE:FF'));
  
  testScenario('Staging: Only IP', 
    Device(ipAddress: '10.0.0.1', macAddress: null));
  
  print('\n' + '=' * 80);
  print('POTENTIAL ISSUE IDENTIFIED');
  print('=' * 80);
  
  print('\nEmpty strings vs null:');
  print('If API returns empty string ("") instead of null:');
  
  final emptyDevice = Device(ipAddress: '', macAddress: '');
  print('\nDevice with empty strings:');
  print('  ipAddress: "${emptyDevice.ipAddress}" (empty string, NOT null)');
  print('  macAddress: "${emptyDevice.macAddress}" (empty string, NOT null)');
  print('  Current display: "${formatNetworkInfoCurrent(emptyDevice)}"');
  print('  Shows: " • " (just bullet!)');
  
  print('\nThis is the problem!');
  print('Empty string ?? "No IP" returns empty string (not null)');
  print('So it shows "" instead of "No IP"');
}