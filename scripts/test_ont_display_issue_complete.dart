#!/usr/bin/env dart

import 'dart:math';

/// Complete test for ONT display issue
void main() {
  print('=' * 80);
  print('ONT DISPLAY ISSUE - COMPLETE ANALYSIS');
  print('=' * 80);
  
  print('\n📌 FACT 1: MOCK DATA GENERATION');
  print('-' * 40);
  print('mock_data_service.dart creates ONTs:');
  print('  Line 350: type: \'ont\' (LOWERCASE)');
  print('  ✅ This is CORRECT - matches staging API');
  
  print('\n📌 FACT 2: STAGING API');
  print('-' * 40);
  print('device_remote_data_source.dart:');
  print('  Line 293: type: \'ont\' (LOWERCASE)');
  print('  ✅ Staging returns lowercase \'ont\'');
  
  print('\n📌 FACT 3: DEVICETYPEUTILS');
  print('-' * 40);
  print('DeviceTypeUtils.isONT():');
  print('  Uses: type.toLowerCase() == \'ont\'');
  print('  ✅ Correctly handles case-insensitive check');
  
  print('\n❌ PROBLEM LOCATIONS');
  print('-' * 40);
  
  final problemLocations = [
    'mock_data_service.dart:38    - d.type == \'ONT\' (logging)',
    'mock_data_service.dart:644   - d.type == \'ONT\' (statistics)',
    'mock_data_service.dart:650   - d.type == \'ONT\' (statistics)',
    'mock_data_service.dart:929   - d.type == \'ONT\' (JSON generation)',
    'room_detail_screen.dart:464  - d.type == \'ONT\' (device count)',
    'room_detail_screen.dart:681  - device[\'type\'] == \'ONT\' (icon selection)',
  ];
  
  for (final location in problemLocations) {
    print('  ❌ $location');
  }
  
  print('\n✅ CORRECT LOCATIONS');
  print('-' * 40);
  print('  ✅ devices_screen.dart:168 - d.type == \'ont\' (lowercase)');
  print('  ✅ DeviceTypeUtils - uses lowercase comparison');
  
  print('\n🔍 SIMULATION');
  print('-' * 40);
  
  // Simulate the issue
  final devices = [
    Device('ont-1', 'ONT1-1-0001', 'ont'),
    Device('ont-2', 'ONT1-1-0002', 'ont'),
    Device('ap-1', 'AP1-1-0001', 'access_point'),
  ];
  
  print('Total devices: ${devices.length}');
  
  // Wrong way (uppercase check)
  final ontCountWrong = devices.where((d) => d.type == 'ONT').length;
  print('ONTs with type == \'ONT\': $ontCountWrong ❌');
  
  // Right way (lowercase check)
  final ontCountRight = devices.where((d) => d.type == 'ont').length;
  print('ONTs with type == \'ont\': $ontCountRight ✅');
  
  // Best way (using utility)
  final ontCountBest = devices.where((d) => isONT(d.type)).length;
  print('ONTs with DeviceTypeUtils.isONT(): $ontCountBest ✅');
  
  print('\n💡 ROOT CAUSE');
  print('-' * 40);
  print('The mock data correctly creates ONTs with type \'ont\' (lowercase)');
  print('BUT several UI and statistics checks look for \'ONT\' (uppercase)');
  print('Result: ONTs exist but are not counted or displayed!');
  
  print('\n🎯 SOLUTION');
  print('-' * 40);
  print('Fix all uppercase \'ONT\' checks to use lowercase \'ont\'');
  print('OR better: use DeviceTypeUtils.isONT() everywhere');
  print('');
  print('Specific fixes needed:');
  print('1. mock_data_service.dart - change 4 occurrences');
  print('2. room_detail_screen.dart - change 2 occurrences');
  
  print('\n🏗️ ARCHITECTURE COMPLIANCE');
  print('-' * 40);
  print('✅ Using DeviceTypeUtils follows Clean Architecture');
  print('✅ Domain layer utility for type checking');
  print('✅ Single source of truth for type logic');
  print('✅ Consistent with staging environment');
  
  print('\n📋 QUESTIONS FOR USER');
  print('-' * 40);
  print('1. Should I fix the uppercase \'ONT\' checks to lowercase?');
  print('2. OR should I use DeviceTypeUtils.isONT() everywhere?');
  print('3. The staging API uses lowercase \'ont\' - is this correct?');
  
  print('\n' + '=' * 80);
  print('ANALYSIS COMPLETE - AWAITING DIRECTION');
  print('=' * 80);
}

// Test classes
class Device {
  final String id;
  final String name;
  final String type;
  
  Device(this.id, this.name, this.type);
}

bool isONT(String type) {
  return type.toLowerCase() == 'ont';
}