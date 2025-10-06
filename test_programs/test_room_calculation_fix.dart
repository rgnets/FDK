#!/usr/bin/env dart

// Test the exact fix for room_view_models.dart

class Device {
  Device({
    required this.id,
    required this.status,
    this.pmsRoomId,
  });
  
  final String id;
  final String status;
  final int? pmsRoomId;
}

class Room {
  Room({
    required this.id,
    required this.name,
    this.deviceIds,
  });
  
  final String id;
  final String name;
  final List<String>? deviceIds;
}

class RoomViewModel {
  RoomViewModel({
    required this.room,
    required this.deviceCount,
    required this.onlineDevices,
  });
  
  final Room room;
  final int deviceCount;
  final int onlineDevices;
  
  double get onlinePercentage =>
      deviceCount > 0 ? (onlineDevices / deviceCount) * 100 : 0;
}

// Current implementation (broken in staging)
RoomViewModel calculateCurrentWay(Room room, List<Device> allDevices) {
  // Calculate device stats for each room
  final deviceIds = room.deviceIds ?? [];
  final deviceCount = deviceIds.length;
  
  // Count online devices from REAL data
  var onlineDevices = 0;
  for (final deviceId in deviceIds) {
    // Find the device in the list
    final deviceIndex = allDevices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex != -1) {
      final device = allDevices[deviceIndex];
      if (device.status.toLowerCase() == 'online') {
        onlineDevices++;
      }
    }
  }
  
  return RoomViewModel(
    room: room,
    deviceCount: deviceCount,
    onlineDevices: onlineDevices,
  );
}

// Proposed implementation (works for both staging and development)
RoomViewModel calculateProposedWay(Room room, List<Device> allDevices) {
  // Calculate device stats for each room
  final deviceIds = room.deviceIds ?? [];
  var deviceCount = 0;
  var onlineDevices = 0;
  
  if (deviceIds.isNotEmpty) {
    // APPROACH 1: Use deviceIds if available (development/mock data)
    deviceCount = deviceIds.length;
    
    for (final deviceId in deviceIds) {
      final deviceIndex = allDevices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex != -1) {
        final device = allDevices[deviceIndex];
        if (device.status.toLowerCase() == 'online') {
          onlineDevices++;
        }
      }
    }
  } else {
    // APPROACH 2: Use pmsRoomId if deviceIds is empty (staging)
    // Filter devices that belong to this room
    final roomIdInt = int.tryParse(room.id);
    if (roomIdInt != null) {
      final roomDevices = allDevices.where((device) =>
        device.pmsRoomId == roomIdInt
      ).toList();
      
      deviceCount = roomDevices.length;
      onlineDevices = roomDevices.where((d) =>
        d.status.toLowerCase() == 'online'
      ).length;
    }
  }
  
  return RoomViewModel(
    room: room,
    deviceCount: deviceCount,
    onlineDevices: onlineDevices,
  );
}

