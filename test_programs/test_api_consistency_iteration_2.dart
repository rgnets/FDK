#!/usr/bin/env dart

// Test Iteration 2: Why rooms show 0% in staging

class Room {
  final String id;
  final String name;
  Room({required this.id, required this.name});
}

class Device {
  final String id;
  final int? pmsRoomId;
  final String status;
  Device({required this.id, this.pmsRoomId, required this.status});
}

// Current matching logic from room_view_models.dart
List<Device> getDevicesForRoom(Room room, List<Device> allDevices) {
  final roomIdInt = int.tryParse(room.id);
  if (roomIdInt != null) {
    return allDevices.where((device) => device.pmsRoomId == roomIdInt).toList();
  }
  return [];
}

void testScenario(String name, List<Room> rooms, List<Device> devices) {
  print('\n$name');
  print('=' * 60);
  
  print('Rooms:');
  for (final room in rooms) {
    print('  id="${room.id}" (parsed as int: ${int.tryParse(room.id)})');
  }
  
  print('\nDevices:');
  for (final device in devices) {
    print('  id="${device.id}", pmsRoomId=${device.pmsRoomId}, status=${device.status}');
  }
  
  print('\nMatching results:');
  for (final room in rooms) {
    final roomDevices = getDevicesForRoom(room, devices);
    final online = roomDevices.where((d) => d.status == 'online').length;
    final percentage = roomDevices.isEmpty ? 0.0 : (online / roomDevices.length) * 100;
    print('  Room ${room.id}: ${online}/${roomDevices.length} = ${percentage.toStringAsFixed(0)}%');
  }
}

void main() {
  print('WHY STAGING SHOWS 0% - ITERATION 2');
  print('=' * 80);
  
  // Scenario 1: Everything works (development)
  testScenario('Scenario 1: Development (Working)', [
    Room(id: '1', name: 'Conference'),
    Room(id: '2', name: 'Lobby'),
  ], [
    Device(id: 'ap-001', pmsRoomId: 1, status: 'online'),
    Device(id: 'ap-002', pmsRoomId: 1, status: 'offline'),
    Device(id: 'ap-003', pmsRoomId: 2, status: 'online'),
  ]);
  
  // Scenario 2: Devices have null pmsRoomId (API returns no pms_room)
  testScenario('Scenario 2: Staging - No pms_room in API', [
    Room(id: '1', name: 'Room 101'),
    Room(id: '2', name: 'Room 102'),
  ], [
    Device(id: '123', pmsRoomId: null, status: 'online'),
    Device(id: '456', pmsRoomId: null, status: 'online'),
    Device(id: '789', pmsRoomId: null, status: 'online'),
  ]);
  
  // Scenario 3: Room IDs don't match device pmsRoomIds
  testScenario('Scenario 3: ID Mismatch', [
    Room(id: '101', name: 'Room 101'),  // ID is "101"
    Room(id: '102', name: 'Room 102'),  // ID is "102"
  ], [
    Device(id: '123', pmsRoomId: 1, status: 'online'),  // pmsRoomId is 1, not 101!
    Device(id: '456', pmsRoomId: 2, status: 'online'),  // pmsRoomId is 2, not 102!
  ]);
  
  // Scenario 4: Mixed - some devices have pmsRoomId, some don't
  testScenario('Scenario 4: Mixed (Partial Data)', [
    Room(id: '1', name: 'Room 1'),
    Room(id: '2', name: 'Room 2'),
  ], [
    Device(id: '123', pmsRoomId: 1, status: 'online'),
    Device(id: '456', pmsRoomId: null, status: 'online'),  // No room!
    Device(id: '789', pmsRoomId: 2, status: 'offline'),
  ]);
  
  print('\n' + '=' * 80);
  print('ROOT CAUSES FOR 0% DISPLAY:');
  print('=' * 80);
  
  print('\n1. Missing pms_room in API response:');
  print('   If API returns devices without pms_room field,');
  print('   pmsRoomId will be null, no matching occurs');
  
  print('\n2. Room ID format mismatch:');
  print('   If rooms have IDs like "101", "102" but devices');
  print('   have pms_room.id as 1, 2, they won\'t match');
  
  print('\n3. WLAN devices have no pmsRoomId:');
  print('   Line 316-329 in device_remote_data_source');
  print('   doesn\'t extract pms_room at all');
  
  print('\n' + '=' * 80);
  print('KEY INSIGHT:');
  print('=' * 80);
  print('\nThe matching relies ENTIRELY on pmsRoomId.');
  print('If pmsRoomId is null or doesn\'t match room.id,');
  print('the room will show 0/0 = 0%');
  
  print('\nThis is likely what\'s happening in staging:');
  print('- Either devices don\'t have pms_room in API');
  print('- Or room IDs don\'t match pms_room.id values');
}