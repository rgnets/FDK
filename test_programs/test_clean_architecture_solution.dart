#!/usr/bin/env dart

// Test Clean Architecture solution - iteration 1 of 3
// Remove calculated fields from data layer

// CLEAN DOMAIN ENTITY - No calculated fields
class Room {
  const Room({
    required this.id,
    required this.name,
    this.roomNumber,
    this.building,
    this.floor,
    this.deviceIds, // Optional, for backward compatibility
    this.metadata,
  });
  
  final String id;
  final String name;
  final String? roomNumber;
  final String? building;
  final int? floor;
  final List<String>? deviceIds;
  final Map<String, dynamic>? metadata;
}

// CLEAN DATA MODEL - No calculated fields
class RoomModel {
  const RoomModel({
    required this.id,
    required this.name,
    this.roomNumber,
    this.building,
    this.floor,
    this.deviceIds,
    this.metadata,
    // REMOVED: deviceCount
    // REMOVED: onlineDevices
  });
  
  final String id;
  final String name;
  final String? roomNumber;
  final String? building;
  final String? floor;
  final List<String>? deviceIds;
  final Map<String, dynamic>? metadata;
  
  Room toEntity() {
    return Room(
      id: id,
      name: name,
      roomNumber: roomNumber,
      building: building,
      floor: floor != null ? int.tryParse(floor!) : null,
      deviceIds: deviceIds,
      metadata: metadata,
    );
  }
}

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.pmsRoomId,
  });
  
  final String id;
  final String name;
  final String type;
  final String status;
  final int? pmsRoomId;
}

// PRESENTATION LAYER - All calculations here
class RoomViewModel {
  const RoomViewModel({
    required this.room,
    required this.deviceCount,
    required this.onlineDevices,
  });
  
  final Room room;
  final int deviceCount;
  final int onlineDevices;
  
  String get id => room.id;
  String get name => room.name;
  
  double get onlinePercentage =>
      deviceCount > 0 ? (onlineDevices / deviceCount) * 100 : 0;
      
  bool get hasIssues => onlineDevices < deviceCount;
}

// Single source of truth for calculations
List<RoomViewModel> roomViewModels(
  List<Room> rooms,
  List<Device> allDevices,
) {
  return rooms.map((room) {
    // ALL calculation happens here
    final roomDevices = _getDevicesForRoom(room, allDevices);
    
    final deviceCount = roomDevices.length;
    final onlineDevices = roomDevices
        .where((device) => device.status.toLowerCase() == 'online')
        .length;
    
    return RoomViewModel(
      room: room,
      deviceCount: deviceCount,
      onlineDevices: onlineDevices,
    );
  }).toList();
}

List<Device> _getDevicesForRoom(Room room, List<Device> allDevices) {
  final roomIdInt = int.tryParse(room.id);
  if (roomIdInt != null) {
    return allDevices.where((device) => device.pmsRoomId == roomIdInt).toList();
  }
  return [];
}

// Mock Data Source - Clean, no calculations
class RoomMockDataSource {
  List<RoomModel> getRooms(List<Room> mockRooms) {
    // Simply convert to models, NO CALCULATIONS
    return mockRooms.map((room) {
      return RoomModel(
        id: room.id,
        name: room.name,
        roomNumber: room.roomNumber,
        building: room.building,
        floor: room.floor?.toString(),
        deviceIds: room.deviceIds,
        metadata: room.metadata,
      );
    }).toList();
  }
}

// Remote Data Source - Clean, no calculations
class RoomRemoteDataSource {
  List<RoomModel> parseApiResponse(List<Map<String, dynamic>> apiData) {
    return apiData.map((json) {
      return RoomModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        roomNumber: json['room_number']?.toString(),
        building: json['building']?.toString(),
        floor: json['floor']?.toString(),
        deviceIds: _extractDeviceIds(json),
        metadata: json,
      );
    }).toList();
  }
  
  List<String>? _extractDeviceIds(Map<String, dynamic> json) {
    // Extract if provided, otherwise null
    if (json['device_ids'] is List) {
      return List<String>.from(json['device_ids'] as List);
    }
    return null;
  }
}

void testScenario(String name, List<Room> rooms, List<Device> devices) {
  print('\n$name');
  print('-' * 40);
  
  final viewModels = roomViewModels(rooms, devices);
  
  for (final vm in viewModels) {
    print('${vm.name}:');
    print('  Devices: ${vm.deviceCount}');
    print('  Online: ${vm.onlineDevices}');
    print('  Percentage: ${vm.onlinePercentage.toStringAsFixed(1)}%');
    print('  Has Issues: ${vm.hasIssues}');
  }
}

void main() {
  print('=' * 60);
  print('CLEAN ARCHITECTURE SOLUTION - ITERATION 1');
  print('=' * 60);
  
  // Test data
  final devices = [
    const Device(id: 'ap-001', name: 'AP-1A', type: 'ap', status: 'online', pmsRoomId: 1),
    const Device(id: 'ap-002', name: 'AP-1B', type: 'ap', status: 'offline', pmsRoomId: 1),
    const Device(id: 'sw-001', name: 'SW-1', type: 'switch', status: 'online', pmsRoomId: 1),
    const Device(id: 'ont-001', name: 'ONT-1', type: 'ont', status: 'online', pmsRoomId: 1),
    const Device(id: 'ap-003', name: 'AP-2', type: 'ap', status: 'online', pmsRoomId: 2),
    const Device(id: 'ont-002', name: 'ONT-2', type: 'ont', status: 'online', pmsRoomId: 2),
    const Device(id: 'ap-004', name: 'AP-3', type: 'ap', status: 'offline', pmsRoomId: 3),
  ];
  
  final rooms = [
    const Room(id: '1', name: 'Conference Room', building: 'Main', floor: 1),
    const Room(id: '2', name: 'Lobby', building: 'Main', floor: 1),
    const Room(id: '3', name: 'Office', building: 'Main', floor: 2),
  ];
  
  testScenario('Clean Architecture Approach', rooms, devices);
  
  print('\n' + '=' * 60);
  print('BENEFITS');
  print('=' * 60);
  
  print('\n✅ Single Source of Truth:');
  print('  • ALL calculations in presentation layer');
  print('  • No duplicated logic');
  print('  • Consistent behavior across environments');
  
  print('\n✅ Clean Architecture:');
  print('  • Data layer provides raw data only');
  print('  • Domain entities are pure data structures');
  print('  • Presentation layer handles display logic');
  
  print('\n✅ MVVM Pattern:');
  print('  • ViewModels calculate display values');
  print('  • Clear separation of concerns');
  print('  • Testable and maintainable');
  
  print('\n✅ No Environment Differences:');
  print('  • Mock data uses same structure as API');
  print('  • Same calculation path for all environments');
  print('  • Predictable, consistent behavior');
  
  print('\n' + '=' * 60);
  print('IMPLEMENTATION STEPS');
  print('=' * 60);
  
  print('\n1. Update RoomModel:');
  print('   • Remove deviceCount field');
  print('   • Remove onlineDevices field');
  
  print('\n2. Update RoomMockDataSource:');
  print('   • Remove device counting logic');
  print('   • Remove online device calculation');
  
  print('\n3. Update RoomRemoteDataSource:');
  print('   • Stop reading device_count from API');
  print('   • Stop reading online_devices from API');
  
  print('\n4. Update MockDataService:');
  print('   • Fix getMockDevicesForRoom to use pmsRoomId');
  print('   • Or remove it entirely (not needed)');
  
  print('\n5. Result:');
  print('   • room_view_models.dart is the ONLY place');
  print('   • that calculates device statistics');
}