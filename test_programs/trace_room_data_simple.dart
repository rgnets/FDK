#!/usr/bin/env dart

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_mock_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/repositories/room_repository_impl.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_remote_data_source.dart';

/// Simplified room data pipeline test without Flutter dependencies
void main() async {
  print('=' * 80);
  print('ROOM DATA PIPELINE TEST - Mock Service to Repository');
  print('=' * 80);
  
  // Set environment to development
  EnvironmentConfig.setEnvironment(Environment.development);
  print('\n1. Environment: ${EnvironmentConfig.environment}');
  print('   isDevelopment: ${EnvironmentConfig.isDevelopment}');
  print('   useSyntheticData: ${EnvironmentConfig.useSyntheticData}');
  
  print('\n2. MOCK DATA SERVICE TEST:');
  final mockService = MockDataService();
  final rawRooms = mockService.getMockRooms();
  print('   Mock service provides: ${rawRooms.length} rooms');
  
  if (rawRooms.isEmpty) {
    print('   ❌ CRITICAL: MockDataService returns no rooms!');
    return;
  }
  
  // Show sample rooms
  for (final room in rawRooms.take(3)) {
    print('   Room: ID=${room.id}, Name=${room.name}, Building=${room.building}');
  }
  
  print('\n3. MOCK DATA SOURCE TEST:');
  final mockDataSource = RoomMockDataSourceImpl(mockDataService: mockService);
  final roomModels = await mockDataSource.getRooms();
  print('   Mock data source returns: ${roomModels.length} room models');
  
  if (roomModels.isEmpty) {
    print('   ❌ CRITICAL: Mock data source returns no room models!');
    return;
  }
  
  // Show sample room models
  for (final model in roomModels.take(3)) {
    print('   RoomModel: ID=${model.id}, Name=${model.name}, Building=${model.building}');
  }
  
  print('\n4. REPOSITORY TEST:');
  // Create mock implementations for the other data sources
  final mockRemoteDataSource = MockRoomRemoteDataSource();
  final mockLocalDataSource = MockRoomLocalDataSource();
  
  final repository = RoomRepositoryImpl(
    remoteDataSource: mockRemoteDataSource,
    mockDataSource: mockDataSource,
    localDataSource: mockLocalDataSource,
  );
  
  final repositoryResult = await repository.getRooms();
  
  repositoryResult.fold(
    (failure) {
      print('   ❌ CRITICAL: Repository failed - ${failure.message}');
      return;
    },
    (rooms) {
      print('   ✓ Repository returns: ${rooms.length} room entities');
      
      if (rooms.isEmpty) {
        print('   ❌ CRITICAL: Repository returns no room entities!');
        return;
      }
      
      // Show sample room entities
      for (final room in rooms.take(3)) {
        print('   Room Entity: ID=${room.id}, Name=${room.name}, Building=${room.building}');
      }
    },
  );
  
  print('\n5. DATA INTEGRITY CHECK:');
  if (repositoryResult.isRight()) {
    final rooms = repositoryResult.getOrElse((_) => []);
    
    // Check if data is preserved through the pipeline
    bool dataIntegrity = true;
    
    if (rawRooms.length != roomModels.length) {
      print('   ⚠️  Raw rooms count (${rawRooms.length}) != Room models count (${roomModels.length})');
      dataIntegrity = false;
    }
    
    if (roomModels.length != rooms.length) {
      print('   ⚠️  Room models count (${roomModels.length}) != Room entities count (${rooms.length})');  
      dataIntegrity = false;
    }
    
    // Check first room data preservation
    if (rawRooms.isNotEmpty && roomModels.isNotEmpty && rooms.isNotEmpty) {
      final rawRoom = rawRooms.first;
      final roomModel = roomModels.first;
      final roomEntity = rooms.first;
      
      if (rawRoom.id != roomModel.id || roomModel.id != roomEntity.id) {
        print('   ⚠️  Room ID not preserved: ${rawRoom.id} → ${roomModel.id} → ${roomEntity.id}');
        dataIntegrity = false;
      }
      
      if (rawRoom.name != roomModel.name || roomModel.name != roomEntity.name) {
        print('   ⚠️  Room name not preserved: ${rawRoom.name} → ${roomModel.name} → ${roomEntity.name}');
        dataIntegrity = false;
      }
    }
    
    if (dataIntegrity) {
      print('   ✅ Data integrity maintained through pipeline');
    } else {
      print('   ❌ Data integrity issues detected');
    }
  }
  
  print('\n6. DEVELOPMENT MODE VERIFICATION:');
  print('   Environment isDevelopment: ${EnvironmentConfig.isDevelopment}');
  
  if (EnvironmentConfig.isDevelopment) {
    print('   ✅ Correct environment - should use mock data');
  } else {
    print('   ❌ Wrong environment - may not be using mock data');
  }
  
  print('\n7. SUMMARY:');
  if (repositoryResult.isRight()) {
    final rooms = repositoryResult.getOrElse((_) => []);
    print('   MockDataService: ${rawRooms.length} rooms');
    print('   MockDataSource: ${roomModels.length} room models');
    print('   Repository: ${rooms.length} room entities');
    
    if (rooms.isNotEmpty) {
      print('   ✅ SUCCESS: Room data flows from mock to repository');
    } else {
      print('   ❌ FAILURE: No room data reaches repository layer');
    }
  } else {
    print('   ❌ FAILURE: Repository layer not working');
  }
  
  print('\n' + '=' * 80);
  print('END OF PIPELINE TEST');
  print('=' * 80);
}

/// Mock implementations for testing
class MockRoomRemoteDataSource implements RoomRemoteDataSource {
  @override
  Future<List<RoomModel>> getRooms() async {
    throw UnimplementedError('Not used in development mode');
  }
  
  @override
  Future<RoomModel> getRoom(String id) async {
    throw UnimplementedError('Not used in development mode');
  }
  
  @override
  Future<RoomModel> createRoom(RoomModel room) async {
    throw UnimplementedError('Not used in development mode');
  }
  
  @override
  Future<RoomModel> updateRoom(RoomModel room) async {
    throw UnimplementedError('Not used in development mode');
  }
  
  @override
  Future<void> deleteRoom(String id) async {
    throw UnimplementedError('Not used in development mode');
  }
}

class MockRoomLocalDataSource implements RoomLocalDataSource {
  @override
  Future<List<RoomModel>> getCachedRooms() async => [];
  
  @override
  Future<RoomModel?> getCachedRoom(String id) async => null;
  
  @override
  Future<void> cacheRooms(List<RoomModel> rooms) async {}
  
  @override
  Future<void> cacheRoom(RoomModel room) async {}
  
  @override
  Future<bool> isCacheValid() async => false;
  
  @override
  Future<void> clearCache() async {}
}