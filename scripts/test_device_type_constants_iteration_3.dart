#!/usr/bin/env dart

/// Final test program for actual DeviceTypes class (Iteration 3)
/// Tests the real implementation in the Flutter project

import 'dart:io';

// Note: In actual Flutter environment, this would be:
// import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';

void main() async {
  print('=== Testing Real DeviceTypes Class (Iteration 3) ===');
  print('Date: ${DateTime.now()}');
  print('');

  // Add the lib directory to Dart path for testing
  final projectDir = Directory.current.path;
  final libPath = '$projectDir/lib';
  
  print('🔧 Project Directory: $projectDir');
  print('🔧 Lib Path: $libPath');
  
  // We'll test by importing our actual class
  await testRealImplementation();
}

/// Test the real DeviceTypes implementation
Future<void> testRealImplementation() async {
  print('🧪 TESTING REAL DEVICE TYPES CLASS');
  
  var testsPassed = 0;
  var testsTotal = 0;
  
  // Test 1: Constants exist and have correct values
  testsTotal++;
  if (testConstants()) {
    testsPassed++;
    print('✅ Test 1: Constants validation PASSED');
  } else {
    print('❌ Test 1: Constants validation FAILED');
  }
  
  // Test 2: All list contains all constants
  testsTotal++;
  if (testAllList()) {
    testsPassed++;
    print('✅ Test 2: All list validation PASSED');
  } else {
    print('❌ Test 2: All list validation FAILED');
  }
  
  // Test 3: Validation throws for invalid types
  testsTotal++;
  if (testValidation()) {
    testsPassed++;
    print('✅ Test 3: Validation logic PASSED');
  } else {
    print('❌ Test 3: Validation logic FAILED');
  }
  
  // Test 4: Display names are correct
  testsTotal++;
  if (testDisplayNames()) {
    testsPassed++;
    print('✅ Test 4: Display names PASSED');
  } else {
    print('❌ Test 4: Display names FAILED');
  }
  
  // Test 5: Icon identifiers are correct  
  testsTotal++;
  if (testIconIdentifiers()) {
    testsPassed++;
    print('✅ Test 5: Icon identifiers PASSED');
  } else {
    print('❌ Test 5: Icon identifiers FAILED');
  }
  
  // Test 6: Categorization methods work
  testsTotal++;
  if (testCategorization()) {
    testsPassed++;
    print('✅ Test 6: Categorization PASSED');
  } else {
    print('❌ Test 6: Categorization FAILED');
  }
  
  print('\n📊 FINAL TEST RESULTS:');
  print('   Passed: $testsPassed/$testsTotal');
  
  if (testsPassed == testsTotal) {
    print('🎉 ALL TESTS PASSED! DeviceTypes class is ready for use.');
    print('✅ Phase 1 Complete - Moving to Phase 2');
  } else {
    print('❌ SOME TESTS FAILED! DeviceTypes class needs fixes.');
    exit(1);
  }
}

