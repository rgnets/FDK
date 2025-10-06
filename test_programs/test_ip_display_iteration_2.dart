#!/usr/bin/env dart

// Test Iteration 2: Fix IP Display for empty strings

class Device {
  final String? ipAddress;
  final String? macAddress;
  
  Device({this.ipAddress, this.macAddress});
}

// Current implementation (WRONG for empty strings)
String formatNetworkInfoWrong(Device device) {
  final ip = device.ipAddress ?? 'No IP';  // Doesn't handle empty string
  final mac = device.macAddress ?? 'No MAC';  // Doesn't handle empty string
  
  if (device.ipAddress != null && 
      device.ipAddress!.contains(':') && 
      device.ipAddress!.length > 20) {
    return device.ipAddress!;
  }
  
  return '$ip • $mac';
}

// Fixed implementation (CORRECT - handles empty strings)
String formatNetworkInfoFixed(Device device) {
  // Check for null OR empty string
  final ip = (device.ipAddress == null || device.ipAddress!.isEmpty) 
      ? 'No IP' 
      : device.ipAddress!;
  final mac = (device.macAddress == null || device.macAddress!.isEmpty) 
      ? 'No MAC' 
      : device.macAddress!;
  
  // Special case: IPv6 addresses are too long to show with MAC
  if (device.ipAddress != null && 
      device.ipAddress!.isNotEmpty &&  // Also check not empty
      device.ipAddress!.contains(':') && 
      device.ipAddress!.length > 20) {
    return device.ipAddress!;
  }
  
  return '$ip • $mac';
}

// Alternative clean implementation following Clean Architecture
String formatNetworkInfoClean(Device device) {
  // Helper to check if string is null or empty
  bool isNullOrEmpty(String? value) => value == null || value.isEmpty;
  
  final ip = device.ipAddress;
  final mac = device.macAddress;
  
  // IPv6 special case
  if (!isNullOrEmpty(ip) && ip!.contains(':') && ip.length > 20) {
    return ip;
  }
  
  // Format with fallbacks
  final displayIp = isNullOrEmpty(ip) ? 'No IP' : ip!;
  final displayMac = isNullOrEmpty(mac) ? 'No MAC' : mac!;
  
  return '$displayIp • $displayMac';
}

void compareImplementations() {
  print('IMPLEMENTATION COMPARISON');
  print('=' * 80);
  
  final testCases = [
    Device(ipAddress: '192.168.1.1', macAddress: 'AA:BB:CC:DD:EE:FF'),
    Device(ipAddress: null, macAddress: null),
    Device(ipAddress: '', macAddress: ''),  // The problem case!
    Device(ipAddress: '10.0.0.1', macAddress: ''),
    Device(ipAddress: '', macAddress: 'AA:BB:CC:DD:EE:FF'),
    Device(ipAddress: '2001:0db8:85a3:0000:0000:8a2e:0370:7334', macAddress: 'AA:BB:CC:DD:EE:FF'),
  ];
  
  for (final device in testCases) {
    print('\nDevice: ip="${device.ipAddress}", mac="${device.macAddress}"');
    print('  Wrong:  "${formatNetworkInfoWrong(device)}"');
    print('  Fixed:  "${formatNetworkInfoFixed(device)}"');
    print('  Clean:  "${formatNetworkInfoClean(device)}"');
  }
}

void validateArchitecture() {
  print('\n\nARCHITECTURE VALIDATION');
  print('=' * 80);
  
  print('\n✓ Clean Architecture:');
  print('  - This is presentation layer logic (correct place)');
  print('  - Formatting for display only');
  print('  - No business logic');
  
  print('\n✓ MVVM:');
  print('  - View formatting logic');
  print('  - Could be in ViewModel if needed');
  print('  - Pure function, easily testable');
  
  print('\n✓ Single Responsibility:');
  print('  - Only formats network info for display');
  print('  - One clear purpose');
  
  print('\n✓ Testability:');
  print('  - Pure function');
  print('  - No dependencies');
  print('  - Easy to unit test');
}

void main() {
  print('IP DISPLAY FIX - ITERATION 2');
  print('=' * 80);
  
  print('\nTHE PROBLEM:');
  print('- Staging API returns empty strings ("") for missing values');
  print('- Development mock data uses null for missing values');
  print('- Current code only checks for null, not empty strings');
  print('- Result: Staging shows " • " instead of "No IP • No MAC"');
  
  print('\nTHE SOLUTION:');
  print('Check for BOTH null AND empty string');
  
  print('\n');
  compareImplementations();
  validateArchitecture();
  
  print('\n' + '=' * 80);
  print('IMPLEMENTATION PLAN');
  print('=' * 80);
  print('\nFile: lib/features/devices/presentation/screens/devices_screen.dart');
  print('Method: _formatNetworkInfo (line 26)');
  print('\nChange:');
  print('  FROM: device.ipAddress ?? "No IP"');
  print('  TO:   (device.ipAddress == null || device.ipAddress!.isEmpty) ? "No IP" : device.ipAddress!');
  print('\nSame for macAddress.');
  print('\nThis ensures consistent display across all environments.');
}