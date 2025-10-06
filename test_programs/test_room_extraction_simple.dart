#!/usr/bin/env dart

/// Simple test for room number extraction logic
void main() {
  print('=' * 80);
  print('ROOM NUMBER EXTRACTION TEST');
  print('=' * 80);
  
  // Test cases based on current mock data format
  final testCases = [
    // Current mock format
    'CE-101', // Central Hub room 101 → should show "101"
    'NO-205', // North Tower room 205 → should show "205" 
    'SW-312', // South Wing room 312 → should show "312"
    'EA-004', // East Wing room 4 → should show "004" or "4"
    'WE-515', // West Wing room 515 → should show "515"
    
    // Edge cases
    'BadFormat', // No dash → fallback
    'AB-CD-123', // Multiple dashes → "123"
    '205', // Already just number → "205"
    '', // Empty → fallback
    'ROOM-999', // Word prefix → "999"
    'A-B-C-456-D', // Many parts → "456" (last numeric part)
  ];
  
  print('\nTesting room number extraction:');
  print('-' * 40);
  
  for (final testCase in testCases) {
    final result = extractRoomNumber(testCase);
    print('  "$testCase" → "$result"');
  }
  
  print('\n\nAlgorithm explanation:');
  print('1. If contains dash: take last part if it\'s numeric');
  print('2. If already numeric: return as-is');
  print('3. Fallback: extract first number sequence');
  print('4. Ultimate fallback: return original');
  
  print('\nArchitecture compliance:');
  print('✓ Pure function - no side effects');
  print('✓ Testable logic');
  print('✓ Handles edge cases gracefully');
  print('✓ Preserves original data');
  
  print('\n' + '=' * 80);
  print('EXTRACTION TEST COMPLETE');
  print('=' * 80);
}

/// Extract just the room number from various formats
String extractRoomNumber(String roomName) {
  // Handle empty cases
  if (roomName.isEmpty) {
    return 'Unknown';
  }
  
  // If it contains a dash, take the part after the last dash
  if (roomName.contains('-')) {
    final parts = roomName.split('-');
    final lastPart = parts.last.trim();
    
    // If last part is numeric (with optional letter suffix), return it
    if (RegExp(r'^\d+[A-Za-z]?$').hasMatch(lastPart)) {
      return lastPart;
    }
    
    // If last part isn't numeric, look for last numeric part in all parts
    for (int i = parts.length - 1; i >= 0; i--) {
      final part = parts[i].trim();
      if (RegExp(r'^\d+[A-Za-z]?$').hasMatch(part)) {
        return part;
      }
    }
  }
  
  // If it's already just a number (with optional letter), return it
  if (RegExp(r'^\d+[A-Za-z]?$').hasMatch(roomName.trim())) {
    return roomName.trim();
  }
  
  // Fallback: extract first number sequence from anywhere in string
  final match = RegExp(r'\d+').firstMatch(roomName);
  if (match != null) {
    return match.group(0)!;
  }
  
  // Ultimate fallback: return original name
  return roomName;
}