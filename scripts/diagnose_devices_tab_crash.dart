#!/usr/bin/env dart

/// Diagnostic script to test the devices tab crash in room detail view
/// This script mimics the exact code path that the DevicesTab widget follows

import 'dart:io';

void main() async {
  print('=== Diagnosing Devices Tab Crash ===');
  print('Date: ${DateTime.now()}');
  print('');

  // Simulate the crash scenario based on the room detail screen code
  await testDevicesTabLogic();
}

/// Test the devices tab logic that might be crashing
Future<void> testDevicesTabLogic() async {
  print('🔍 Testing DevicesTab logic...');
  
  // Step 1: Test room ID parsing (line 406-411 in room_detail_screen.dart)
  print('\n1. Testing room ID parsing:');
  await testRoomIdParsing();
  
  // Step 2: Test device filtering logic (line 413-416)
  print('\n2. Testing device filtering logic:');
  await testDeviceFiltering();
  
  // Step 3: Test device type counting (line 448-465)
  print('\n3. Testing device type counting:');
  await testDeviceTypeCounting();
  
  // Step 4: Test device list item creation (line 472-499)
  print('\n4. Testing device list item creation:');
  await testDeviceListItemCreation();

  print('\n=== Analysis Complete ===');
}

/// Test room ID parsing logic from line 406-411
Future<void> testRoomIdParsing() async {
  // Test cases that might crash
  final testCases = [
    '1',        // Valid numeric
    '101',      // Valid numeric
    'abc',      // Invalid - should return null
    '',         // Empty string
    'null',     // String "null"
  ];

  for (final roomId in testCases) {
    try {
      final roomIdInt = int.tryParse(roomId);
      print('  Room ID "$roomId" -> $roomIdInt ${roomIdInt == null ? "(INVALID)" : "(VALID)"}');
      
      if (roomIdInt == null) {
        print('    ⚠️  This would trigger "Invalid room ID" error in UI');
      }
    } catch (e) {
      print('  ❌ ERROR parsing room ID "$roomId": $e');
    }
  }
}

/// Test device filtering logic from line 413-416  
Future<void> testDeviceFiltering() async {
  // Mock device data similar to what the app might receive
  final mockDevices = [
    MockDevice(id: '1', name: 'AP-1', type: 'Access Point', status: 'online', pmsRoomId: 101),
    MockDevice(id: '2', name: 'SW-1', type: 'Switch', status: 'offline', pmsRoomId: 102),
    MockDevice(id: '3', name: 'ONT-1', type: 'ont', status: 'online', pmsRoomId: 101),
    MockDevice(id: '4', name: 'AP-2', type: 'Access Point', status: 'warning', pmsRoomId: null), // null room
  ];

  final testRoomId = 101;
  
  try {
    final roomDevices = mockDevices.where((device) {
      return device.pmsRoomId == testRoomId;
    }).toList();
    
    print('  Total devices: ${mockDevices.length}');
    print('  Devices for room $testRoomId: ${roomDevices.length}');
    
    for (final device in roomDevices) {
      print('    - ${device.name} (${device.type}) - ${device.status}');
    }
    
    if (roomDevices.isEmpty) {
      print('  ⚠️  Empty device list would show EmptyState widget');
    }
    
  } catch (e) {
    print('  ❌ ERROR in device filtering: $e');
  }
}

/// Test device type counting from line 448-465
Future<void> testDeviceTypeCounting() async {
  final mockDevices = [
    MockDevice(id: '1', name: 'AP-1', type: 'Access Point', status: 'online', pmsRoomId: 101),
    MockDevice(id: '2', name: 'SW-1', type: 'Switch', status: 'offline', pmsRoomId: 101),
    MockDevice(id: '3', name: 'ONT-1', type: 'ont', status: 'online', pmsRoomId: 101),
    MockDevice(id: '4', name: 'AP-2', type: 'Access Point', status: 'warning', pmsRoomId: 101),
  ];

  try {
    // Test the exact device type filtering from the code
    final accessPointCount = mockDevices.where((d) => d.type == 'Access Point').length;
    final switchCount = mockDevices.where((d) => d.type == 'Switch').length; 
    final ontCount = mockDevices.where((d) => d.type == 'ont').length; // lowercase!
    
    print('  Access Points: $accessPointCount');
    print('  Switches: $switchCount');
    print('  ONTs: $ontCount');
    print('  Total: ${mockDevices.length}');
    
    // Test potential issues
    if (accessPointCount + switchCount + ontCount != mockDevices.length) {
      print('  ⚠️  Device type counts don\'t match total - possible type mismatch!');
    }
    
  } catch (e) {
    print('  ❌ ERROR in device type counting: $e');
  }
}

/// Test device list item creation from line 472-499
Future<void> testDeviceListItemCreation() async {
  final mockDevices = [
    MockDevice(id: '1', name: 'AP-1', type: 'Access Point', status: 'online', pmsRoomId: 101, ipAddress: '192.168.1.1'),
    MockDevice(id: '2', name: 'SW-1', type: 'Switch', status: 'offline', pmsRoomId: 101, ipAddress: null), // null IP
    MockDevice(id: '3', name: 'ONT-1', type: 'ont', status: 'online', pmsRoomId: 101, ipAddress: ''),     // empty IP
  ];

  try {
    for (int index = 0; index < mockDevices.length; index++) {
      final device = mockDevices[index];
      
      // This is the exact data structure created in lines 479-485
      final deviceMap = {
        'id': device.id,
        'name': device.name,
        'type': device.type,
        'status': device.status,
        'ipAddress': device.ipAddress,
      };
      
      print('  Device $index: ${deviceMap['name']}');
      print('    - ID: ${deviceMap['id']}');
      print('    - Type: ${deviceMap['type']}');
      print('    - Status: ${deviceMap['status']}');
      print('    - IP: ${deviceMap['ipAddress']} ${deviceMap['ipAddress'] == null ? "(NULL)" : deviceMap['ipAddress'] == '' ? "(EMPTY)" : ""}');
      
      // Test potential null/empty issues
      if (deviceMap['name'] == null || deviceMap['name'] == '') {
        print('      ⚠️  NULL/empty name could cause UI issues');
      }
      if (deviceMap['type'] == null) {
        print('      ⚠️  NULL type could cause icon selection issues');
      }
      if (deviceMap['status'] == null) {
        print('      ⚠️  NULL status could cause color selection issues');
      }
    }
    
  } catch (e) {
    print('  ❌ ERROR in device list item creation: $e');
  }
}

/// Mock device class for testing
class MockDevice {
  final String id;
  final String name;
  final String type;
  final String status;
  final int? pmsRoomId;
  final String? ipAddress;

  MockDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.pmsRoomId,
    this.ipAddress,
  });
}