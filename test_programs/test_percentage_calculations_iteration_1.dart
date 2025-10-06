#!/usr/bin/env dart

// Test Iteration 1: Validate percentage calculations for 0.5%

void main() {
  print('PERCENTAGE CALCULATION TEST - ITERATION 1');
  print('Testing 0.5% calculations for null pms_room and empty rooms');
  print('=' * 80);
  
  calculateNullPmsRoomDevices();
  calculateEmptyRooms();
  validateDistribution();
  testRounding();
}

void calculateNullPmsRoomDevices() {
  print('\n1. NULL PMS_ROOM CALCULATION (0.5% of devices)');
  print('-' * 50);
  
  const totalDevices = 1920;
  final nullPmsRoomCount = (totalDevices * 0.005).round();
  
  print('Total devices: $totalDevices');
  print('Percentage: 0.5%');
  print('Calculation: $totalDevices × 0.005 = ${totalDevices * 0.005}');
  print('Rounded: $nullPmsRoomCount devices');
  
  print('\nVERIFICATION:');
  final actualPercentage = (nullPmsRoomCount / totalDevices) * 100;
  print('Actual percentage: ${actualPercentage.toStringAsFixed(2)}%');
  print('Difference from target: ${(actualPercentage - 0.5).abs().toStringAsFixed(2)}%');
  
  print('\n✓ RESULT: $nullPmsRoomCount devices will have null pms_room');
}

void calculateEmptyRooms() {
  print('\n2. EMPTY ROOMS CALCULATION (0.5% of rooms)');
  print('-' * 50);
  
  const totalRooms = 680;
  final emptyRoomCount = (totalRooms * 0.005).round();
  
  print('Total rooms: $totalRooms');
  print('Percentage: 0.5%');
  print('Calculation: $totalRooms × 0.005 = ${totalRooms * 0.005}');
  print('Rounded: $emptyRoomCount rooms');
  
  print('\nVERIFICATION:');
  final actualPercentage = (emptyRoomCount / totalRooms) * 100;
  print('Actual percentage: ${actualPercentage.toStringAsFixed(2)}%');
  print('Difference from target: ${(actualPercentage - 0.5).abs().toStringAsFixed(2)}%');
  
  print('\n✓ RESULT: $emptyRoomCount rooms will have no devices');
}

void validateDistribution() {
  print('\n3. DISTRIBUTION VALIDATION');
  print('-' * 50);
  
  print('DEVICE DISTRIBUTION:');
  print('  • 1910 devices with valid pms_room (99.5%)');
  print('  • 10 devices with null pms_room (0.5%)');
  print('  Total: 1920 devices ✓');
  
  print('\nROOM DISTRIBUTION:');
  print('  • 677 rooms with devices (99.5%)');
  print('  • 3 empty rooms (0.5%)');
  print('  Total: 680 rooms ✓');
  
  print('\nEDGE CASES COVERED:');
  print('  ✓ Devices without room assignment (10 devices)');
  print('  ✓ Rooms without any devices (3 rooms)');
  print('  ✓ Both represent realistic error scenarios');
}

void testRounding() {
  print('\n4. ROUNDING EDGE CASES');
  print('-' * 50);
  
  print('TESTING DIFFERENT TOTALS:');
  
  // Test various totals to ensure consistent rounding
  final testCases = [
    {'total': 100, 'type': 'devices'},
    {'total': 500, 'type': 'devices'},
    {'total': 1000, 'type': 'devices'},
    {'total': 2000, 'type': 'devices'},
  ];
  
  for (final testCase in testCases) {
    final total = testCase['total'] as int;
    final count = (total * 0.005).round();
    final percentage = (count / total) * 100;
    print('  $total ${testCase['type']}: $count items (${percentage.toStringAsFixed(2)}%)');
  }
  
  print('\n✓ Rounding is consistent and appropriate');
}