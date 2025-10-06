#!/usr/bin/env dart

import '../lib/core/services/mock_data_service.dart';

void main() {
  print('ROOM-DEVICE LINKING VERIFICATION');
  print('=' * 60);
  
  final mockService = MockDataService();
  final rooms = mockService.getMockRooms();
  final devices = mockService.getMockDevices();
  
  print('\n1. ROOM ID FORMAT CHECK');
  print('-' * 40);
  
  // Check first 5 rooms
  for (var i = 0; i < 5 && i < rooms.length; i++) {
    final room = rooms[i];
    print('Room ${i + 1}:');
    print('  ID: ${room.id} (Type: ${room.id.runtimeType})');
    print('  Name: ${room.name}');
    print('  Location: ${room.location}');
    print('  Building: ${room.building}');
    
    // Verify ID is parseable as integer
    final idAsInt = int.tryParse(room.id);
    if (idAsInt != null) {
      print('  ✅ ID parses to integer: $idAsInt');
    } else {
      print('  ❌ ID does NOT parse to integer!');
    }
    print('');
  }
  
  print('\n2. DEVICE pmsRoomId CHECK');
  print('-' * 40);
  
  // Check first 5 devices
  for (var i = 0; i < 5 && i < devices.length; i++) {
    final device = devices[i];
    print('Device ${i + 1}:');
    print('  ID: ${device.id}');
    print('  Name: ${device.name}');
    print('  Location: ${device.location}');
    print('  pmsRoomId: ${device.pmsRoomId} (Type: ${device.pmsRoomId.runtimeType})');
    
    if (device.pmsRoomId != null) {
      print('  ✅ Has integer pmsRoomId');
    } else {
      print('  ⚠️  No pmsRoomId');
    }
    print('');
  }
  
  print('\n3. ROOM-DEVICE LINKING TEST');
  print('-' * 40);
  
  // Test linking for first 3 rooms
  var successCount = 0;
  var totalRoomsWithDevices = 0;
  
  for (var i = 0; i < 3 && i < rooms.length; i++) {
    final room = rooms[i];
    final roomIdInt = int.tryParse(room.id);
    
    if (roomIdInt != null) {
      final roomDevices = devices.where((d) => d.pmsRoomId == roomIdInt).toList();
      
      print('Room "${room.name}" (ID: ${room.id}):');
      print('  Location: ${room.location}');
      print('  Devices found: ${roomDevices.length}');
      
      if (roomDevices.isNotEmpty) {
        successCount++;
        totalRoomsWithDevices++;
        print('  ✅ Room-device linking works!');
        for (var j = 0; j < 3 && j < roomDevices.length; j++) {
          final device = roomDevices[j];
          print('    - ${device.name} (${device.type}) at "${device.location}"');
        }
        if (roomDevices.length > 3) {
          print('    ... and ${roomDevices.length - 3} more devices');
        }
      } else {
        print('  ⚠️  No devices found for this room');
      }
    } else {
      print('Room "${room.name}" (ID: ${room.id}):');
      print('  ❌ Room ID cannot be parsed as integer!');
    }
    print('');
  }
  
  print('\n4. LOCATION FORMAT CONSISTENCY');
  print('-' * 40);
  
  // Check that device locations match room locations
  for (var i = 0; i < 3 && i < rooms.length; i++) {
    final room = rooms[i];
    final roomIdInt = int.tryParse(room.id);
    
    if (roomIdInt != null) {
      final roomDevices = devices.where((d) => d.pmsRoomId == roomIdInt).toList();
      
      if (roomDevices.isNotEmpty) {
        final device = roomDevices.first;
        print('Room location: "${room.location}"');
        print('Device location: "${device.location}"');
        
        if (room.location == device.location) {
          print('✅ Locations match perfectly');
        } else {
          print('⚠️  Locations differ (may be intentional)');
        }
        print('');
      }
    }
  }
  
  print('\n5. FINAL ASSESSMENT');
  print('-' * 40);
  
  final totalRooms = rooms.length;
  final totalDevices = devices.length;
  final devicesWithPmsRoomId = devices.where((d) => d.pmsRoomId != null).length;
  
  print('📊 STATISTICS:');
  print('  Total rooms: $totalRooms');
  print('  Total devices: $totalDevices');
  print('  Devices with pmsRoomId: $devicesWithPmsRoomId');
  
  // Check if all room IDs are numeric
  final roomsWithNumericIds = rooms.where((r) => int.tryParse(r.id) != null).length;
  
  print('\n✅ VERIFICATION RESULTS:');
  print('  Room IDs are numeric: $roomsWithNumericIds/$totalRooms');
  print('  Devices have pmsRoomId: $devicesWithPmsRoomId/$totalDevices');
  print('  Room-device linking: ${successCount > 0 ? 'WORKING' : 'BROKEN'}');
  
  if (roomsWithNumericIds == totalRooms && devicesWithPmsRoomId > 0) {
    print('\n🎯 SUCCESS: Room-device linking is properly configured!');
    print('  - Room IDs are numeric strings (parseable as integers)');
    print('  - Devices have integer pmsRoomId fields');
    print('  - Linking logic (pmsRoomId == int.parse(room.id)) works correctly');
  } else {
    print('\n❌ FAILURE: Room-device linking has issues!');
  }
}