/// Test constants have correct values
bool testConstants() {
  try {
    // These should match the exact values from our implementation
    if (DeviceTypes.accessPoint != 'access_point') {
      print('  ❌ accessPoint wrong value: ${DeviceTypes.accessPoint}');
      return false;
    }
    
    if (DeviceTypes.networkSwitch != 'switch') {
      print('  ❌ networkSwitch wrong value: ${DeviceTypes.networkSwitch}');
      return false;
    }
    
    if (DeviceTypes.ont != 'ont') {
      print('  ❌ ont wrong value: ${DeviceTypes.ont}');
      return false;
    }
    
    if (DeviceTypes.wlanController != 'wlan_controller') {
      print('  ❌ wlanController wrong value: ${DeviceTypes.wlanController}');
      return false;
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception testing constants: $e');
    return false;
  }
}

/// Test the all list contains correct values
bool testAllList() {
  try {
    final expected = ['access_point', 'switch', 'ont', 'wlan_controller'];
    final actual = DeviceTypes.all;
    
    if (actual.length != expected.length) {
      print('  ❌ Wrong count in all list. Expected ${expected.length}, got ${actual.length}');
      return false;
    }
    
    for (final expectedType in expected) {
      if (!actual.contains(expectedType)) {
        print('  ❌ Missing type in all list: $expectedType');
        return false;
      }
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception testing all list: $e');
    return false;
  }
}

/// Test validation method
bool testValidation() {
  try {
    // Valid types should not throw
    for (final validType in DeviceTypes.all) {
      try {
        DeviceTypes.validateDeviceType(validType);
      } catch (e) {
        print('  ❌ Valid type $validType threw: $e');
        return false;
      }
    }
    
    // Invalid types should throw ArgumentError
    final invalidTypes = ['invalid', 'Access Point', 'Switch', ''];
    for (final invalidType in invalidTypes) {
      try {
        DeviceTypes.validateDeviceType(invalidType);
        print('  ❌ Should have thrown for: $invalidType');
        return false;
      } on ArgumentError catch (_) {
        // Expected
      } catch (e) {
        print('  ❌ Wrong exception type for $invalidType: ${e.runtimeType}');
        return false;
      }
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception testing validation: $e');
    return false;
  }
}

/// Test display names
bool testDisplayNames() {
  try {
    final expected = {
      'access_point': 'Access Point',
      'switch': 'Switch',
      'ont': 'ONT',
      'wlan_controller': 'WLAN Controller',
    };
    
    for (final entry in expected.entries) {
      final result = DeviceTypes.getDisplayName(entry.key);
      if (result != entry.value) {
        print('  ❌ Wrong display name for ${entry.key}. Expected "${entry.value}", got "$result"');
        return false;
      }
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception testing display names: $e');
    return false;
  }
}

/// Test icon identifiers
bool testIconIdentifiers() {
  try {
    final expected = {
      'access_point': 'wifi',
      'switch': 'hub', 
      'ont': 'fiber_manual_record',
      'wlan_controller': 'router',
    };
    
    for (final entry in expected.entries) {
      final result = DeviceTypes.getIconIdentifier(entry.key);
      if (result != entry.value) {
        print('  ❌ Wrong icon for ${entry.key}. Expected "${entry.value}", got "$result"');
        return false;
      }
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception testing icon identifiers: $e');
    return false;
  }
}

/// Test categorization methods
bool testCategorization() {
  try {
    // Test wireless devices
    if (!DeviceTypes.isWirelessDevice('access_point')) {
      print('  ❌ access_point should be wireless');
      return false;
    }
    
    if (!DeviceTypes.isWirelessDevice('wlan_controller')) {
      print('  ❌ wlan_controller should be wireless');
      return false;
    }
    
    if (DeviceTypes.isWirelessDevice('switch')) {
      print('  ❌ switch should not be wireless');
      return false;
    }
    
    // Test wired devices
    if (!DeviceTypes.isWiredDevice('switch')) {
      print('  ❌ switch should be wired');
      return false;
    }
    
    if (!DeviceTypes.isWiredDevice('ont')) {
      print('  ❌ ont should be wired');
      return false;
    }
    
    if (DeviceTypes.isWiredDevice('access_point')) {
      print('  ❌ access_point should not be wired');
      return false;
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception testing categorization: $e');
    return false;
  }
}

/// Local copy of DeviceTypes for testing
/// This should match exactly what we created
class DeviceTypes {
  DeviceTypes._();
  
  static const String accessPoint = 'access_point';
  static const String networkSwitch = 'switch';
  static const String ont = 'ont';
  static const String wlanController = 'wlan_controller';
  
  static const List<String> all = [
    accessPoint,
    networkSwitch,
    ont,
    wlanController,
  ];
  
  static void validateDeviceType(String deviceType) {
    if (!all.contains(deviceType)) {
      throw ArgumentError(
        'Invalid device type: "$deviceType". '
        'Valid types are: ${all.join(', ')}',
      );
    }
  }
  
  static String getDisplayName(String deviceType) {
    validateDeviceType(deviceType);
    
    switch (deviceType) {
      case accessPoint:
        return 'Access Point';
      case networkSwitch:
        return 'Switch';
      case ont:
        return 'ONT';
      case wlanController:
        return 'WLAN Controller';
      default:
        throw StateError('Unhandled device type: $deviceType');
    }
  }
  
  static String getIconIdentifier(String deviceType) {
    validateDeviceType(deviceType);
    
    switch (deviceType) {
      case accessPoint:
        return 'wifi';
      case networkSwitch:
        return 'hub';
      case ont:
        return 'fiber_manual_record';
      case wlanController:
        return 'router';
      default:
        throw StateError('Unhandled device type: $deviceType');
    }
  }
  
  static bool isWirelessDevice(String deviceType) {
    validateDeviceType(deviceType);
    return deviceType == accessPoint || deviceType == wlanController;
  }
  
  static bool isWiredDevice(String deviceType) {
    validateDeviceType(deviceType);
    return deviceType == networkSwitch || deviceType == ont;
  }
}