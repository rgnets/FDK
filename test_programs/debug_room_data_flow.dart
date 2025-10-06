#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_mock_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/models/room_model.dart';
import 'package:rgnets_fdk/core/config/environment.dart';

void main() async {
  print('=' * 80);
  print('ROOM DATA FLOW DEBUG');
  print('=' * 80);
  
  // Set environment to development
  EnvironmentConfig.setEnvironment(Environment.development);
  print('\n1. Environment: ${EnvironmentConfig.environment}');
  print('   isDevelopment: ${EnvironmentConfig.isDevelopment}');
  
  // Create MockDataService
  print('\n2. Creating MockDataService...');
  final mockService = MockDataService();
  
  // Get raw Room objects
  print('\n3. Raw Room objects from MockDataService:');
  final rooms = mockService.getMockRooms();
  print('   Total rooms: ${rooms.length}');
  
  // Show first few rooms
  print('\n   First 5 rooms:');
  for (final room in rooms.take(5)) {
    print('     ID: ${room.id.padRight(5)} Name: ${room.name.padRight(25)} Building: ${room.building}');
  }
  
  // Test RoomMockDataSourceImpl
  print('\n4. Testing RoomMockDataSourceImpl:');
  final roomDataSource = RoomMockDataSourceImpl(mockDataService: mockService);
  
  // Test getRooms()
  final roomModels = await roomDataSource.getRooms();
  print('   Total RoomModels: ${roomModels.length}');
  
  print('\n   First 5 RoomModels:');
  for (final model in roomModels.take(5)) {
    print('     ID: ${model.id.padRight(5)} Name: ${model.name.padRight(25)} Building: ${model.building}');
  }
  
  // Test getRoom() with valid ID
  print('\n5. Testing getRoom() with valid ID:');
  final firstRoom = rooms.first;
  final retrievedRoom = await roomDataSource.getRoom(firstRoom.id);
  print('   Requested ID: ${firstRoom.id}');
  print('   Retrieved ID: ${retrievedRoom.id}');
  print('   Retrieved Name: ${retrievedRoom.name}');
  
  if (firstRoom.id == retrievedRoom.id) {
    print('   ✓ Correct room returned');
  } else {
    print('   ✗ WRONG room returned! Expected ${firstRoom.id}, got ${retrievedRoom.id}');
  }
  
  // Test getRoom() with invalid ID - THIS SHOULD FAIL
  print('\n6. Testing getRoom() with INVALID ID (should fail):');
  try {
    final invalidRoom = await roomDataSource.getRoom('NONEXISTENT_ID');
    print('   ✗ ERROR: Should have thrown exception but returned:');
    print('     ID: ${invalidRoom.id}');
    print('     Name: ${invalidRoom.name}');
    print('   This is the FALLBACK LOGIC problem!');
  } catch (e) {
    print('   ✓ Correctly threw exception: $e');
  }
  
  // Test createRoom() with empty ID
  print('\n7. Testing createRoom() with empty ID:');
  try {
    final testRoom = RoomModel(
      id: '', 
      name: 'Test Room',
      building: 'Test Building',
    );
    final newRoom = await roomDataSource.createRoom(testRoom);
    if (newRoom.id.isEmpty) {
      print('   ✗ ERROR: ID should have been generated but is empty');
    } else {
      print('   ID was generated: ${newRoom.id}');
      if (newRoom.id.startsWith('mock_')) {
        print('   ✓ Fallback ID generation working (this might be acceptable)');
      } else {
        print('   ? Unexpected ID format: ${newRoom.id}');
      }
    }
  } catch (e) {
    print('   Exception: $e');
  }
  
  print('\n8. ANALYSIS:');
  print('=' * 80);
  
  // Check for problematic patterns
  print('\nProblematic fallback patterns found:');
  print('1. getRoom() with invalid ID returns first room instead of throwing');
  print('2. createRoom() generates fallback ID when empty (may be acceptable)');
  
  print('\n9. RECOMMENDATIONS:');
  print('- Remove orElse fallback in getRoom() method');
  print('- Make invalid room ID lookup throw proper exception');
  print('- Consider if createRoom() ID generation is acceptable behavior');
  
  print('\n' + '=' * 80);
  print('END OF DEBUG');
  print('=' * 80);
}