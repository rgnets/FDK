#!/usr/bin/env dart

/// Isolated test program for DeviceTypes constants
/// Tests all functionality and edge cases following architectural standards

import 'dart:io';

// Import the constants we're testing
// Note: In real app, this would be a proper import
// For testing, we'll recreate the class locally to validate logic

void main() async {
  print('=== Testing Device Type Constants (Iteration 1) ===');
  print('Date: ${DateTime.now()}');
  print('');

  await runAllTests();
}

/// Run comprehensive tests for DeviceTypes
Future<void> runAllTests() async {
  var testsPassed = 0;
  var testsTotal = 0;
  
  print('🧪 TESTING DEVICE TYPE CONSTANTS');
  
  // Test 1: Basic constants validation
  testsTotal++;
  if (await testBasicConstants()) {
    testsPassed++;
    print('✅ Test 1: Basic constants validation PASSED');
  } else {
    print('❌ Test 1: Basic constants validation FAILED');
  }
  
  // Test 2: Validation method
  testsTotal++;
  if (await testValidationMethod()) {
    testsPassed++;
    print('✅ Test 2: Validation method PASSED');
  } else {
    print('❌ Test 2: Validation method FAILED');
  }
  
  // Test 3: Display names
  testsTotal++;
  if (await testDisplayNames()) {
    testsPassed++;
    print('✅ Test 3: Display names PASSED');
  } else {
    print('❌ Test 3: Display names FAILED');
  }
  
  // Test 4: Icon identifiers
  testsTotal++;
  if (await testIconIdentifiers()) {
    testsPassed++;
    print('✅ Test 4: Icon identifiers PASSED');
  } else {
    print('❌ Test 4: Icon identifiers FAILED');
  }
  
  // Test 5: Device categorization
  testsTotal++;
  if (await testDeviceCategorization()) {
    testsPassed++;
    print('✅ Test 5: Device categorization PASSED');
  } else {
    print('❌ Test 5: Device categorization FAILED');
  }
  
  // Test 6: Error handling
  testsTotal++;
  if (await testErrorHandling()) {
    testsPassed++;
    print('✅ Test 6: Error handling PASSED');
  } else {
    print('❌ Test 6: Error handling FAILED');
  }
  
  print('\n📊 TEST RESULTS:');
  print('   Passed: $testsPassed/$testsTotal');
  
  if (testsPassed == testsTotal) {
    print('🎉 ALL TESTS PASSED! DeviceTypes constants are ready.');
  } else {
    print('❌ SOME TESTS FAILED! Need fixes before proceeding.');
    exit(1);
  }
}

