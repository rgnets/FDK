#!/usr/bin/env dart

// Test Iteration 3: Verify actual device names from mock data

void main() {
  print('ACTUAL DEVICE NAME ANALYSIS - ITERATION 3');
  print('=' * 80);
  
  print('\nMOCK DATA DEVICE NAME GENERATION:');
  print('=' * 80);
  
  print('\nFrom mock_data_service.dart line 278:');
  print('  name: \'AP-\${roomId.toUpperCase()}\$suffix\'');
  print('\nWhere roomId is like: "north-tower-101"');
  print('\nResults in device names like:');
  print('  • AP-NORTH-TOWER-101');
  print('  • AP-NORTH-TOWER-101-A (multiple APs)');
  print('  • ONT-SOUTH-TOWER-201');
  print('  • SW-EAST-WING-301');
  
  print('\n' + '=' * 80);
  print('PARSING CHALLENGE:');
  print('=' * 80);
  
  print('\nThe actual device names are NOT in the format I assumed!');
  print('  Expected: "AP-NT-101-1"');
  print('  Actual: "AP-NORTH-TOWER-101"');
  
  print('\nThis means device name parsing won\'t work reliably because:');
  print('  1. Full building names, not abbreviations');
  print('  2. Different hyphen positions');
  print('  3. Can\'t reliably extract room number');
  
  print('\n' + '=' * 80);
  print('RE-EVALUATING SOLUTIONS:');
  print('=' * 80);
  
  print('\n--- OPTION A: Device Name Parsing [INVALID] ---');
  print('  ✗ Device names don\'t follow expected pattern');
  print('  ✗ Can\'t reliably extract room info');
  
  print('\n--- OPTION B: Use pmsRoomId with Lookup [ARCHITECTURAL ISSUE] ---');
  print('  ✗ Requires rooms in service layer');
  print('  ✗ Violates Clean Architecture');
  print('  ✗ Not available in all contexts');
  
  print('\n--- OPTION C: Store pmsRoomId and Enrich in Presentation ---');
  print('Pros:');
  print('  • Architecturally sound');
  print('  • pmsRoomId is consistent (integer)');
  print('  • Presentation layer can lookup room');
  print('Implementation:');
  print('  1. Store pmsRoomId in notification.metadata');
  print('  2. NotificationsScreen gets room from provider');
  print('  3. Display formatted room name');
  
  print('\n--- OPTION D: Simplify Display Logic ---');
  print('Pros:');
  print('  • No data changes');
  print('  • Works immediately');
  print('  • No lookups needed');
  print('Implementation:');
  print('  1. Modify _formatNotificationTitle');
  print('  2. Handle any format consistently');
  print('  3. Extract meaningful parts where possible');
  
  print('\n' + '=' * 80);
  print('REVISED RECOMMENDATION: OPTION D');
  print('=' * 80);
  
  print('\nSimplify the display logic to handle all formats:');
  print('');
  print('String _formatNotificationTitle(AppNotification notification) {');
  print('  final baseTitle = notification.title;');
  print('  final roomId = notification.roomId;');
  print('  ');
  print('  if (roomId == null || roomId.isEmpty) {');
  print('    return baseTitle;');
  print('  }');
  print('  ');
  print('  // Extract meaningful room identifier');
  print('  String displayRoom = roomId;');
  print('  ');
  print('  // Handle different formats:');
  print('  // "north-tower-101" -> extract "101"');
  print('  // "101" -> use as-is');
  print('  // "NT-101" -> use as-is');
  print('  ');
  print('  // If it contains hyphens and ends with numbers, extract the number');
  print('  final match = RegExp(r\'(\\d+)\$\').firstMatch(roomId);');
  print('  if (match != null) {');
  print('    displayRoom = match.group(1)!;');
  print('  }');
  print('  ');
  print('  // Always use consistent format');
  print('  return \'\$baseTitle - Room \$displayRoom\';');
  print('}');
  
  print('\n' + '=' * 80);
  print('TEST CASES:');
  print('=' * 80);
  
  // Test the proposed logic
  String formatNotificationTitle(String baseTitle, String? roomId) {
    if (roomId == null || roomId.isEmpty) {
      return baseTitle;
    }
    
    String displayRoom = roomId;
    
    // Extract room number if present
    final match = RegExp(r'(\d+)$').firstMatch(roomId);
    if (match != null) {
      displayRoom = match.group(1)!;
    }
    
    return '$baseTitle - Room $displayRoom';
  }
  
  final testCases = [
    ('Device Offline', 'north-tower-101'),
    ('Device Offline', '101'),
    ('Device Offline', 'NT-101'),
    ('Device Offline', ''),
    ('Device Offline', null),
    ('Device Has Note', 'south-tower-201'),
    ('Missing Images', '301'),
  ];
  
  print('\nResults:');
  for (final (title, room) in testCases) {
    final formatted = formatNotificationTitle(title, room);
    print('  Input: roomId="$room"');
    print('  Output: "$formatted"');
    print('');
  }
  
  print('=' * 80);
  print('BENEFITS OF THIS APPROACH:');
  print('=' * 80);
  print('  1. No data model changes');
  print('  2. No architectural violations');
  print('  3. Works with any roomId format');
  print('  4. Consistent display across environments');
  print('  5. Simple, maintainable code');
  print('  6. No additional dependencies or lookups');
}