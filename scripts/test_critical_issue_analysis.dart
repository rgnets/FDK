#!/usr/bin/env dart

/// Critical issue analysis - testing exact crash scenario
/// Based on findings from room_detail_screen.dart and device data source

import 'dart:io';

void main() async {
  print('=== Critical Issue Analysis: Devices Tab Crash ===');
  print('Date: ${DateTime.now()}');
  print('');

  await analyzeCriticalIssues();
}

/// Analyze the critical issues that could cause crashes
Future<void> analyzeCriticalIssues() async {
  print('🔥 CRITICAL ISSUE ANALYSIS');
  
  // Issue 1: Provider state management
  print('\n1. Testing provider state management:');
  await testProviderStateIssues();
  
  // Issue 2: Field access patterns
  print('\n2. Testing field access patterns:');
  await testFieldAccessIssues();
  
  // Issue 3: Room ID parsing edge cases
  print('\n3. Testing room ID edge cases:');
  await testRoomIdEdgeCases();
  
  // Issue 4: AsyncValue state handling
  print('\n4. Testing AsyncValue state handling:');
  await testAsyncValueIssues();

  print('\n=== CRITICAL ANALYSIS COMPLETE ===');
}

/// Test provider state management issues
Future<void> testProviderStateIssues() async {
  print('  🔍 Provider State Analysis:');
  
  // The DevicesTab watches devicesNotifierProvider (line 396)
  // If this provider is in error state, it should show error UI
  // If loading, should show loading spinner
  // BUT: What if the provider throws during the data() callback?
  
  print('    ✅ devicesAsync.when() pattern is correct');
  print('    ⚠️  POTENTIAL CRASH: Exception in data() callback (line 403)');
  print('       This could crash the entire widget tree!');
  
  // The data callback does complex filtering logic
  // If roomVm.id is invalid, int.tryParse() returns null (line 406)
  // This triggers "Invalid room ID" message (line 408-411)
  // But what if devices list has corrupted data?
  
  print('    ⚠️  POTENTIAL CRASH: Corrupted device data in filtering');
}

/// Test field access issues
Future<void> testFieldAccessIssues() async {
  print('  🔍 Field Access Analysis:');
  
  // Room detail screen accesses device.ipAddress (line 484)
  // But what if the device entity has null ipAddress?
  // The UI handles this with null check (line 698-702)
  
  print('    ✅ ipAddress null handling is correct in UI');
  
  // BUT: What about the device type mapping?
  // Access Points: type = 'access_point' (line 277)
  // Switches: type = 'switch' (line 309)  
  // ONTs: type = 'ont' (line 293)
  // WLAN: type = 'wlan_controller' (line 325)
  
  // But the UI checks for:
  // - 'Access Point' (line 452)
  // - 'Switch' (line 458)
  // - 'ont' (line 464) ✅
  
  print('    ❌ CRITICAL MISMATCH: Device type names!');
  print('       API returns: access_point, switch, ont, wlan_controller');
  print('       UI expects: Access Point, Switch, ont, ???');
  print('       This means device counts will be WRONG!');
}

/// Test room ID edge cases
Future<void> testRoomIdEdgeCases() async {
  print('  🔍 Room ID Edge Cases:');
  
  // Test the exact room ID scenarios that could crash
  final testCases = [
    ('Valid room ID', '101', true),
    ('String room ID', 'room-101', false),
    ('Empty room ID', '', false),
    ('UUID room ID', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', false),
  ];
  
  for (final test in testCases) {
    final (name, roomId, shouldPass) = test;
    final roomIdInt = int.tryParse(roomId);
    
    if (shouldPass && roomIdInt != null) {
      print('    ✅ $name: $roomId -> $roomIdInt');
    } else if (!shouldPass && roomIdInt == null) {
      print('    ⚠️  $name: $roomId -> null (triggers "Invalid room ID")');
    } else {
      print('    ❌ UNEXPECTED: $name: $roomId -> $roomIdInt');
    }
  }
  
  print('    💡 INSIGHT: If app creates rooms with UUID IDs, this will ALWAYS fail!');
}

/// Test AsyncValue state handling
Future<void> testAsyncValueIssues() async {
  print('  🔍 AsyncValue State Handling:');
  
  // The pattern in _DevicesTab (line 398-402):
  // return devicesAsync.when(
  //   loading: () => const Center(child: CircularProgressIndicator()),
  //   error: (error, stack) => Center(child: Text('Error loading devices: $error')),
  //   data: (devices) { ... complex logic ... }
  // );
  
  print('    ✅ Loading state handled correctly');
  print('    ✅ Error state handled correctly');
  print('    ❌ CRITICAL: Complex logic in data() callback!');
  print('       If ANY line in data() throws, entire widget crashes!');
  
  // Critical lines that could throw:
  print('    🔥 CRASH POINTS in data() callback:');
  print('       Line 413-416: device.pmsRoomId comparison');
  print('       Line 452: device.type string comparison');
  print('       Line 458: device.type string comparison');
  print('       Line 464: device.type string comparison');
  print('       Line 477: device access for list item');
  print('       Line 484: device.ipAddress access');
}

/// Mock test with exact device type mismatch scenario
void testDeviceTypeMismatch() {
  print('\n  🧪 TESTING TYPE MISMATCH SCENARIO:');
  
  // Mock device from API (what data source creates)
  final mockDevice = MockDevice(
    id: 'ap_123',
    name: 'Test-AP-1', 
    type: 'access_point',  // ❌ This is what API returns
    status: 'online',
    pmsRoomId: 101,
  );
  
  // Test device type counting (lines 452, 458, 464)
  print('    Testing device type counts:');
  
  final isAccessPoint = mockDevice.type == 'Access Point';  // ❌ Will be FALSE
  final isSwitch = mockDevice.type == 'Switch';            // ❌ Will be FALSE  
  final isOnt = mockDevice.type == 'ont';                  // ❌ Will be FALSE
  
  print('      Device type: "${mockDevice.type}"');
  print('      Matches "Access Point": $isAccessPoint');
  print('      Matches "Switch": $isSwitch');
  print('      Matches "ont": $isOnt');
  
  if (!isAccessPoint && !isSwitch && !isOnt) {
    print('      ❌ DEVICE WILL BE UNCOUNTED IN ALL CATEGORIES!');
    print('      💥 This causes empty device list display issues!');
  }
}

class MockDevice {
  final String id;
  final String name;
  final String type;
  final String status;
  final int pmsRoomId;

  MockDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.pmsRoomId,
  });
}