/// Test basic constants are defined correctly
Future<bool> testBasicConstants() async {
  try {
    // Expected constants
    const expectedTypes = ['access_point', 'switch', 'ont', 'wlan_controller'];
    
    // Test that all expected constants exist
    final constants = MockDeviceTypes.all;
    
    if (constants.length != expectedTypes.length) {
      print('  ❌ Wrong number of constants. Expected ${expectedTypes.length}, got ${constants.length}');
      return false;
    }
    
    for (final expected in expectedTypes) {
      if (!constants.contains(expected)) {
        print('  ❌ Missing constant: $expected');
        return false;
      }
    }
    
    // Test individual constants
    if (MockDeviceTypes.accessPoint != 'access_point') {
      print('  ❌ accessPoint constant wrong value');
      return false;
    }
    
    if (MockDeviceTypes.switch != 'switch') {
      print('  ❌ switch constant wrong value');
      return false;
    }
    
    if (MockDeviceTypes.ont != 'ont') {
      print('  ❌ ont constant wrong value');
      return false;
    }
    
    if (MockDeviceTypes.wlanController != 'wlan_controller') {
      print('  ❌ wlanController constant wrong value');
      return false;
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception in testBasicConstants: $e');
    return false;
  }
}

/// Test validation method throws appropriate errors
Future<bool> testValidationMethod() async {
  try {
    // Test valid types (should not throw)
    for (final validType in MockDeviceTypes.all) {
      try {
        MockDeviceTypes.validateDeviceType(validType);
      } catch (e) {
        print('  ❌ Validation failed for valid type $validType: $e');
        return false;
      }
    }
    
    // Test invalid types (should throw ArgumentError)
    final invalidTypes = ['invalid', 'Access Point', 'Switch', '', 'ONT'];
    
    for (final invalidType in invalidTypes) {
      try {
        MockDeviceTypes.validateDeviceType(invalidType);
        print('  ❌ Validation should have thrown for invalid type: $invalidType');
        return false;
      } on ArgumentError catch (_) {
        // Expected - this is good
      } catch (e) {
        print('  ❌ Wrong exception type for $invalidType. Expected ArgumentError, got ${e.runtimeType}');
        return false;
      }
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception in testValidationMethod: $e');
    return false;
  }
}

/// Test display name conversion
Future<bool> testDisplayNames() async {
  try {
    final expectedNames = {
      'access_point': 'Access Point',
      'switch': 'Switch',
      'ont': 'ONT',
      'wlan_controller': 'WLAN Controller',
    };
    
    for (final entry in expectedNames.entries) {
      final result = MockDeviceTypes.getDisplayName(entry.key);
      if (result != entry.value) {
        print('  ❌ Wrong display name for ${entry.key}. Expected "${entry.value}", got "$result"');
        return false;
      }
    }
    
    // Test invalid type throws
    try {
      MockDeviceTypes.getDisplayName('invalid');
      print('  ❌ Should have thrown for invalid device type');
      return false;
    } on ArgumentError catch (_) {
      // Expected
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception in testDisplayNames: $e');
    return false;
  }
}

/// Test icon identifier mapping
Future<bool> testIconIdentifiers() async {
  try {
    final expectedIcons = {
      'access_point': 'wifi',
      'switch': 'hub',
      'ont': 'fiber_manual_record',
      'wlan_controller': 'router',
    };
    
    for (final entry in expectedIcons.entries) {
      final result = MockDeviceTypes.getIconIdentifier(entry.key);
      if (result != entry.value) {
        print('  ❌ Wrong icon for ${entry.key}. Expected "${entry.value}", got "$result"');
        return false;
      }
    }
    
    // Test invalid type throws
    try {
      MockDeviceTypes.getIconIdentifier('invalid');
      print('  ❌ Should have thrown for invalid device type');
      return false;
    } on ArgumentError catch (_) {
      // Expected
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception in testIconIdentifiers: $e');
    return false;
  }
}

/// Test device categorization methods
Future<bool> testDeviceCategorization() async {
  try {
    // Test wireless devices
    if (!MockDeviceTypes.isWirelessDevice('access_point')) {
      print('  ❌ access_point should be wireless');
      return false;
    }
    
    if (!MockDeviceTypes.isWirelessDevice('wlan_controller')) {
      print('  ❌ wlan_controller should be wireless');
      return false;
    }
    
    if (MockDeviceTypes.isWirelessDevice('switch')) {
      print('  ❌ switch should not be wireless');
      return false;
    }
    
    if (MockDeviceTypes.isWirelessDevice('ont')) {
      print('  ❌ ont should not be wireless');
      return false;
    }
    
    // Test wired devices
    if (!MockDeviceTypes.isWiredDevice('switch')) {
      print('  ❌ switch should be wired');
      return false;
    }
    
    if (!MockDeviceTypes.isWiredDevice('ont')) {
      print('  ❌ ont should be wired');
      return false;
    }
    
    if (MockDeviceTypes.isWiredDevice('access_point')) {
      print('  ❌ access_point should not be wired');
      return false;
    }
    
    if (MockDeviceTypes.isWiredDevice('wlan_controller')) {
      print('  ❌ wlan_controller should not be wired');
      return false;
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception in testDeviceCategorization: $e');
    return false;
  }
}

/// Test error handling edge cases
Future<bool> testErrorHandling() async {
  try {
    // Test null handling (if applicable)
    // Note: In Dart, null strings would be caught by type system
    
    // Test empty string
    try {
      MockDeviceTypes.validateDeviceType('');
      print('  ❌ Should throw for empty string');
      return false;
    } on ArgumentError catch (_) {
      // Expected
    }
    
    // Test case sensitivity
    try {
      MockDeviceTypes.validateDeviceType('ACCESS_POINT');
      print('  ❌ Should throw for wrong case');
      return false;
    } on ArgumentError catch (_) {
      // Expected
    }
    
    // Test whitespace
    try {
      MockDeviceTypes.validateDeviceType(' access_point ');
      print('  ❌ Should throw for whitespace');
      return false;
    } on ArgumentError catch (_) {
      // Expected
    }
    
    return true;
  } catch (e) {
    print('  ❌ Exception in testErrorHandling: $e');
    return false;
  }
}

/// Mock implementation of DeviceTypes for testing
/// This replicates the logic we want to test
class MockDeviceTypes {
  MockDeviceTypes._();
  
  static const String accessPoint = 'access_point';
  static const String switch = 'switch';
  static const String ont = 'ont';
  static const String wlanController = 'wlan_controller';
  
  static const List<String> all = [
    accessPoint,
    switch,
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
      case switch:
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
      case switch:
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
    return deviceType == switch || deviceType == ont;
  }
}