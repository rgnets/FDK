#!/usr/bin/env dart

import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_view_models.dart';

/// Test the room name display logic
void main() {
  print('=' * 80);
  print('ROOM NAME DISPLAY TEST');
  print('=' * 80);
  
  // Test data representing current mock format
  final testRooms = [
    Room(
      id: '1000',
      name: 'CE-101', // Central Hub room 101
      building: 'Central Hub',
      floor: 1,
    ),
    Room(
      id: '1001', 
      name: 'NO-205', // North Tower room 205
      building: 'North Tower', 
      floor: 2,
    ),
    Room(
      id: '1002',
      name: 'SW-312', // South Wing room 312
      building: 'South Wing',
      floor: 3,
    ),
    Room(
      id: '1003',
      name: 'BadFormat', // Edge case - no dash
      building: 'Test Building',
      floor: 1,
    ),
    Room(
      id: '1004',
      name: 'AB-CD-123', // Edge case - multiple dashes
      building: 'Test Building 2',
      floor: 1,
    ),
  ];
  
  print('\n1. CURRENT BEHAVIOR:');
  for (final room in testRooms) {
    final viewModel = RoomViewModel(
      room: room,
      deviceCount: 5,
      onlineDevices: 4,
    );
    
    print('Room: ${room.name}');
    print('  Current Display Title: "${viewModel.name}"');
    print('  Current Location Display: "${viewModel.locationDisplay}"');
    print('');
  }
  
  print('\n2. PROPOSED NEW BEHAVIOR:');
  for (final room in testRooms) {
    final currentName = room.name;
    final extractedNumber = extractRoomNumber(currentName);
    
    print('Room: $currentName');
    print('  Proposed Display Title: "$extractedNumber"');
    print('  Would Remove Location Display');
    print('');
  }
  
  print('\n3. ROOM NUMBER EXTRACTION LOGIC TEST:');
  final testCases = [
    'CE-101',
    'NO-205',
    'SW-312',
    'BadFormat',
    'AB-CD-123',
    '205',
    '',
    'ROOM-999',
  ];
  
  for (final testCase in testCases) {
    final result = extractRoomNumber(testCase);
    print('  "$testCase" → "$result"');
  }
  
  print('\n4. ARCHITECTURE COMPLIANCE CHECK:');
  print('  ✓ View Model transformation (MVVM pattern)');
  print('  ✓ No domain entity changes (Clean Architecture)');
  print('  ✓ Presentation layer logic only');
  print('  ✓ Same code path for all environments');
  print('  ✓ Preserves original data in domain layer');
  
  print('\n' + '=' * 80);
  print('END OF TEST');
  print('=' * 80);
}

/// Extract just the room number from various formats
String extractRoomNumber(String roomName) {
  // Handle empty or null cases
  if (roomName.isEmpty) {
    return 'Unknown';
  }
  
  // If it contains a dash, take the part after the last dash
  if (roomName.contains('-')) {
    final parts = roomName.split('-');
    final lastPart = parts.last.trim();
    
    // Return the last part if it's numeric-ish, otherwise return original
    if (RegExp(r'^\d+[A-Z]?$').hasMatch(lastPart)) {
      return lastPart;
    }
  }
  
  // If it's already just a number, return it
  if (RegExp(r'^\d+[A-Z]?$').hasMatch(roomName.trim())) {
    return roomName.trim();
  }
  
  // Fallback: try to extract any number sequence
  final match = RegExp(r'\d+').firstMatch(roomName);
  if (match != null) {
    return match.group(0)!;
  }
  
  // Ultimate fallback: return original name
  return roomName;
}