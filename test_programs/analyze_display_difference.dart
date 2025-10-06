#!/usr/bin/env dart

// Analysis of why display differs between staging and development

class TestDevice {
  final String id;
  final String status;
  final int? pmsRoomId;
  final String? location;
  
  TestDevice({required this.id, required this.status, this.pmsRoomId, this.location});
}

class TestRoomModel {
  final String id;
  final int deviceCount;    // PROBLEM: Should not exist
  final int onlineDevices;  // PROBLEM: Should not exist
  
  TestRoomModel({required this.id, required this.deviceCount, required this.onlineDevices});
}

void main() {
  print('=' * 60);
  print('DISPLAY DIFFERENCE ANALYSIS');
  print('=' * 60);
  
  print('\n1. THE PROBLEM');
  print('-' * 40);
  print('Development and staging show different room percentages because');
  print('they calculate onlineDevices at different layers:');
  
  print('\n2. DEVELOPMENT MODE DATA FLOW');
  print('-' * 40);
  print('Step 1: MockDataService generates devices with:');
  print('  • pmsRoomId: Set correctly (we just fixed this)');
  print('  • location: Still set to roomId string');
  print('');
  print('Step 2: RoomMockDataSource.getRooms():');
  print('  • Line 32: calls getMockDevicesForRoom(room.id)');
  print('  • Line 38: calculates deviceCount from matched devices');
  print('  • Line 39: calculates onlineDevices HERE IN DATA LAYER');
  print('');
  print('Step 3: getMockDevicesForRoom uses:');
  print('  • d.location == roomId (NOT using pmsRoomId!)');
  print('  • This still works because location is still set');
  print('');
  print('Step 4: RoomModel created with:');
  print('  • deviceCount: Pre-calculated value');
  print('  • onlineDevices: Pre-calculated value');
  print('  • deviceIds: room.deviceIds (probably empty)');
  print('');
  print('Step 5: room_view_models.dart:');
  print('  • Tries to use pmsRoomId matching');
  print('  • But RoomModel already has onlineDevices set!');
  print('  • The ViewModel calculation is IGNORED');
  
  print('\n3. STAGING MODE DATA FLOW');
  print('-' * 40);
  print('Step 1: API returns room data');
  print('');
  print('Step 2: RoomRemoteDataSource.getRooms():');
  print('  • Line 74: deviceCount from API (probably 0)');
  print('  • Line 75: onlineDevices from API (probably 0)');
  print('  • Line 76: deviceIds extracted (probably empty)');
  print('');
  print('Step 3: RoomModel created with:');
  print('  • deviceCount: 0 (API doesn\'t provide)');
  print('  • onlineDevices: 0 (API doesn\'t provide)');
  print('  • deviceIds: empty');
  print('');
  print('Step 4: room_view_models.dart:');
  print('  • Uses pmsRoomId matching');
  print('  • Calculates real values');
  print('  • Shows correct percentages');
  
  print('\n4. THE CORE ISSUE');
  print('-' * 40);
  print('❌ RoomModel has onlineDevices and deviceCount fields!');
  print('❌ Mock data calculates these in the DATA LAYER');
  print('❌ This violates Clean Architecture');
  print('❌ The ViewModel calculation is bypassed');
  
  print('\n5. WHY THIS IS WRONG');
  print('-' * 40);
  print('Clean Architecture violation:');
  print('  • Domain entities shouldn\'t have calculated fields');
  print('  • RoomModel shouldn\'t know about device counts');
  print('  • Calculations belong in PRESENTATION layer');
  print('');
  print('MVVM violation:');
  print('  • ViewModels should calculate display values');
  print('  • Data layer shouldn\'t pre-calculate UI values');
  
  print('\n6. THE SOLUTION');
  print('-' * 40);
  print('Option A: Remove fields from RoomModel (BEST)');
  print('  • Remove deviceCount and onlineDevices from RoomModel');
  print('  • Let room_view_models.dart do ALL calculations');
  print('  • True Clean Architecture compliance');
  print('');
  print('Option B: Fix getMockDevicesForRoom (QUICK FIX)');
  print('  • Change to use pmsRoomId instead of location');
  print('  • Still architecturally wrong');
  print('  • But would make displays match');
  
  print('\n7. VERIFICATION');
  print('-' * 40);
  
  // Mock devices with both pmsRoomId and location
  final devices = [
    TestDevice(id: 'd1', status: 'online', pmsRoomId: 1, location: '1'),
    TestDevice(id: 'd2', status: 'offline', pmsRoomId: 1, location: '1'),
    TestDevice(id: 'd3', status: 'online', pmsRoomId: 1, location: '1'),
  ];
  
  // Current mock data approach (using location)
  final mockDevicesForRoom = devices.where((d) => d.location == '1').toList();
  final mockOnlineCount = mockDevicesForRoom.where((d) => d.status == 'online').length;
  print('Mock data calculation (using location):');
  print('  Found ${mockDevicesForRoom.length} devices');
  print('  Online: $mockOnlineCount');
  
  // ViewModel approach (using pmsRoomId)
  final vmDevicesForRoom = devices.where((d) => d.pmsRoomId == 1).toList();
  final vmOnlineCount = vmDevicesForRoom.where((d) => d.status == 'online').length;
  print('');
  print('ViewModel calculation (using pmsRoomId):');
  print('  Found ${vmDevicesForRoom.length} devices');
  print('  Online: $vmOnlineCount');
  
  print('\n' + '=' * 60);
  print('RECOMMENDED SOLUTION');
  print('=' * 60);
  
  print('\n1. Remove deviceCount and onlineDevices from RoomModel');
  print('2. Remove these calculations from RoomMockDataSource');
  print('3. Remove these fields from RoomRemoteDataSource');
  print('4. Let room_view_models.dart be the ONLY place that calculates');
  print('5. This ensures consistent behavior across all environments');
  print('');
  print('This follows Clean Architecture: data layer provides data,');
  print('presentation layer calculates display values.');
}