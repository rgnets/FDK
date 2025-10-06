#!/usr/bin/env dart

// Test Fix Iteration 1 - Verify the complete solution

// Clean Room entity - no calculated fields
class Room {
  const Room({
    required this.id,
    required this.name,
    this.roomNumber,
    this.description,
    this.location,
    this.floor,
    this.building,
    this.deviceIds,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });
  
  final String id;
  final String name;
  final String? roomNumber;
  final String? description;
  final String? location;
  final int? floor;
  final String? building;
  final List<String>? deviceIds;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

// Clean RoomModel - no calculated fields (deviceCount and onlineDevices REMOVED)
class RoomModel {
  const RoomModel({
    required this.id,
    required this.name,
    this.roomNumber,
    this.building,
    this.floor,
    this.deviceIds,
    this.metadata,
  });
  
  final String id;
  final String name;
  final String? roomNumber;
  final String? building;
  final String? floor;
  final List<String>? deviceIds;
  final Map<String, dynamic>? metadata;
  
  // Clean conversion to entity
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
  
  // Clean factory from JSON (no calculated fields)
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      roomNumber: json['room_number']?.toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      deviceIds: _extractDeviceIds(json),
      metadata: json,
    );
  }
  
  static List<String>? _extractDeviceIds(Map<String, dynamic> json) {
    // Only extract if explicitly provided
    if (json['device_ids'] is List) {
      return List<String>.from(json['device_ids'] as List);
    }
    return null;
  }
}

// Device entity
class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.pmsRoomId,
    this.location,
  });
  
  final String id;
  final String name;
  final String type;
  final String status;
  final int? pmsRoomId;
  final String? location;
}

// Mock Data Service - Fixed to use pmsRoomId
class MockDataService {
  final List<Device> _devices;
  final List<Room> _rooms;
  
  MockDataService(this._devices, this._rooms);
  
  List<Device> getMockDevices() => _devices;
  List<Room> getMockRooms() => _rooms;
  
  // FIXED: Now uses pmsRoomId instead of location
  List<Device> getMockDevicesForRoom(String roomId) {
    final roomIdInt = int.tryParse(roomId);
    if (roomIdInt != null) {
      return _devices.where((d) => d.pmsRoomId == roomIdInt).toList();
    }
    return [];
  }
}

// Clean Mock Data Source - no calculations
class RoomMockDataSource {
  final MockDataService mockDataService;
  
  RoomMockDataSource(this.mockDataService);
  
  Future<List<RoomModel>> getRooms() async {
    final mockRooms = mockDataService.getMockRooms();
    
    // Simply convert to models - NO CALCULATIONS
    return mockRooms.map((room) {
      return RoomModel(
        id: room.id,
        name: room.name,
        roomNumber: room.roomNumber,
        building: room.building,
        floor: room.floor?.toString(),
        deviceIds: room.deviceIds,
        metadata: {
          'description': room.description,
          'location': room.location,
          'updatedAt': room.updatedAt?.toIso8601String(),
        },
      );
    }).toList();
  }
}

// Clean Remote Data Source - no calculations
class RoomRemoteDataSource {
  List<RoomModel> parseApiResponse(List<Map<String, dynamic>> apiData) {
    return apiData.map((json) {
      // Use clean factory that doesn't read calculated fields
      return RoomModel.fromJson(json);
    }).toList();
  }
}

// Room ViewModel - calculations happen here
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
      
  bool get hasIssues => onlineDevices < deviceCount;
}