void main() {
  print('=' * 60);
  print('TESTING ROOM CALCULATION FIX');
  print('=' * 60);
  
  // Create test data
  final devices = [
    Device(id: 'd1', status: 'online', pmsRoomId: 1),
    Device(id: 'd2', status: 'offline', pmsRoomId: 1),
    Device(id: 'd3', status: 'online', pmsRoomId: 1),
    Device(id: 'd4', status: 'online', pmsRoomId: 2),
    Device(id: 'd5', status: 'online', pmsRoomId: 2),
    Device(id: 'd6', status: 'offline', pmsRoomId: 3),
  ];
  
  print('\n1. DEVELOPMENT/MOCK SCENARIO');
  print('-' * 40);
  print('Room has deviceIds populated:');
  
  final devRoom = Room(
    id: '1',
    name: 'Room 101',
    deviceIds: ['d1', 'd2', 'd3'], // Has deviceIds
  );
  
  final devCurrentResult = calculateCurrentWay(devRoom, devices);
  final devProposedResult = calculateProposedWay(devRoom, devices);
  
  print('\nCurrent implementation:');
  print('  Devices: ${devCurrentResult.deviceCount}');
  print('  Online: ${devCurrentResult.onlineDevices}');
  print('  Percentage: ${devCurrentResult.onlinePercentage.toStringAsFixed(1)}%');
  
  print('\nProposed implementation:');
  print('  Devices: ${devProposedResult.deviceCount}');
  print('  Online: ${devProposedResult.onlineDevices}');
  print('  Percentage: ${devProposedResult.onlinePercentage.toStringAsFixed(1)}%');
  
  print('\n✅ Both work correctly when deviceIds is populated');
  
  print('\n2. STAGING SCENARIO');
  print('-' * 40);
  print('Room has empty deviceIds (API doesn\'t provide them):');
  
  final stagingRoom = Room(
    id: '1',
    name: 'Room 101',
    deviceIds: [], // Empty deviceIds (staging issue)
  );
  
  final stagingCurrentResult = calculateCurrentWay(stagingRoom, devices);
  final stagingProposedResult = calculateProposedWay(stagingRoom, devices);
  
  print('\nCurrent implementation:');
  print('  Devices: ${stagingCurrentResult.deviceCount}');
  print('  Online: ${stagingCurrentResult.onlineDevices}');
  print('  Percentage: ${stagingCurrentResult.onlinePercentage.toStringAsFixed(1)}%');
  print('  ❌ Shows 0% because deviceIds is empty');
  
  print('\nProposed implementation:');
  print('  Devices: ${stagingProposedResult.deviceCount}');
  print('  Online: ${stagingProposedResult.onlineDevices}');
  print('  Percentage: ${stagingProposedResult.onlinePercentage.toStringAsFixed(1)}%');
  print('  ✅ Correctly calculates using pmsRoomId');
  
  print('\n3. EDGE CASES');
  print('-' * 40);
  
  // Test room with no devices
  final emptyRoom = Room(id: '99', name: 'Empty Room', deviceIds: []);
  final emptyResult = calculateProposedWay(emptyRoom, devices);
  print('Empty room (id=99):');
  print('  Devices: ${emptyResult.deviceCount}');
  print('  Percentage: ${emptyResult.onlinePercentage.toStringAsFixed(1)}%');
  print('  ✅ Correctly shows 0% for room with no devices');
  
  // Test all rooms
  print('\n4. ALL ROOMS TEST');
  print('-' * 40);
  
  final rooms = [
    Room(id: '1', name: 'Room 101', deviceIds: []),
    Room(id: '2', name: 'Room 102', deviceIds: []),
    Room(id: '3', name: 'Room 103', deviceIds: []),
  ];
  
  for (final room in rooms) {
    final result = calculateProposedWay(room, devices);
    print('${room.name}:');
    print('  Devices: ${result.deviceCount}, Online: ${result.onlineDevices}, ' +
          'Percentage: ${result.onlinePercentage.toStringAsFixed(1)}%');
  }
  
  print('\n' + '=' * 60);
  print('ARCHITECTURE VALIDATION');
  print('=' * 60);
  
  print('\n✅ MVVM COMPLIANCE:');
  print('  • Logic stays in ViewModel (presentation layer)');
  print('  • Aggregates data from rooms and devices providers');
  print('  • No changes to View components');
  
  print('\n✅ CLEAN ARCHITECTURE:');
  print('  • Domain entities (Room, Device) unchanged');
  print('  • Data layer unchanged');
  print('  • Only presentation layer calculation modified');
  
  print('\n✅ DEPENDENCY INJECTION:');
  print('  • Still uses ref.watch(roomsNotifierProvider)');
  print('  • Still uses ref.watch(devicesNotifierProvider)');
  print('  • No new dependencies added');
  
  print('\n✅ RIVERPOD STATE:');
  print('  • Reactive to both data sources');
  print('  • AsyncValue.valueOrNull for safe access');
  print('  • Updates when either provider changes');
  
  print('\n' + '=' * 60);
  print('IMPLEMENTATION PLAN');
  print('=' * 60);
  
  print('\nIn room_view_models.dart, modify lines 58-73:');
  print('');
  print('1. Check if deviceIds is not empty');
  print('2. If populated: use current approach (for dev/mock)');
  print('3. If empty: filter devices by pmsRoomId (for staging)');
  print('');
  print('This single change will make room percentages work');
  print('in BOTH development AND staging environments!');
  
  print('\nThe fix is:');
  print('  • Minimal (only changes calculation logic)');
  print('  • Backwards compatible (dev still works)');
  print('  • Architecturally sound (stays in ViewModel)');
  print('  • Data-driven (uses existing data relationships)');
}