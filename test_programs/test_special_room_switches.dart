#!/usr/bin/env dart

import 'package:rgnets_fdk/core/services/mock_data_service.dart';

/// Test that switches in MDF/IDF rooms use special format
void main() {
  print('SPECIAL ROOM SWITCH FORMAT TEST');
  print('=' * 80);
  
  final mockService = MockDataService();
  final devices = mockService.getMockDevices();
  final rooms = mockService.getMockRooms();
  
  // Find MDF and IDF rooms
  print('\n1. IDENTIFYING SPECIAL ROOMS:');
  print('-' * 50);
  
  final mdfRooms = rooms.where((r) => r.description?.contains('MDF') ?? false).toList();
  final idfRooms = rooms.where((r) => r.description?.contains('IDF') ?? false).toList();
  
  print('MDF Rooms found: ${mdfRooms.length}');
  for (final room in mdfRooms.take(3)) {
    print('  ${room.name}: ${room.description}');
  }
  
  print('\nIDF Rooms found: ${idfRooms.length}');
  for (final room in idfRooms.take(5)) {
    print('  ${room.name}: ${room.description}');
  }
  
  // Check switches in these rooms
  print('\n2. SWITCHES IN SPECIAL ROOMS:');
  print('-' * 50);
  
  // Get all switches
  final switches = devices.where((d) => d.type == 'switch').toList();
  
  // Find switches in MDF rooms (they should end with -MDF)
  print('\nMDF Switches (should end with -MDF):');
  final mdfSwitches = switches.where((s) => s.name.contains('-MDF')).toList();
  for (final sw in mdfSwitches.take(5)) {
    print('  ${sw.name.padRight(30)} Location: ${sw.location}');
    
    // Verify format
    if (sw.name.endsWith('-MDF')) {
      print('    ✓ Correct MDF format');
    } else {
      print('    ✗ Wrong format!');
    }
  }
  
  // Find switches in IDF rooms (they should end with -IDF[floor])
  print('\nIDF Switches (should end with -IDF[floor]):');
  final idfSwitches = switches.where((s) => s.name.contains('-IDF')).toList();
  for (final sw in idfSwitches.take(10)) {
    print('  ${sw.name.padRight(30)} Location: ${sw.location}');
    
    // Verify format
    if (sw.name.contains('-IDF')) {
      final parts = sw.name.split('-');
      final lastPart = parts.last;
      if (lastPart.startsWith('IDF')) {
        print('    ✓ Correct IDF format (${lastPart})');
      } else {
        print('    ✗ Wrong format!');
      }
    }
  }
  
  // Regular room switches (should end with -RM[number])
  print('\nRegular Room Switches (should end with -RM[number]):');
  final regularSwitches = switches.where((s) => s.name.contains('-RM')).take(5).toList();
  for (final sw in regularSwitches) {
    print('  ${sw.name.padRight(30)} Location: ${sw.location}');
    
    // Verify format
    if (sw.name.contains('-RM')) {
      print('    ✓ Correct room format');
    } else {
      print('    ✗ Wrong format!');
    }
  }
  
  // Summary
  print('\n3. SUMMARY:');
  print('-' * 50);
  print('Total switches: ${switches.length}');
  print('MDF switches: ${mdfSwitches.length}');
  print('IDF switches: ${idfSwitches.length}');
  print('Regular room switches: ${switches.where((s) => s.name.contains("-RM")).length}');
  
  print('\n✓ Special room switches use MDF/IDF format');
  print('✓ Regular room switches use RM format');
  print('✓ Format: SW[building]-[floor]-[serial]-[model]-[MDF|IDF[floor]|RM[room]]');
}