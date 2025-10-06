#!/usr/bin/env dart

// Test the actual data flow to understand display differences

class Room {
  final String id;
  final String name;
  final Map<String, dynamic>? metadata;
  
  Room({required this.id, required this.name, this.metadata});
}

class Device {
  final String id;
  final String name;
  final String status;
  final int? pmsRoomId;
  
  Device({required this.id, required this.name, required this.status, this.pmsRoomId});
}

class RoomViewModel {
  final Room room;
  final int deviceCount;
  final int onlineDevices;
  
  RoomViewModel({
    required this.room,
    required this.deviceCount,
    required this.onlineDevices,
  });
  
  double get onlinePercentage =>
      deviceCount > 0 ? (onlineDevices / deviceCount) * 100 : 0;
  
  bool get hasIssues => onlineDevices < deviceCount;
}

// Simulating the actual _getDevicesForRoom function
List<Device> _getDevicesForRoom(Room room, List<Device> allDevices) {
  final roomIdInt = int.tryParse(room.id);
  if (roomIdInt != null) {
    return allDevices.where((device) => device.pmsRoomId == roomIdInt).toList();
  }
  return [];
}

void testScenario(String name, List<Room> rooms, List<Device> devices) {
  print('\n$name');
  print('=' * 60);
  
  print('\nRooms data:');
  for (final room in rooms) {
    print('  Room: id="${room.id}", name="${room.name}"');
    if (room.metadata != null) {
      print('    metadata: ${room.metadata}');
    }
  }
  
  print('\nDevices data:');
  for (final device in devices) {
    print('  Device: id="${device.id}", pmsRoomId=${device.pmsRoomId}, status="${device.status}"');
  }
  
  print('\nCalculated ViewModels:');
  for (final room in rooms) {
    final roomDevices = _getDevicesForRoom(room, devices);
    final deviceCount = roomDevices.length;
    final onlineDevices = roomDevices
        .where((device) => device.status.toLowerCase() == 'online')
        .length;
    
    final vm = RoomViewModel(
      room: room,
      deviceCount: deviceCount,
      onlineDevices: onlineDevices,
    );
    
    print('  ${room.name}: ${vm.onlineDevices}/${vm.deviceCount} = ${vm.onlinePercentage.toStringAsFixed(1)}%');
    print('    Devices found: ${roomDevices.map((d) => d.id).toList()}');
  }
}

void main() {
  print('ACTUAL DATA FLOW ANALYSIS');
  print('=' * 80);
  
  // Scenario 1: What development might have
  print('\n1. DEVELOPMENT ENVIRONMENT (Mock Data)');
  final devRooms = [
    Room(id: '1', name: 'Conference Room'),
    Room(id: '2', name: 'Lobby'),
    Room(id: '3', name: 'Office'),
  ];
  
  final devDevices = [
    Device(id: 'ap-001', name: 'AP-1', status: 'online', pmsRoomId: 1),
    Device(id: 'ap-002', name: 'AP-2', status: 'offline', pmsRoomId: 1),
    Device(id: 'ap-003', name: 'AP-3', status: 'online', pmsRoomId: 2),
    Device(id: 'ap-004', name: 'AP-4', status: 'online', pmsRoomId: 3),
  ];
  
  testScenario('Development Mock Data', devRooms, devDevices);
  
  // Scenario 2: What staging might have from API
  print('\n2. STAGING ENVIRONMENT (API Data)');
  final stagingRooms = [
    Room(id: '1', name: 'Room 101', metadata: {'device_count': 3, 'online_devices': 2}),
    Room(id: '2', name: 'Room 102', metadata: {'device_count': 2, 'online_devices': 1}),
    Room(id: '3', name: 'Room 103', metadata: {'device_count': 1, 'online_devices': 0}),
  ];
  
  // Staging might not get devices, or devices might be structured differently
  final stagingDevices = <Device>[];  // Empty if devices endpoint fails or returns differently
  
  testScenario('Staging API Data (No Devices)', stagingRooms, stagingDevices);
  
  // Scenario 3: What if staging gets devices but with different structure
  print('\n3. STAGING WITH DEVICES BUT DIFFERENT IDS');
  final stagingDevicesAlt = [
    Device(id: 'dev-101', name: 'Device 101', status: 'online', pmsRoomId: 101),  // Wrong ID
    Device(id: 'dev-102', name: 'Device 102', status: 'online', pmsRoomId: 102),  // Wrong ID
  ];
  
  testScenario('Staging API Data (Wrong Device IDs)', stagingRooms, stagingDevicesAlt);
  
  print('\n' + '=' * 80);
  print('KEY OBSERVATIONS:');
  print('=' * 80);
  print('\n1. If staging devices endpoint returns empty or fails:');
  print('   - All rooms show 0/0 = 0%');
  print('\n2. If staging room IDs don\'t match device pmsRoomId:');
  print('   - Rooms can\'t find their devices');
  print('   - All rooms show 0/0 = 0%');
  print('\n3. The metadata device_count and online_devices are IGNORED');
  print('   - We removed them from RoomModel');
  print('   - Only the actual device matching matters');
  
  print('\n' + '=' * 80);
  print('LIKELY ISSUE:');
  print('=' * 80);
  print('The devices in staging either:');
  print('1. Are not being fetched properly');
  print('2. Have different pmsRoomId values than room IDs');
  print('3. Have a different data structure');
}