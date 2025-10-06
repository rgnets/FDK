#!/usr/bin/env dart

// Test the device ID mismatch issue

class Device {
  final String id;
  final int? pmsRoomId;
  final String status;
  
  Device({required this.id, this.pmsRoomId, required this.status});
}

class Room {
  final String id;
  final String name;
  final List<String>? deviceIds;
  
  Room({required this.id, required this.name, this.deviceIds});
}

// Current implementation that only uses pmsRoomId
List<Device> getDevicesByPmsRoomId(Room room, List<Device> allDevices) {
  final roomIdInt = int.tryParse(room.id);
  if (roomIdInt != null) {
    return allDevices.where((device) => device.pmsRoomId == roomIdInt).toList();
  }
  return [];
}

// Alternative that could use deviceIds from room
List<Device> getDevicesByDeviceIds(Room room, List<Device> allDevices) {
  if (room.deviceIds == null || room.deviceIds!.isEmpty) {
    return [];
  }
  
  return allDevices.where((device) => 
    room.deviceIds!.contains(device.id)
  ).toList();
}

// Hybrid approach - try both methods
List<Device> getDevicesHybrid(Room room, List<Device> allDevices) {
  // First try pmsRoomId matching
  final byPmsRoomId = getDevicesByPmsRoomId(room, allDevices);
  if (byPmsRoomId.isNotEmpty) {
    return byPmsRoomId;
  }
  
  // Fallback to deviceIds if available
  return getDevicesByDeviceIds(room, allDevices);
}

void testScenario(String name, Room room, List<Device> devices) {
  print('\n$name');
  print('=' * 60);
  print('Room: id="${room.id}", name="${room.name}", deviceIds=${room.deviceIds}');
  print('\nDevices:');
  for (final device in devices) {
    print('  ${device.id}: pmsRoomId=${device.pmsRoomId}, status=${device.status}');
  }
  
  print('\nMethod 1 - By pmsRoomId:');
  final byPmsRoomId = getDevicesByPmsRoomId(room, devices);
  print('  Found ${byPmsRoomId.length} devices: ${byPmsRoomId.map((d) => d.id).toList()}');
  final online1 = byPmsRoomId.where((d) => d.status == 'online').length;
  print('  ${online1}/${byPmsRoomId.length} online');
  
  print('\nMethod 2 - By deviceIds:');
  final byDeviceIds = getDevicesByDeviceIds(room, devices);
  print('  Found ${byDeviceIds.length} devices: ${byDeviceIds.map((d) => d.id).toList()}');
  final online2 = byDeviceIds.where((d) => d.status == 'online').length;
  print('  ${online2}/${byDeviceIds.length} online');
  
  print('\nMethod 3 - Hybrid:');
  final hybrid = getDevicesHybrid(room, devices);
  print('  Found ${hybrid.length} devices: ${hybrid.map((d) => d.id).toList()}');
  final online3 = hybrid.where((d) => d.status == 'online').length;
  print('  ${online3}/${hybrid.length} online');
}

void main() {
  print('DEVICE ID MISMATCH ANALYSIS');
  print('=' * 80);
  
  // Scenario 1: Development with matching IDs
  print('\n1. DEVELOPMENT (IDs match)');
  final devRoom = Room(
    id: '1',
    name: 'Conference Room',
    deviceIds: ['ap-001', 'ont-001', 'sw-001'],
  );
  
  final devDevices = [
    Device(id: 'ap-001', pmsRoomId: 1, status: 'online'),
    Device(id: 'ont-001', pmsRoomId: 1, status: 'offline'),
    Device(id: 'sw-001', pmsRoomId: 1, status: 'online'),
    Device(id: 'ap-002', pmsRoomId: 2, status: 'online'),
  ];
  
  testScenario('Development Environment', devRoom, devDevices);
  
  // Scenario 2: Staging with prefixed IDs (THE PROBLEM!)
  print('\n2. STAGING (Prefixed IDs)');
  final stagingRoom = Room(
    id: '1',
    name: 'Room 101',
    deviceIds: ['123', '456', '789'],  // API returns raw IDs
  );
  
  final stagingDevices = [
    Device(id: 'ap_123', pmsRoomId: 1, status: 'online'),    // Prefixed!
    Device(id: 'ont_456', pmsRoomId: 1, status: 'offline'),  // Prefixed!
    Device(id: 'sw_789', pmsRoomId: 1, status: 'online'),    // Prefixed!
    Device(id: 'ap_999', pmsRoomId: 2, status: 'online'),
  ];
  
  testScenario('Staging Environment (Prefixed)', stagingRoom, stagingDevices);
  
  // Scenario 3: What if room deviceIds were also prefixed?
  print('\n3. STAGING (If room had prefixed IDs)');
  final stagingRoomFixed = Room(
    id: '1',
    name: 'Room 101',
    deviceIds: ['ap_123', 'ont_456', 'sw_789'],  // Prefixed to match
  );
  
  testScenario('Staging with Matching Prefixes', stagingRoomFixed, stagingDevices);
  
  print('\n' + '=' * 80);
  print('ROOT CAUSE IDENTIFIED:');
  print('=' * 80);
  print('\n1. DeviceRemoteDataSource prefixes device IDs:');
  print('   - Access points: "ap_" + id');
  print('   - ONTs: "ont_" + id');
  print('   - Switches: "sw_" + id');
  print('   - WLAN: "wlan_" + id');
  print('\n2. Room deviceIds from API don\'t have these prefixes');
  print('\n3. Current code only uses pmsRoomId matching');
  print('\n4. If pmsRoomId is null or doesn\'t match, no devices found');
  
  print('\n' + '=' * 80);
  print('SOLUTION OPTIONS:');
  print('=' * 80);
  print('\nOption A: Remove ID prefixing (BEST - Clean Architecture)');
  print('  - Keep original IDs from API');
  print('  - Avoids ID transformation in data layer');
  print('\nOption B: Add fallback to deviceIds matching');
  print('  - Try pmsRoomId first');
  print('  - Fall back to deviceIds if needed');
  print('\nOption C: Ensure pmsRoomId is always set correctly');
  print('  - Fix the extraction logic for pms_room_id');
}