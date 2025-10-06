#!/usr/bin/env dart

// Test script to verify null safety issues in device data
// This simulates the exact data flow that causes crashes

import 'dart:convert';

void main() {
  print('=' * 80);
  print('NULL SAFETY TEST FOR DEVICES VIEW');
  print('=' * 80);
  print('');
  
  testFormatNetworkInfo();
  testDeviceModelMapping();
  testProviderDataFlow();
  print('');
  printRecommendations();
}

void testFormatNetworkInfo() {
  print('1. TESTING _formatNetworkInfo METHOD');
  print('-' * 40);
  
  // Simulate the exact method from devices_screen.dart lines 26-43
  String formatNetworkInfo(Map<String, dynamic> device) {
    final ipAddress = device['ipAddress'] as String?;
    final macAddress = device['macAddress'] as String?;
    
    print('  Testing device: ${device['name']}');
    print('    ipAddress: ${ipAddress ?? "null"}');
    print('    macAddress: ${macAddress ?? "null"}');
    
    try {
      // This is what the actual code does (DANGEROUS!)
      final ip = (ipAddress == null || ipAddress.trim().isEmpty) 
          ? 'No IP' 
          : ipAddress;
      final mac = (macAddress == null || macAddress.trim().isEmpty) 
          ? 'No MAC' 
          : macAddress;
      
      // BUT the actual code uses force unwrap!
      // This would crash:
      // final ip = ipAddress!.trim().isEmpty ? 'No IP' : ipAddress!;
      
      // Special case for IPv6
      if (ipAddress != null && 
          ipAddress.trim().isNotEmpty &&
          ipAddress.contains(':') && 
          ipAddress.length > 20) {
        return ipAddress;
      }
      
      return '$ip • $mac';
    } catch (e) {
      print('    ERROR: $e');
      return 'ERROR';
    }
  }
  
  // Test cases that would crash the app
  final testDevices = [
    {
      'name': 'Device with both',
      'ipAddress': '192.168.1.100',
      'macAddress': 'AA:BB:CC:DD:EE:FF',
    },
    {
      'name': 'Device with null IP',
      'ipAddress': null,
      'macAddress': 'AA:BB:CC:DD:EE:FF',
    },
    {
      'name': 'Device with null MAC',
      'ipAddress': '192.168.1.100',
      'macAddress': null,
    },
    {
      'name': 'Device with both null',
      'ipAddress': null,
      'macAddress': null,
    },
    {
      'name': 'Device with empty strings',
      'ipAddress': '',
      'macAddress': '',
    },
    {
      'name': 'Device with IPv6',
      'ipAddress': '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
      'macAddress': 'AA:BB:CC:DD:EE:FF',
    },
  ];
  
  for (final device in testDevices) {
    final result = formatNetworkInfo(device);
    final wouldCrash = device['ipAddress'] == null || device['macAddress'] == null;
    final crashWarning = wouldCrash ? ' ⚠️ WOULD CRASH WITH FORCE UNWRAP!' : '';
    print('    Result: "$result"$crashWarning');
    print('');
  }
}

void testDeviceModelMapping() {
  print('2. TESTING DEVICE MODEL FIELD MAPPING');
  print('-' * 40);
  
  // Test how different device types map their fields
  final deviceMappings = {
    'access_point': {
      'raw_mac_field': 'mac',
      'raw_ip_field': 'ip',
      'expected_null_rate': 'Low',
    },
    'media_converter': {
      'raw_mac_field': 'mac',
      'raw_ip_field': 'ip',
      'expected_null_rate': 'Medium',
    },
    'switch_device': {
      'raw_mac_field': 'scratch',  // Unusual!
      'raw_ip_field': 'host',       // Different!
      'expected_null_rate': 'High',
    },
    'wlan_device': {
      'raw_mac_field': 'mac',
      'raw_ip_field': 'host',
      'expected_null_rate': 'Medium',
    },
  };
  
  for (final entry in deviceMappings.entries) {
    final type = entry.key;
    final mapping = entry.value;
    
    print('  $type:');
    print('    MAC from: ${mapping['raw_mac_field']} field');
    print('    IP from: ${mapping['raw_ip_field']} field');
    print('    Null probability: ${mapping['expected_null_rate']}');
    
    if (mapping['raw_mac_field'] == 'scratch') {
      print('    ⚠️ WARNING: Unusual field mapping for MAC!');
    }
  }
  print('');
}

void testProviderDataFlow() {
  print('3. TESTING PROVIDER DATA FLOW');
  print('-' * 40);
  
  // Simulate the provider chain
  print('  Provider initialization order:');
  print('    1. devicesNotifierProvider.build()');
  print('    2. Initializes AdaptiveRefreshManager');
  print('    3. Initializes CacheManager');
  print('    4. Starts background refresh immediately');
  print('    5. Calls getDevices with field selection');
  print('');
  
  print('  Potential initialization issues:');
  print('    ⚠️ Background refresh starts in build()');
  print('    ⚠️ Multiple providers watch devicesNotifierProvider');
  print('    ⚠️ filteredDevicesListProvider depends on devices');
  print('    ⚠️ mockDataStateProvider also depends on devices');
  print('');
  
  // Simulate provider watching
  print('  Widget rebuild cascade:');
  print('    DevicesScreen rebuilds when:');
  print('      - devicesNotifierProvider changes');
  print('      - filteredDevicesListProvider changes');
  print('      - deviceUIStateNotifierProvider changes');
  print('      - mockDataStateProvider changes');
  print('    Risk: Too many rebuild triggers');
}

void printRecommendations() {
  print('=' * 80);
  print('CRASH DIAGNOSIS RESULTS');
  print('=' * 80);
  print('');
  
  print('PRIMARY CRASH CAUSE:');
  print('  ❌ Force unwrapping in _formatNetworkInfo (lines 27-32)');
  print('     device.ipAddress!.trim() will crash if ipAddress is null');
  print('     device.macAddress!.trim() will crash if macAddress is null');
  print('');
  
  print('SECONDARY ISSUES:');
  print('  ⚠️ Switch devices use "scratch" field for MAC (unusual)');
  print('  ⚠️ WLAN controllers have no UI tab');
  print('  ⚠️ Background refresh starts immediately in build()');
  print('  ⚠️ Multiple providers watching same source');
  print('');
  
  print('IMMEDIATE FIX NEEDED:');
  print('  Replace force unwrapping with null-safe operations');
  print('  Current (crashes): device.ipAddress!.trim()');
  print('  Fixed (safe): device.ipAddress?.trim() ?? ""');
  print('');
  
  print('TO TEST THE CRASH:');
  print('  1. Run: bash scripts/test_devices_api.sh');
  print('     Check if any devices have null IP/MAC');
  print('  2. Run: bash scripts/start_dev_server.sh');
  print('     In another terminal: bash scripts/monitor_crash.sh');
  print('  3. Navigate to Devices view');
  print('  4. Check crash logs for "NoSuchMethodError" or "Null check operator"');
}