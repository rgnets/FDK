#!/usr/bin/env dart

// Test to understand why staging doesn't show the room percentage changes

void main() {
  print('=' * 60);
  print('STAGING VS DEVELOPMENT DATA FLOW ANALYSIS');
  print('=' * 60);
  
  print('\n1. DEVELOPMENT MODE DATA FLOW');
  print('-' * 40);
  print('RoomMockDataSource.getRooms():');
  print('  • Creates RoomModel with onlineDevices field calculated');
  print('  • Lines 38-39: Counts actual online devices from mock data');
  print('  • RoomModel has onlineDevices = actual count');
  print('');
  print('RoomModel.toEntity():');
  print('  • Converts to Room entity');
  print('  • Room entity does NOT have onlineDevices field');
  print('  • Only has: id, name, deviceIds, etc.');
  print('');
  print('RoomViewModel calculation:');
  print('  • My code calculates from devices: lines 62-73');
  print('  • Gets actual device list and checks status');
  print('  ✅ WORKS because deviceIds are populated');
  
  print('\n2. STAGING MODE DATA FLOW');
  print('-' * 40);
  print('RoomRemoteDataSource.getRooms():');
  print('  • Lines 74-75: Expects API to provide device_count and online_devices');
  print('  • If API doesn\'t provide these, defaults to 0');
  print('  • Creates RoomModel with these values');
  print('');
  print('RoomModel.toEntity():');
  print('  • Converts to Room entity');
  print('  • Room entity does NOT have onlineDevices field');
  print('  • Only has: id, name, deviceIds, etc.');
  print('');
  print('RoomViewModel calculation:');
  print('  • My code calculates from devices: lines 62-73');
  print('  • ISSUE: If room.deviceIds is empty/null, deviceCount = 0');
  print('  • Result: onlineDevices = 0, percentage = 0%');
  
  print('\n3. THE CRITICAL DIFFERENCE');
  print('-' * 40);
  print('DEVELOPMENT:');
  print('  • Mock data provides deviceIds list');
  print('  • My calculation works correctly');
  print('');
  print('STAGING:');
  print('  • API might not provide deviceIds list');
  print('  • Or deviceIds might be extracted incorrectly');
  print('  • Look at line 76: _extractDeviceIds(roomData)');
  
  print('\n4. ROOT CAUSE HYPOTHESIS');
  print('-' * 40);
  print('The issue is likely in RoomRemoteDataSource._extractDeviceIds()');
  print('This method might:');
  print('  • Return empty list for staging API data');
  print('  • Not extract device IDs correctly from API response');
  print('  • Be looking for wrong field names');
  print('');
  print('If deviceIds is empty:');
  print('  • deviceCount = 0 (line 59)');
  print('  • Loop never runs (lines 63-73)');
  print('  • onlineDevices = 0');
  print('  • Percentage = 0%');
  
  print('\n5. WHY OTHER CHANGES WORK IN STAGING');
  print('-' * 40);
  print('Device Network Info:');
  print('  • Pure UI formatting, no data dependency');
  print('  • Works regardless of data source');
  print('');
  print('Notification Title:');
  print('  • Pure UI formatting, no data dependency');
  print('  • Works regardless of data source');
  print('');
  print('Room Percentage:');
  print('  • DEPENDS on room.deviceIds being populated');
  print('  • If deviceIds is empty, calculation fails');
  
  print('\n' + '=' * 60);
  print('SOLUTION');
  print('=' * 60);
  print('\nNeed to check _extractDeviceIds() method in');
  print('room_remote_data_source.dart to ensure it properly');
  print('extracts device IDs from the staging API response.');
  print('');
  print('The room percentage calculation is CORRECT.');
  print('The issue is the DATA (deviceIds) is missing in staging.');
}