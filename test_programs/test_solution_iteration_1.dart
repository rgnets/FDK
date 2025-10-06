#!/usr/bin/env dart

// Test Solution Iteration 1: Remove ID prefixing
// Following Clean Architecture - data layer should not transform IDs

class DeviceModel {
  final String id;
  final String name;
  final String type;
  final String status;
  final int? pmsRoomId;
  
  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.pmsRoomId,
  });
  
  factory DeviceModel.fromApiResponse(Map<String, dynamic> data, String deviceType) {
    // SOLUTION: Don't prefix IDs - keep them as they are from API
    // This follows Clean Architecture - data layer provides raw data
    
    int? extractPmsRoomId() {
      // Check multiple possible fields
      if (data['pms_room'] != null && data['pms_room'] is Map) {
        final pmsRoom = data['pms_room'] as Map<String, dynamic>;
        final idValue = pmsRoom['id'];
        if (idValue is int) return idValue;
        if (idValue is String) return int.tryParse(idValue);
      }
      
      if (data['pms_room_id'] != null) {
        final value = data['pms_room_id'];
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
      }
      
      if (data['room_id'] != null) {
        final value = data['room_id'];
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
      }
      
      return null;
    }
    
    return DeviceModel(
      id: data['id']?.toString() ?? '',  // NO PREFIX!
      name: data['name'] ?? data['nickname'] ?? 'Device-${data['id']}',
      type: deviceType,
      status: _determineStatus(data),
      pmsRoomId: extractPmsRoomId(),
    );
  }
  
  static String _determineStatus(Map<String, dynamic> data) {
    if (data['online'] == true) return 'online';
    if (data['online'] == false) return 'offline';
    if (data['status']?.toString().toLowerCase() == 'online') return 'online';
    if (data['status']?.toString().toLowerCase() == 'offline') return 'offline';
    return 'offline';
  }
}

class Room {
  final String id;
  final String name;
  final List<String>? deviceIds;
  
  Room({required this.id, required this.name, this.deviceIds});
}

class Device {
  final String id;
  final String name;
  final String type;
  final String status;
  final int? pmsRoomId;
  
  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.pmsRoomId,
  });
}

// Test the solution
void testScenario(String name, List<Map<String, dynamic>> apiData, String deviceType) {
  print('\n$name');
  print('-' * 40);
  
  // Convert API data to models
  final models = apiData.map((data) => 
    DeviceModel.fromApiResponse(data, deviceType)
  ).toList();
  
  print('Converted ${models.length} devices:');
  for (final model in models) {
    print('  ID: "${model.id}" (no prefix!), pmsRoomId: ${model.pmsRoomId}, status: ${model.status}');
  }
}

void main() {
  print('SOLUTION ITERATION 1: REMOVE ID PREFIXING');
  print('=' * 80);
  print('Following Clean Architecture principles:');
  print('- Data layer should provide raw data without transformation');
  print('- ID prefixing is a presentation concern, not data layer');
  
  // Test with various API response formats
  testScenario('Access Points', [
    {
      'id': 123,
      'name': 'AP-Conference',
      'online': true,
      'pms_room': {'id': 1, 'name': 'Conference Room'},
    },
    {
      'id': 456,
      'name': 'AP-Lobby',
      'online': false,
      'pms_room_id': 2,
    },
  ], 'access_point');
  
  testScenario('Media Converters (ONTs)', [
    {
      'id': 789,
      'name': 'ONT-001',
      'status': 'online',
      'room_id': 1,
    },
    {
      'id': 101,
      'name': 'ONT-002',
      'online': true,
      'pms_room': 3,
    },
  ], 'ont');
  
  testScenario('Switches', [
    {
      'id': 202,
      'nickname': 'Main Switch',
      'online': true,
      'pms_room': {'id': '1'},
    },
    {
      'id': 303,
      'name': 'Floor Switch',
      'online': false,
    },
  ], 'switch');
  
  print('\n' + '=' * 80);
  print('BENEFITS OF THIS SOLUTION:');
  print('=' * 80);
  print('\n1. Clean Architecture Compliance:');
  print('   - Data layer provides raw data');
  print('   - No ID transformation in data layer');
  print('   - Presentation layer can add prefixes if needed for display');
  
  print('\n2. Consistency:');
  print('   - Device IDs match across all layers');
  print('   - Room deviceIds will match device IDs');
  print('   - Both pmsRoomId and deviceIds matching will work');
  
  print('\n3. Maintainability:');
  print('   - Simpler code');
  print('   - No ID mapping needed');
  print('   - Easier to debug');
  
  print('\n4. MVVM Pattern:');
  print('   - ViewModels can transform IDs for display if needed');
  print('   - Data remains pure');
  
  print('\n' + '=' * 80);
  print('IMPLEMENTATION:');
  print('=' * 80);
  print('\n1. Update DeviceRemoteDataSource:');
  print('   - Remove ID prefixing (lines 246, 274, 302, 318)');
  print('   - Keep original IDs from API');
  
  print('\n2. Improve pmsRoomId extraction:');
  print('   - Check multiple fields');
  print('   - Handle different formats');
  
  print('\n3. No changes needed to:');
  print('   - room_view_models.dart (already correct)');
  print('   - RoomModel (already cleaned)');
  print('   - MockDataService (already using raw IDs)');
}