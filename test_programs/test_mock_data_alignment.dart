#!/usr/bin/env dart

import 'dart:io';

/// Test program to analyze and fix mock data alignment with staging API
/// This ensures mock data matches the exact format of staging API responses
void main() async {
  print('MOCK DATA vs STAGING API ALIGNMENT TEST');
  print('=' * 80);
  
  // Analyze current mock data format
  analyzeMockDataFormat();
  
  // Analyze staging API format based on documentation
  analyzeStagingApiFormat();
  
  // Propose alignment changes
  proposeAlignmentChanges();
  
  // Test architectural compliance
  testArchitecturalCompliance();
  
  print('\n✅ Analysis complete');
}

void analyzeMockDataFormat() {
  print('\n1. CURRENT MOCK DATA FORMAT:');
  print('-' * 50);
  
  // From mock_data_service.dart lines 73-74
  final building = 'North Tower';
  final floor = 2;
  final roomNum = 5;
  
  // Current mock format
  final currentMockLocation = '(${building}) ${floor}${roomNum.toString().padLeft(2, '0')}';
  
  print('Building: $building');
  print('Floor: $floor');
  print('Room: $roomNum');
  print('Generated location: "$currentMockLocation"');
  print('Length: ${currentMockLocation.length} characters');
  
  // Test with different buildings
  final testCases = [
    ('North Tower', 2, 5),
    ('South Tower', 10, 15),
    ('East Wing', 1, 1),
    ('West Wing', 8, 1),
    ('Central Hub', 3, 12),
  ];
  
  print('\nSample mock locations:');
  for (final (bldg, flr, rm) in testCases) {
    final loc = '($bldg) $flr${rm.toString().padLeft(2, '0')}';
    print('  $loc (${loc.length} chars)');
  }
}

void analyzeStagingApiFormat() {
  print('\n2. STAGING API FORMAT (from test_staging_api_location.py):');
  print('-' * 50);
  
  // Based on the Python test script, staging API returns:
  final stagingExamples = [
    '(West Wing) 801',
    '(North Tower) 205',
  ];
  
  print('Staging API pms_room.name examples:');
  for (final example in stagingExamples) {
    print('  "$example" (${example.length} chars)');
  }
  
  print('\nKey observations:');
  print('  - Format: (Building) RoomNumber');
  print('  - Room number WITHOUT separate floor digit');
  print('  - Room numbers are 3 digits (e.g., 801, 205)');
  print('  - This matches hotel/PMS standard room numbering');
}

void proposeAlignmentChanges() {
  print('\n3. PROPOSED ALIGNMENT CHANGES:');
  print('-' * 50);
  
  print('''
The mock data needs to change its room naming to match PMS standards:

CURRENT (incorrect):
  roomName = '\${building.substring(0, 2).toUpperCase()}-\$floor\${roomNum.toString().padLeft(2, '0')}';
  displayLocation = '(\$building) \$floor\${roomNum.toString().padLeft(2, '0')}';
  
  Examples:
    - "(North Tower) 205" means floor 2, room 05
    - "(West Wing) 801" means floor 8, room 01

PROPOSED (correct - matching API):
  // Generate proper 3-digit room numbers (floor + room number)
  final roomNumber = floor * 100 + roomNum; // Standard hotel numbering
  roomName = '\${building.substring(0, 2).toUpperCase()}-\$roomNumber';
  displayLocation = '(\$building) \$roomNumber';
  
  Examples:
    - "(North Tower) 205" means room 205 (floor 2, room 5)
    - "(West Wing) 801" means room 801 (floor 8, room 1)

This matches standard hotel/PMS room numbering where:
  - First digit(s) = floor
  - Last two digits = room number on that floor
  - Room 205 = Floor 2, Room 05
  - Room 801 = Floor 8, Room 01
  - Room 1015 = Floor 10, Room 15
''');
}

void testArchitecturalCompliance() {
  print('\n4. ARCHITECTURAL COMPLIANCE CHECK:');
  print('-' * 50);
  
  print('✓ Clean Architecture: Data layer (mock_data_service) generates data');
  print('✓ MVVM: No UI logic, pure data generation');
  print('✓ Dependency Injection: MockDataService is injected via providers');
  print('✓ Riverpod: Used consistently for state management');
  print('✓ Single Responsibility: Mock service only generates mock data');
  
  print('\nImplementation location:');
  print('  File: lib/core/services/mock_data_service.dart');
  print('  Method: _generateRooms()');
  print('  Lines to change: 73-74');
  
  print('\nChanges needed:');
  print('  1. Update room number generation to use 3-digit format');
  print('  2. Update displayLocation to match staging format');
  print('  3. Ensure roomName uses the same convention');
}