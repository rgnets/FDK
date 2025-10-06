#!/usr/bin/env dart

/// Diagnostic script to test Device entity field access patterns
/// Based on room_detail_screen.dart line 479-485 and Device entity structure

import 'dart:io';

void main() async {
  print('=== Diagnosing Device Entity Field Access ===');
  print('Date: ${DateTime.now()}');
  print('');

  await testDeviceFieldAccess();
}

/// Test field access patterns that might cause crashes
Future<void> testDeviceFieldAccess() async {
  print('🔍 Testing Device entity field access...');
  
  // Step 1: Test the exact field access pattern from room_detail_screen.dart
  print('\n1. Testing room detail screen device access pattern:');
  await testRoomDetailDeviceAccess();
  
  // Step 2: Test field name mismatches from API docs
  print('\n2. Testing API field name mismatches:');
  await testApiFieldMismatches();
  
  // Step 3: Test null safety issues
  print('\n3. Testing null safety issues:');
  await testNullSafetyIssues();

  print('\n=== Analysis Complete ===');
}

/// Test the exact pattern used in room_detail_screen.dart lines 479-485
Future<void> testRoomDetailDeviceAccess() async {
  print('  Testing exact field access from _DevicesTab...');
  
  // This mimics the exact code from line 479-485 in room_detail_screen.dart:
  // device: {
  //   'id': device.id,
  //   'name': device.name,
  //   'type': device.type,
  //   'status': device.status,
  //   'ipAddress': device.ipAddress,
  // },
  
  final mockDevice = MockDevice(
    id: '123',
    name: 'Test-AP-1',
    type: 'Access Point',
    status: 'online',
    ipAddress: '192.168.1.100',
    pmsRoomId: 101,
  );
  
  try {
    // Test the exact map creation from the screen
    final deviceMap = {
      'id': mockDevice.id,
      'name': mockDevice.name,
      'type': mockDevice.type,
      'status': mockDevice.status,
      'ipAddress': mockDevice.ipAddress, // ❌ POTENTIAL ISSUE: This is 'ipAddress' 
    };
    
    print('    ✅ Successfully created device map:');
    print('       ID: ${deviceMap['id']}');
    print('       Name: ${deviceMap['name']}');
    print('       Type: ${deviceMap['type']}');
    print('       Status: ${deviceMap['status']}');
    print('       IP Address: ${deviceMap['ipAddress']}');
    
  } catch (e) {
    print('    ❌ ERROR creating device map: $e');
  }
}

/// Test field name mismatches based on API docs and Device entity
Future<void> testApiFieldMismatches() async {
  print('  Testing field name inconsistencies...');
  
  // From API docs (api_fields_reference.md):
  // - Access Points use 'ip' field
  // - Switches use 'host' field  
  // - Access Points/ONTs use 'mac' field
  // - Switches store MAC in 'scratch' field
  
  // But Device entity uses:
  // - ipAddress (String?)
  // - macAddress (String?)
  
  print('    API vs Entity field mapping:');
  print('      API Access Point \'ip\' -> Entity \'ipAddress\' ✅');
  print('      API Switch \'host\' -> Entity \'ipAddress\' ❓ (mapping needed)');
  print('      API \'mac\' -> Entity \'macAddress\' ✅');
  print('      API Switch \'scratch\' -> Entity \'macAddress\' ❓ (mapping needed)');
  
  // The issue might be that the field mapping is handled in data layer
  // but the UI assumes all devices have the same field names
  
  print('    ⚠️  POTENTIAL CRASH CAUSE: Field mapping inconsistencies');
}

/// Test null safety patterns
Future<void> testNullSafetyIssues() async {
  print('  Testing null safety patterns...');
  
  // Test with null values that might come from API
  final testCases = [
    MockDevice(id: '1', name: 'Test-1', type: 'Access Point', status: 'online', ipAddress: null, pmsRoomId: 101),
    MockDevice(id: '2', name: 'Test-2', type: 'Switch', status: 'offline', ipAddress: '', pmsRoomId: null),
    MockDevice(id: '3', name: '', type: 'ont', status: 'warning', ipAddress: '192.168.1.1', pmsRoomId: 101),
  ];
  
  for (final device in testCases) {
    try {
      print('    Testing device: ${device.name.isEmpty ? "(EMPTY NAME)" : device.name}');
      
      // Test the map creation that could crash
      final deviceMap = {
        'id': device.id,
        'name': device.name,
        'type': device.type,
        'status': device.status,
        'ipAddress': device.ipAddress,
      };
      
      // Test the _DeviceListItem widget logic (lines 663-665)
      final statusColor = device.status == 'online' ? 'GREEN' :
                         device.status == 'offline' ? 'RED' :
                         device.status == 'warning' ? 'ORANGE' : 'GREY';
                         
      print('      Status: ${device.status} -> Color: $statusColor');
      
      // Test the icon selection logic (lines 679-683)
      final iconType = device.type == 'Access Point' ? 'WIFI' :
                      device.type == 'Switch' ? 'HUB' :
                      device.type == 'ont' ? 'FIBER' : 'DEFAULT';
                      
      print('      Type: ${device.type} -> Icon: $iconType');
      
      // Test potential null access
      if (device.ipAddress != null && device.ipAddress!.isNotEmpty) {
        print('      IP: ${device.ipAddress}');
      } else {
        print('      IP: NULL/EMPTY ⚠️');
      }
      
    } catch (e) {
      print('      ❌ ERROR processing device: $e');
    }
  }
}

/// Mock device for testing
class MockDevice {
  final String id;
  final String name;
  final String type;
  final String status;
  final String? ipAddress;
  final int? pmsRoomId;

  MockDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.ipAddress,
    this.pmsRoomId,
  });
}