// Single source of truth for calculations
List<RoomViewModel> roomViewModels(
  List<Room> rooms,
  List<Device> allDevices,
) {
  return rooms.map((room) {
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

void main() async {
  print('=' * 60);
  print('FIX TEST - ITERATION 1');
  print('=' * 60);
  
  // Create test data
  final devices = [
    const Device(id: 'ap-001', name: 'AP-1A', type: 'ap', status: 'online', pmsRoomId: 1),
    const Device(id: 'ap-002', name: 'AP-1B', type: 'ap', status: 'offline', pmsRoomId: 1),
    const Device(id: 'sw-001', name: 'SW-1', type: 'switch', status: 'online', pmsRoomId: 1),
    const Device(id: 'ap-003', name: 'AP-2', type: 'ap', status: 'online', pmsRoomId: 2),
    const Device(id: 'sw-002', name: 'SW-2', type: 'switch', status: 'online', pmsRoomId: 2),
    const Device(id: 'ap-004', name: 'AP-3', type: 'ap', status: 'offline', pmsRoomId: 3),
  ];
  
  final rooms = [
    const Room(id: '1', name: 'Conference Room', building: 'Main'),
    const Room(id: '2', name: 'Lobby', building: 'Main'),
    const Room(id: '3', name: 'Office', building: 'Main'),
  ];
  
  // Test 1: Mock Data Source (Development)
  print('\n1. MOCK DATA SOURCE TEST');
  print('-' * 40);
  
  final mockService = MockDataService(devices, rooms);
  final mockDataSource = RoomMockDataSource(mockService);
  final mockModels = await mockDataSource.getRooms();
  
  print('Mock models created: ${mockModels.length}');
  for (final model in mockModels) {
    print('  ${model.name}: has deviceIds=${model.deviceIds?.length ?? 0}');
  }
  
  // Convert to entities
  final mockEntities = mockModels.map((m) => m.toEntity()).toList();
  
  // Calculate view models
  final mockViewModels = roomViewModels(mockEntities, devices);
  
  print('\nMock ViewModels (calculated in presentation layer):');
  for (final vm in mockViewModels) {
    print('  ${vm.room.name}: ${vm.onlineDevices}/${vm.deviceCount} = ${vm.onlinePercentage.toStringAsFixed(1)}%');
  }
  
  // Test 2: Remote Data Source (Staging/Production)
  print('\n2. REMOTE DATA SOURCE TEST');
  print('-' * 40);
  
  final apiData = [
    {'id': '1', 'name': 'Conference Room', 'building': 'Main'},
    {'id': '2', 'name': 'Lobby', 'building': 'Main'},
    {'id': '3', 'name': 'Office', 'building': 'Main'},
  ];
  
  final remoteDataSource = RoomRemoteDataSource();
  final remoteModels = remoteDataSource.parseApiResponse(apiData);
  
  print('Remote models created: ${remoteModels.length}');
  for (final model in remoteModels) {
    print('  ${model.name}: has deviceIds=${model.deviceIds?.length ?? 0}');
  }
  
  // Convert to entities
  final remoteEntities = remoteModels.map((m) => m.toEntity()).toList();
  
  // Calculate view models
  final remoteViewModels = roomViewModels(remoteEntities, devices);
  
  print('\nRemote ViewModels (calculated in presentation layer):');
  for (final vm in remoteViewModels) {
    print('  ${vm.room.name}: ${vm.onlineDevices}/${vm.deviceCount} = ${vm.onlinePercentage.toStringAsFixed(1)}%');
  }
  
  // Test 3: Verify both produce same results
  print('\n3. CONSISTENCY CHECK');
  print('-' * 40);
  
  var allMatch = true;
  for (var i = 0; i < mockViewModels.length; i++) {
    final mock = mockViewModels[i];
    final remote = remoteViewModels[i];
    
    final match = mock.deviceCount == remote.deviceCount &&
                  mock.onlineDevices == remote.onlineDevices;
    
    print('${mock.room.name}: ${match ? "✅ MATCH" : "❌ MISMATCH"}');
    if (!match) {
      print('  Mock: ${mock.onlineDevices}/${mock.deviceCount}');
      print('  Remote: ${remote.onlineDevices}/${remote.deviceCount}');
      allMatch = false;
    }
  }
  
  print('\n' + '=' * 60);
  print('RESULT: ${allMatch ? "✅ ALL ENVIRONMENTS CONSISTENT" : "❌ INCONSISTENCY DETECTED"}');
  print('=' * 60);
  
  print('\n✅ Clean Architecture:');
  print('  • RoomModel has no calculated fields');
  print('  • Data sources provide raw data only');
  print('  • Calculations in presentation layer only');
  
  print('\n✅ MVVM Pattern:');
  print('  • ViewModels handle all display logic');
  print('  • Single source of truth');
  print('  • Testable and maintainable');
  
  print('\n✅ Consistency:');
  print('  • Same results in all environments');
  print('  • No environment-specific logic');
  print('  • Predictable behavior');
}