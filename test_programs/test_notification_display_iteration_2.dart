#!/usr/bin/env dart

// Test Iteration 2: Analyze what device.location contains in different environments

void main() {
  print('NOTIFICATION DISPLAY ANALYSIS - ITERATION 2');
  print('=' * 80);
  
  print('\nDEVICE LOCATION VALUES:');
  print('=' * 80);
  
  print('\n1. DEVELOPMENT (MockDataService):');
  print('   - Source: room.id');
  print('   - Format: building-floor-room (e.g., "north-tower-101")');
  print('   - Characteristics:');
  print('     • Contains hyphens');
  print('     • Usually > 10 characters');
  print('     • Text format (not numeric)');
  print('   - Examples:');
  print('     • "north-tower-101"');
  print('     • "south-tower-201"');
  print('     • "east-wing-305"');
  print('     • "central-hub-102"');
  
  print('\n2. STAGING (API Response):');
  print('   - Source: API json["location"]');
  print('   - Format: ???');
  print('   - Possibilities:');
  print('     • Numeric string (e.g., "101", "201")');
  print('     • Empty string ("")');
  print('     • null');
  print('     • Short room code (e.g., "NT-101")');
  
  print('\n' + '=' * 80);
  print('NOTIFICATION TITLE FORMATTING LOGIC:');
  print('=' * 80);
  
  print('\nCurrent Implementation (notifications_screen.dart lines 25-47):');
  print('```dart');
  print('String _formatNotificationTitle(AppNotification notification) {');
  print('  final baseTitle = notification.title;');
  print('  final roomId = notification.roomId;');
  print('  ');
  print('  if (roomId != null && roomId.isNotEmpty) {');
  print('    var displayRoom = roomId;');
  print('    if (roomId.length > 10) {');
  print('      displayRoom = \'\${roomId.substring(0, 10)}...\';');
  print('    }');
  print('    ');
  print('    final isNumeric = RegExp(r\'^\\d+\$\').hasMatch(roomId);');
  print('    if (isNumeric) {');
  print('      return \'\$baseTitle \$displayRoom\';  // space separator');
  print('    } else {');
  print('      return \'\$baseTitle - \$displayRoom\'; // dash separator');
  print('    }');
  print('  }');
  print('  return baseTitle;');
  print('}');
  print('```');
  
  print('\n' + '=' * 80);
  print('RESULTING DISPLAY DIFFERENCES:');
  print('=' * 80);
  
  print('\nDEVELOPMENT:');
  print('  Input: roomId="north-tower-101" (text, > 10 chars)');
  print('  Process:');
  print('    1. Length > 10, so truncate: "north-towe..."');
  print('    2. Not numeric, so use dash: "-"');
  print('  Output: "Device Offline - north-towe..."');
  
  print('\nSTAGING (if numeric):');
  print('  Input: roomId="101" (numeric, <= 10 chars)');
  print('  Process:');
  print('    1. Length <= 10, no truncation: "101"');
  print('    2. Is numeric, so use space: " "');
  print('  Output: "Device Offline 101"');
  
  print('\nSTAGING (if empty/null):');
  print('  Input: roomId="" or null');
  print('  Process:');
  print('    1. Empty or null, return base title only');
  print('  Output: "Device Offline"');
  
  print('\n' + '=' * 80);
  print('ROOT CAUSE:');
  print('=' * 80);
  
  print('\nThe display difference is caused by:');
  print('1. MockDataService sets location = room.id (e.g., "north-tower-101")');
  print('2. API likely returns different format or empty/null for location');
  print('3. NotificationGenerationService copies device.location to notification.roomId');
  print('4. The formatting logic treats them differently:');
  print('   - Text with hyphens → dash separator + truncation');
  print('   - Numeric → space separator, no truncation');
  print('   - Empty/null → no room displayed');
  
  print('\n' + '=' * 80);
  print('SOLUTION NEEDED:');
  print('=' * 80);
  
  print('\nTo ensure consistent display across all environments:');
  print('1. Determine what format staging API actually returns for location');
  print('2. Either:');
  print('   a) Normalize the location format in both environments');
  print('   b) Use a different field that\'s consistent (like pmsRoomId)');
  print('   c) Adjust the display logic to handle all formats consistently');
}