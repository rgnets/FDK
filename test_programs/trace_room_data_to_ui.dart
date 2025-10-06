#!/usr/bin/env dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/use_case_providers.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_view_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Complete end-to-end test from mock data service to UI data
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=' * 80);
  print('ROOM DATA PIPELINE TRACE - Mock to UI');
  print('=' * 80);
  
  // Set environment to development
  EnvironmentConfig.setEnvironment(Environment.development);
  print('\n1. Environment: ${EnvironmentConfig.environment}');
  print('   isDevelopment: ${EnvironmentConfig.isDevelopment}');
  
  // Initialize providers
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );
  
  try {
    print('\n2. PROVIDER CHAIN TEST:');
    
    // Test mock data source directly
    final mockDataSource = container.read(roomMockDataSourceProvider);
    print('   ✓ roomMockDataSourceProvider: ${mockDataSource.runtimeType}');
    
    // Test repository
    final repository = container.read(roomRepositoryProvider);
    print('   ✓ roomRepositoryProvider: ${repository.runtimeType}');
    
    // Test use case
    final useCase = container.read(getRoomsProvider);
    print('   ✓ getRoomsProvider: ${useCase.runtimeType}');
    
    print('\n3. MOCK DATA SOURCE TEST:');
    final mockRooms = await mockDataSource.getRooms();
    print('   Mock data source returned: ${mockRooms.length} rooms');
    if (mockRooms.isNotEmpty) {
      final firstRoom = mockRooms.first;
      print('   First room: ID=${firstRoom.id}, Name=${firstRoom.name}');
    }
    
    print('\n4. REPOSITORY LAYER TEST:');
    final repositoryResult = await repository.getRooms();
    repositoryResult.fold(
      (failure) {
        print('   ✗ Repository failed: ${failure.message}');
        return;
      },
      (rooms) {
        print('   ✓ Repository returned: ${rooms.length} rooms');
        if (rooms.isNotEmpty) {
          final firstRoom = rooms.first;
          print('   First room: ID=${firstRoom.id}, Name=${firstRoom.name}');
        }
      },
    );
    
    if (repositoryResult.isLeft()) {
      print('\n❌ REPOSITORY LAYER FAILED - Cannot continue');
      container.dispose();
      return;
    }
    
    print('\n5. RIVERPOD PROVIDER TEST:');
    try {
      final roomsAsync = await container.read(roomsNotifierProvider.future);
      print('   ✓ RoomsNotifier returned: ${roomsAsync.length} rooms');
      
      if (roomsAsync.isNotEmpty) {
        final firstRoom = roomsAsync.first;
        print('   First room from provider: ID=${firstRoom.id}, Name=${firstRoom.name}');
      }
      
      // Test room statistics
      final stats = container.read(roomStatisticsProvider);
      print('   Room statistics: ${stats.total} total, ${stats.roomsWithIssues} with issues');
      
    } catch (e) {
      print('   ✗ RoomsNotifier failed: $e');
      container.dispose();
      return;
    }
    
    print('\n6. VIEW MODEL TEST:');
    try {
      // Test room view models
      final allRoomsVm = container.read(filteredRoomViewModelsProvider('all'));
      print('   ✓ All rooms view models: ${allRoomsVm.length}');
      
      final readyRoomsVm = container.read(filteredRoomViewModelsProvider('ready'));
      print('   ✓ Ready rooms view models: ${readyRoomsVm.length}');
      
      final issuesRoomsVm = container.read(filteredRoomViewModelsProvider('issues'));
      print('   ✓ Issues rooms view models: ${issuesRoomsVm.length}');
      
      if (allRoomsVm.isNotEmpty) {
        final firstVm = allRoomsVm.first;
        print('   First view model:');
        print('     Name: ${firstVm.name}');
        print('     Location: ${firstVm.locationDisplay}');
        print('     Devices: ${firstVm.onlineDevices}/${firstVm.deviceCount} online');
        print('     Has Issues: ${firstVm.hasIssues}');
        print('     Online %: ${firstVm.onlinePercentage.toStringAsFixed(1)}%');
      }
      
    } catch (e) {
      print('   ✗ View Models failed: $e');
      container.dispose();
      return;
    }
    
    print('\n7. UI DATA READINESS:');
    final roomStats = container.read(roomStatsProvider);
    print('   UI Statistics:');
    print('     Total: ${roomStats.total}');
    print('     Ready: ${roomStats.ready}');  
    print('     With Issues: ${roomStats.withIssues}');
    
    // Test what the UI would actually render
    print('\n8. UI RENDERING SIMULATION:');
    final filteredRooms = container.read(filteredRoomViewModelsProvider('all'));
    
    if (filteredRooms.isEmpty) {
      print('   UI WOULD SHOW: Empty state - "No rooms configured"');
      print('   ❌ PROBLEM: UI has no room data to display!');
    } else {
      print('   UI WOULD SHOW: List of ${filteredRooms.length} rooms');
      print('   ✓ SUCCESS: Room data reaches the UI layer');
      
      // Simulate first few list items
      for (int i = 0; i < filteredRooms.take(3).length; i++) {
        final vm = filteredRooms[i];
        print('   [${i + 1}] ${vm.name} - ${vm.locationDisplay} - ${vm.onlineDevices}/${vm.deviceCount} online');
      }
    }
    
    print('\n9. CRITICAL CHECKS:');
    print('   Environment is Development: ${EnvironmentConfig.isDevelopment}');
    print('   Mock data source provides data: ${mockRooms.length > 0}');  
    print('   Repository converts to domain: ${repositoryResult.isRight()}');
    print('   Provider state is populated: ${(await container.read(roomsNotifierProvider.future)).length > 0}');
    print('   View models are created: ${filteredRooms.length > 0}');
    print('   UI would display data: ${filteredRooms.isNotEmpty}');
    
    if (filteredRooms.isEmpty) {
      print('\n❌ CRITICAL ISSUE: Data does not reach UI layer');
      print('Need to investigate view model creation or provider chain');
    } else {
      print('\n✅ SUCCESS: Complete data pipeline working');
      print('Mock data → Repository → Provider → View Models → UI');
    }
    
  } catch (e, stackTrace) {
    print('\n❌ ERROR in pipeline: $e');
    print('Stack trace:');
    print(stackTrace);
  } finally {
    container.dispose();
  }
  
  print('\n' + '=' * 80);
  print('END OF PIPELINE TRACE');
  print('=' * 80);
}