#!/usr/bin/env dart

// Test to demonstrate how to calculate room percentages using device.pmsRoomId

void main() {
  print('=' * 60);
  print('ROOM-DEVICE LINKAGE ANALYSIS');
  print('=' * 60);
  
  print('\n1. DATA STRUCTURES');
  print('-' * 40);
  print('Device entity has:');
  print('  • id: String (device identifier)');
  print('  • pmsRoomId: int? (links to room via room.id)');
  print('  • location: String? (alternative room link)');
  print('  • status: String (online/offline)');
  print('');
  print('Room entity has:');
  print('  • id: String (room identifier)');
  print('  • deviceIds: List<String>? (list of device IDs)');
  print('');
  
  print('\n2. CURRENT APPROACH (room_view_models.dart)');
  print('-' * 40);
  print('Lines 58-73 do:');
  print('  1. Get deviceIds from room.deviceIds');
  print('  2. For each deviceId in the list');
  print('  3. Find device where device.id == deviceId');
  print('  4. Count if device.status == "online"');
  print('');
  print('Problem in staging:');
  print('  • room.deviceIds is EMPTY or NULL');
  print('  • So deviceCount = 0, loop never runs');
  print('  • Result: 0% online');
  
  print('\n3. HOW MOCK DATA WORKS');
  print('-' * 40);
  print('MockDataService.getMockDevicesForRoom(roomId):');
  print('  • Filters devices where device.location == roomId');
  print('  • Returns matching devices');
  print('  • Mock rooms have deviceIds populated');
  print('');
  
  print('\n4. HOW STAGING DATA WORKS');
  print('-' * 40);
  print('Staging API provides:');
  print('  • Devices with pmsRoomId field (from pms_room.id)');
  print('  • Rooms WITHOUT deviceIds populated');
  print('  • Need to link via pmsRoomId instead');
  
  print('\n5. PROPOSED SOLUTION');
  print('-' * 40);
  print('In room_view_models.dart, we should:');
  print('');
  print('OPTION A - Fallback approach:');
  print('  if (room.deviceIds != null && room.deviceIds!.isNotEmpty) {');
  print('    // Use existing approach with deviceIds');
  print('  } else {');
  print('    // Fallback: filter devices by pmsRoomId');
  print('    final roomDevices = allDevices.where((d) =>');
  print('      d.pmsRoomId?.toString() == room.id');
  print('    ).toList();');
  print('  }');
  print('');
  print('OPTION B - Always use pmsRoomId:');
  print('  // Filter devices that belong to this room');
  print('  final roomDevices = allDevices.where((device) =>');
  print('    device.pmsRoomId?.toString() == room.id');
  print('  ).toList();');
  print('  final deviceCount = roomDevices.length;');
  print('  final onlineDevices = roomDevices.where((d) =>');
  print('    d.status.toLowerCase() == "online"');
  print('  ).length;');
  
  print('\n6. TESTING THE APPROACH');
  print('-' * 40);
  
  // Simulate the calculation
  // Mock room data
  final rooms = [
    {'id': '1', 'name': 'Room 101', 'deviceIds': <String>[]}, // Empty deviceIds
    {'id': '2', 'name': 'Room 102', 'deviceIds': <String>[]},
    {'id': '3', 'name': 'Room 103', 'deviceIds': <String>[]},
  ];
  
  // Mock device data with pmsRoomId
  final devices = [
    {'id': 'd1', 'pmsRoomId': 1, 'status': 'online'},
    {'id': 'd2', 'pmsRoomId': 1, 'status': 'offline'},
    {'id': 'd3', 'pmsRoomId': 1, 'status': 'online'},
    {'id': 'd4', 'pmsRoomId': 2, 'status': 'online'},
    {'id': 'd5', 'pmsRoomId': 2, 'status': 'online'},
    {'id': 'd6', 'pmsRoomId': 3, 'status': 'offline'},
    {'id': 'd7', 'pmsRoomId': 3, 'status': 'offline'},
    {'id': 'd8', 'pmsRoomId': null, 'status': 'online'}, // No room assignment
  ];
  
  print('Test Data:');
  print('  3 rooms (all with empty deviceIds)');
  print('  8 devices (7 assigned to rooms, 1 unassigned)');
  print('');
  
  // Calculate using pmsRoomId approach
  for (final room in rooms) {
    final roomId = room['id'] as String;
    final roomName = room['name'] as String;
    
    // Filter devices by pmsRoomId
    final roomDevices = devices.where((device) {
      final pmsRoomId = device['pmsRoomId'] as int?;
      return pmsRoomId?.toString() == roomId;
    }).toList();
    
    final deviceCount = roomDevices.length;
    final onlineCount = roomDevices.where((d) {
      return (d['status'] as String).toLowerCase() == 'online';
    }).length;
    
    final percentage = deviceCount > 0 
      ? (onlineCount / deviceCount * 100).toStringAsFixed(1)
      : '0.0';
    
    print('$roomName:');
    print('  Devices: $deviceCount');
    print('  Online: $onlineCount');
    print('  Percentage: $percentage%');
  }
  
  print('\n7. ARCHITECTURE COMPLIANCE');
  print('-' * 40);
  print('✅ MVVM:');
  print('  • Calculation in ViewModel (presentation layer)');
  print('  • Aggregates data from multiple sources');
  print('  • No business logic in View');
  print('');
  print('✅ Clean Architecture:');
  print('  • Domain entities unchanged');
  print('  • Data layer unchanged');
  print('  • Only presentation layer logic');
  print('');
  print('✅ Dependency Injection:');
  print('  • Uses existing providers');
  print('  • Watches both rooms and devices');
  print('  • No hardcoded dependencies');
  print('');
  print('✅ Riverpod:');
  print('  • Reactive to both data sources');
  print('  • Proper AsyncValue handling');
  print('  • Automatic updates on data change');
  
  print('\n8. IMPLEMENTATION APPROACH');
  print('-' * 40);
  print('The fix should be in room_view_models.dart:');
  print('');
  print('Instead of only using room.deviceIds to find devices,');
  print('also filter by device.pmsRoomId when deviceIds is empty.');
  print('');
  print('This way:');
  print('  • Development: Uses deviceIds (populated by mock)');
  print('  • Staging: Uses pmsRoomId (from API data)');
  print('  • Both work correctly!');
  
  print('\n' + '=' * 60);
  print('CONCLUSION');
  print('=' * 60);
  print('\nThe staging data HAS the necessary information!');
  print('Devices have pmsRoomId that links them to rooms.');
  print('We just need to use this field when room.deviceIds is empty.');
  print('');
  print('This is architecturally sound and follows all patterns.');
}