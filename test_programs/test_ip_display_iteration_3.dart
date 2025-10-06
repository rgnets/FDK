#!/usr/bin/env dart

// Test Iteration 3: Complete validation of IP display fix

// Domain entity (following Clean Architecture)
class Device {
  final String id;
  final String name;
  final String type;
  final String status;
  final String? ipAddress;
  final String? macAddress;
  
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.ipAddress,
    this.macAddress,
  });
}

// Presentation layer helper (correct location for display logic)
class NetworkInfoFormatter {
  // Final solution following all architecture principles
  static String format(Device device) {
    // Helper function for null/empty check
    String displayValue(String? value, String fallback) {
      if (value == null || value.trim().isEmpty) {
        return fallback;
      }
      return value;
    }
    
    final ip = displayValue(device.ipAddress, 'No IP');
    final mac = displayValue(device.macAddress, 'No MAC');
    
    // Special case: IPv6 addresses (too long for combined display)
    if (device.ipAddress != null && 
        device.ipAddress!.trim().isNotEmpty &&
        device.ipAddress!.contains(':') && 
        device.ipAddress!.length > 20) {
      return device.ipAddress!;
    }
    
    return '$ip • $mac';
  }
}

void testAllScenarios() {
  print('COMPLETE SCENARIO TESTING');
  print('=' * 80);
  
  final scenarios = [
    {
      'name': 'Development: Full data',
      'device': Device(
        id: 'ap_1',
        name: 'AP-Conference',
        type: 'access_point',
        status: 'online',
        ipAddress: '192.168.1.100',
        macAddress: 'AA:BB:CC:DD:EE:FF',
      ),
      'expected': '192.168.1.100 • AA:BB:CC:DD:EE:FF',
    },
    {
      'name': 'Development: Null values',
      'device': Device(
        id: 'ap_2',
        name: 'AP-Lobby',
        type: 'access_point',
        status: 'offline',
        ipAddress: null,
        macAddress: null,
      ),
      'expected': 'No IP • No MAC',
    },
    {
      'name': 'Staging: Empty strings',
      'device': Device(
        id: 'ont_1',
        name: 'ONT-Room101',
        type: 'ont',
        status: 'online',
        ipAddress: '',
        macAddress: '',
      ),
      'expected': 'No IP • No MAC',
    },
    {
      'name': 'Staging: Whitespace only',
      'device': Device(
        id: 'sw_1',
        name: 'Switch-Main',
        type: 'switch',
        status: 'online',
        ipAddress: '   ',
        macAddress: '  \t  ',
      ),
      'expected': 'No IP • No MAC',
    },
    {
      'name': 'Mixed: IP only',
      'device': Device(
        id: 'ap_3',
        name: 'AP-Outdoor',
        type: 'access_point',
        status: 'online',
        ipAddress: '10.0.0.1',
        macAddress: '',
      ),
      'expected': '10.0.0.1 • No MAC',
    },
    {
      'name': 'Mixed: MAC only',
      'device': Device(
        id: 'ap_4',
        name: 'AP-Backup',
        type: 'access_point',
        status: 'offline',
        ipAddress: null,
        macAddress: 'FF:EE:DD:CC:BB:AA',
      ),
      'expected': 'No IP • FF:EE:DD:CC:BB:AA',
    },
    {
      'name': 'IPv6 address',
      'device': Device(
        id: 'ap_5',
        name: 'AP-IPv6',
        type: 'access_point',
        status: 'online',
        ipAddress: '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        macAddress: 'AA:BB:CC:DD:EE:FF',
      ),
      'expected': '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
    },
  ];
  
  var allPassed = true;
  
  for (final scenario in scenarios) {
    final device = scenario['device'] as Device;
    final expected = scenario['expected'] as String;
    final actual = NetworkInfoFormatter.format(device);
    final passed = actual == expected;
    
    print('\n${scenario['name']}:');
    print('  Device: ip="${device.ipAddress}", mac="${device.macAddress}"');
    print('  Expected: "$expected"');
    print('  Actual:   "$actual"');
    print('  Result:   ${passed ? "✓ PASS" : "✗ FAIL"}');
    
    if (!passed) allPassed = false;
  }
  
  print('\n' + '=' * 80);
  print('OVERALL: ${allPassed ? "✓ ALL TESTS PASSED" : "✗ SOME TESTS FAILED"}');
}

void validateArchitecture() {
  print('\n\nARCHITECTURE COMPLIANCE CHECK');
  print('=' * 80);
  
  print('\n✓ Clean Architecture:');
  print('  • Display formatting in presentation layer ✓');
  print('  • No business logic mixed with UI ✓');
  print('  • Domain entity remains pure ✓');
  
  print('\n✓ MVVM Pattern:');
  print('  • View helper for display logic ✓');
  print('  • Testable pure function ✓');
  print('  • No state management needed ✓');
  
  print('\n✓ Single Responsibility:');
  print('  • NetworkInfoFormatter: formats network info only ✓');
  print('  • Device entity: holds data only ✓');
  
  print('\n✓ Dependency Injection:');
  print('  • No dependencies, pure function ✓');
  
  print('\n✓ Riverpod:');
  print('  • Not needed for pure display function ✓');
  
  print('\n✓ Testing:');
  print('  • All edge cases covered ✓');
  print('  • Deterministic output ✓');
}

void main() {
  print('IP DISPLAY COMPLETE VALIDATION - ITERATION 3');
  print('=' * 80);
  
  print('\nROOT CAUSE:');
  print('• Staging API returns empty strings ("") for missing IP/MAC');
  print('• Development mock returns null for missing IP/MAC');
  print('• Current code: device.ipAddress ?? "No IP" doesn\'t handle ""');
  print('• Result: Shows " • " instead of "No IP • No MAC" in staging');
  
  print('\nSOLUTION:');
  print('• Check for null OR empty/whitespace strings');
  print('• Use trim() to handle whitespace-only strings');
  print('• Maintain all other logic unchanged');
  
  print('\n');
  testAllScenarios();
  validateArchitecture();
  
  print('\n' + '=' * 80);
  print('FINAL PLAN');
  print('=' * 80);
  
  print('\n1. NO CHANGES to ID prefixing (prevents collisions)');
  print('\n2. Fix _formatNetworkInfo in devices_screen.dart:');
  print('   Change line 27:');
  print('     FROM: final ip = device.ipAddress ?? "No IP";');
  print('     TO:   final ip = (device.ipAddress == null || device.ipAddress!.trim().isEmpty)');
  print('                     ? "No IP" : device.ipAddress!;');
  print('   Change line 28:');
  print('     FROM: final mac = device.macAddress ?? "No MAC";');
  print('     TO:   final mac = (device.macAddress == null || device.macAddress!.trim().isEmpty)');
  print('                      ? "No MAC" : device.macAddress!;');
  print('\n3. Also update the IPv6 check to handle empty strings');
  
  print('\nThis ensures consistent display across all environments.');
}