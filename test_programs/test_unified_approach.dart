#!/usr/bin/env dart

// Test unified approach - iteration 1 of 3
// Mock data should match API pattern: using pmsRoomId, not deviceIds

class Device {
  const Device({
    required this.id,
    required this.status,
    this.pmsRoomId,
    this.location, // Keep for backward compatibility but don't use
  });
  
  final String id;
  final String status;
  final int? pmsRoomId;
  final String? location;
}

class Room {
  const Room({
    required this.id,
    required this.name,
    this.deviceIds, // Should be null/empty like API
  });
  
  final String id;
  final String name;
  final List<String>? deviceIds;
}

class RoomViewModel {
  const RoomViewModel({
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

// UNIFIED APPROACH - Single logic path
List<Device> _getDevicesForRoom(Room room, List<Device> allDevices) {
  // Parse room ID as integer for pmsRoomId matching
  final roomIdInt = int.tryParse(room.id);
  if (roomIdInt != null) {
    // Match devices by pmsRoomId (both mock and API pattern)
    return allDevices.where((device) => device.pmsRoomId == roomIdInt).toList();
  }
  
  // No devices found for non-numeric room ID
  return [];
}

RoomViewModel calculateRoomViewModel(Room room, List<Device> allDevices) {
  // Get devices using unified logic
  final roomDevices = _getDevicesForRoom(room, allDevices);
  
  // Calculate stats
  final deviceCount = roomDevices.length;
  final onlineDevices = roomDevices
      .where((device) => device.status.toLowerCase() == 'online')
      .length;
  
  return RoomViewModel(
    room: room,
    deviceCount: deviceCount,
    onlineDevices: onlineDevices,
  );
}

void runTest(String testName, List<Room> rooms, List<Device> devices) {
  print('\n$testName');
  print('-' * 40);
  
  for (final room in rooms) {
    final viewModel = calculateRoomViewModel(room, devices);
    print('${room.name} (id=${room.id}):');
    print('  Devices: ${viewModel.deviceCount}');
    print('  Online: ${viewModel.onlineDevices}');
    print('  Percentage: ${viewModel.onlinePercentage.toStringAsFixed(1)}%');
  }
}

void main() {
  print('=' * 60);
  print('UNIFIED APPROACH TEST - ITERATION 1');
  print('=' * 60);
  
  // Create devices with pmsRoomId (matching API pattern)
  final devices = [
    // Room 1 devices
    const Device(id: 'ap-001', status: 'online', pmsRoomId: 1),
    const Device(id: 'ap-002', status: 'offline', pmsRoomId: 1),
    const Device(id: 'sw-001', status: 'online', pmsRoomId: 1),
    const Device(id: 'ont-001', status: 'online', pmsRoomId: 1),
    // Room 2 devices
    const Device(id: 'ap-003', status: 'online', pmsRoomId: 2),
    const Device(id: 'sw-002', status: 'online', pmsRoomId: 2),
    const Device(id: 'ont-002', status: 'offline', pmsRoomId: 2),
    // Room 3 devices
    const Device(id: 'ap-004', status: 'offline', pmsRoomId: 3),
    const Device(id: 'sw-003', status: 'offline', pmsRoomId: 3),
    // Unassigned device
    const Device(id: 'ap-999', status: 'online', pmsRoomId: null),
  ];
  
  // Test 1: Mock data (should NOT have deviceIds, like API)
  final mockRooms = [
    const Room(id: '1', name: 'Conference Room'),  // No deviceIds
    const Room(id: '2', name: 'Lobby'),            // No deviceIds
    const Room(id: '3', name: 'Office'),           // No deviceIds
  ];
  
  runTest('Mock Data (Unified Pattern)', mockRooms, devices);
  
  // Test 2: API data (same pattern as mock)
  final apiRooms = [
    const Room(id: '1', name: 'Room 101', deviceIds: null),
    const Room(id: '2', name: 'Room 102', deviceIds: []),
    const Room(id: '3', name: 'Room 103'),
  ];
  
  runTest('API Data (Same Pattern)', apiRooms, devices);
  
  // Test 3: Edge cases
  final edgeRooms = [
    const Room(id: '999', name: 'Empty Room'),
    const Room(id: 'abc', name: 'Non-numeric ID'),
    const Room(id: '1', name: 'Has Old deviceIds', deviceIds: ['ignored']),
  ];
  
  runTest('Edge Cases', edgeRooms, devices);
  
  print('\n' + '=' * 60);
  print('BENEFITS OF UNIFIED APPROACH');
  print('=' * 60);
  
  print('\n✅ Consistency:');
  print('  • Mock data matches API data structure');
  print('  • Single logic path for all environments');
  print('  • No conditional branches needed');
  
  print('\n✅ Simplicity:');
  print('  • One function handles everything');
  print('  • No dual-path maintenance');
  print('  • Easier to test and debug');
  
  print('\n✅ Clean Architecture:');
  print('  • Clear data contract');
  print('  • No environment-specific logic');
  print('  • Better separation of concerns');
  
  print('\n✅ MVVM Compliance:');
  print('  • ViewModel has single responsibility');
  print('  • Pure functions throughout');
  print('  • Testable in isolation');
  
  print('\n' + '=' * 60);
  print('MIGRATION PLAN');
  print('=' * 60);
  
  print('\n1. Update mock data generation:');
  print('   • Set pmsRoomId instead of location');
  print('   • Remove deviceIds from mock rooms');
  
  print('\n2. Simplify room_view_models.dart:');
  print('   • Remove deviceIds checking logic');
  print('   • Use only pmsRoomId matching');
  
  print('\n3. Benefits:');
  print('   • Consistent behavior across environments');
  print('   • Simpler, more maintainable code');
  print('   • Better alignment with API data model');
}