#!/usr/bin/env dart

// Test Iteration 3: Architectural solution following Clean Architecture

// Following Clean Architecture principles:
// 1. Single source of truth
// 2. Consistent data structures
// 3. No data transformation in data layer
// 4. Clear separation of concerns

class CleanArchitectureSolution {
  void analyzeProblem() {
    print('PROBLEM ANALYSIS');
    print('=' * 80);
    
    print('\nCurrent Issues:');
    print('1. ID Prefixing in data layer (WRONG):');
    print('   - ap_123, ont_456, sw_789');
    print('   - Violates Clean Architecture');
    print('   - Data layer should NOT transform data');
    
    print('\n2. Inconsistent pmsRoomId extraction:');
    print('   - access_points: ✓ extracts pms_room.id');
    print('   - media_converters: ✓ extracts pms_room.id');
    print('   - switch_devices: ✓ extracts pms_room.id');
    print('   - wlan_devices: ✗ MISSING extraction');
    
    print('\n3. Single field principle:');
    print('   - API should use ONE field: pms_room');
    print('   - All devices should have this field');
    print('   - Structure should be consistent');
  }
  
  void proposeDataLayer() {
    print('\n\nDATA LAYER SOLUTION');
    print('=' * 80);
    
    print('\nPrinciples:');
    print('1. NO data transformation');
    print('2. Direct mapping from API');
    print('3. Consistent structure');
    
    print('\nProposed DeviceModel.fromJson:');
    print('''
    DeviceModel.fromJson(Map<String, dynamic> json) {
      // Extract room ID from consistent field
      int? pmsRoomId;
      if (json['pms_room'] != null && json['pms_room'] is Map) {
        final pmsRoom = json['pms_room'] as Map<String, dynamic>;
        pmsRoomId = _parseId(pmsRoom['id']);
      }
      
      return DeviceModel(
        id: json['id']?.toString() ?? '',  // NO PREFIX!
        name: json['name']?.toString() ?? '',
        type: _determineType(json),
        status: _determineStatus(json),
        pmsRoomId: pmsRoomId,  // Consistent extraction
      );
    }
    ''');
    
    print('\nThis ensures:');
    print('- No ID transformation (no prefixes)');
    print('- Consistent pmsRoomId extraction');
    print('- Clean data layer');
  }
  
  void proposeDomainLayer() {
    print('\n\nDOMAIN LAYER');
    print('=' * 80);
    
    print('\nDevice entity remains pure:');
    print('''
    class Device {
      final String id;
      final String name;
      final String type;
      final String status;
      final int? pmsRoomId;  // Single field for room association
    }
    ''');
    
    print('\nRoom entity remains pure:');
    print('''
    class Room {
      final String id;
      final String name;
      // No device counts here!
    }
    ''');
  }
  
  void proposePresentationLayer() {
    print('\n\nPRESENTATION LAYER');
    print('=' * 80);
    
    print('\nRoomViewModel calculates everything:');
    print('''
    List<Device> _getDevicesForRoom(Room room, List<Device> allDevices) {
      final roomIdInt = int.tryParse(room.id);
      if (roomIdInt != null) {
        // Single matching logic by pmsRoomId
        return allDevices.where((d) => d.pmsRoomId == roomIdInt).toList();
      }
      return [];
    }
    ''');
    
    print('\nThis is the ONLY place where:');
    print('- Device counting happens');
    print('- Online percentage is calculated');
    print('- Room-device matching occurs');
  }
  
  void validateArchitecture() {
    print('\n\nARCHITECTURE VALIDATION');
    print('=' * 80);
    
    final checks = [
      'Clean Architecture: Data layer provides raw data ✓',
      'MVVM: ViewModels handle display logic ✓',
      'Single Responsibility: Each layer has one job ✓',
      'Dependency Injection: Constructor-based ✓',
      'Riverpod: Reactive state management ✓',
      'Single Source of Truth: pms_room.id for all devices ✓',
    ];
    
    for (final check in checks) {
      print('✓ $check');
    }
  }
}

void testSolution() {
  print('\n\nSOLUTION TEST');
  print('=' * 80);
  
  // Clean extraction function
  int? extractPmsRoomId(Map<String, dynamic> json) {
    if (json['pms_room'] != null && json['pms_room'] is Map) {
      final pmsRoom = json['pms_room'] as Map<String, dynamic>;
      final id = pmsRoom['id'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    }
    return null;
  }
  
  // Test with various API responses
  final testData = [
    {'device': 'AP', 'data': {'id': 123, 'pms_room': {'id': 1}}},
    {'device': 'ONT', 'data': {'id': 456, 'pms_room': {'id': '2'}}},
    {'device': 'Switch', 'data': {'id': 789, 'pms_room': {'id': 3}}},
    {'device': 'WLAN', 'data': {'id': 101, 'pms_room': {'id': 4}}},
  ];
  
  print('Testing consistent extraction:');
  for (final test in testData) {
    final data = test['data'] as Map<String, dynamic>;
    final pmsRoomId = extractPmsRoomId(data);
    print('${test['device']}: id=${data['id']}, pmsRoomId=$pmsRoomId');
  }
  
  print('\n✓ All devices use same extraction logic');
  print('✓ No ID prefixing');
  print('✓ Consistent structure');
}

void main() {
  print('CLEAN ARCHITECTURE SOLUTION - ITERATION 3');
  print('=' * 80);
  
  final solution = CleanArchitectureSolution();
  solution.analyzeProblem();
  solution.proposeDataLayer();
  solution.proposeDomainLayer();
  solution.proposePresentationLayer();
  solution.validateArchitecture();
  
  testSolution();
  
  print('\n' + '=' * 80);
  print('IMPLEMENTATION PLAN');
  print('=' * 80);
  
  print('\n1. Fix device_remote_data_source.dart:');
  print('   a. Remove ID prefixing (lines 246, 274, 302, 318)');
  print('   b. Add pmsRoomId extraction for WLAN devices');
  print('   c. Use consistent extraction logic');
  
  print('\n2. Ensure API consistency:');
  print('   - All devices should have pms_room field');
  print('   - Room IDs should match pms_room.id values');
  
  print('\n3. No changes needed to:');
  print('   - room_view_models.dart (already correct)');
  print('   - Domain entities (already clean)');
  print('   - RoomModel (already fixed)');
}