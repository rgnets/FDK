#!/usr/bin/env dart

// Analysis of Simple Concatenation: return '$baseTitle - $roomId';

class AppNotification {
  final String title;
  final String? roomId;
  
  AppNotification({required this.title, this.roomId});
}

// Simplified solution - just concatenate
String formatNotificationTitleSimple(AppNotification notification) {
  final baseTitle = notification.title;
  final roomId = notification.roomId;
  
  if (roomId == null || roomId.isEmpty) {
    return baseTitle;
  }
  
  // Just concatenate directly
  return '$baseTitle - $roomId';
}

void main() {
  print('SIMPLE CONCATENATION ANALYSIS');
  print('=' * 80);
  
  print('\nPROPOSED SOLUTION:');
  print('  return \'\$baseTitle - \$roomId\';');
  print('\nNo extraction, no manipulation, just direct concatenation.');
  
  print('\n' + '=' * 80);
  print('WHAT EACH ENVIRONMENT PROVIDES:');
  print('=' * 80);
  
  print('\n1. DEVELOPMENT (MockDataService):');
  print('   device.location = room.id = "north-tower-101"');
  print('   notification.roomId = "north-tower-101"');
  
  print('\n2. STAGING (API):');
  print('   device.location = ??? (likely null, "", or some value)');
  print('   notification.roomId = device.location');
  
  print('\n3. PRODUCTION (API):');
  print('   device.location = ??? (same as staging)');
  print('   notification.roomId = device.location');
  
  print('\n' + '=' * 80);
  print('TEST WITH CURRENT DATA:');
  print('=' * 80);
  
  final testCases = [
    // Development scenarios
    AppNotification(title: 'Device Offline', roomId: 'north-tower-101'),
    AppNotification(title: 'Device Offline', roomId: 'south-tower-201'),
    AppNotification(title: 'Device Has Note', roomId: 'east-wing-305'),
    
    // Staging scenarios (various possibilities)
    AppNotification(title: 'Device Offline', roomId: '101'),
    AppNotification(title: 'Device Offline', roomId: ''),
    AppNotification(title: 'Device Offline', roomId: null),
    AppNotification(title: 'Device Has Note', roomId: 'Room 101'),
    AppNotification(title: 'Missing Images', roomId: 'NT-101'),
  ];
  
  print('\nResults with simple concatenation:');
  for (final notification in testCases) {
    final formatted = formatNotificationTitleSimple(notification);
    print('  roomId: "${notification.roomId}" → "$formatted"');
  }
  
  print('\n' + '=' * 80);
  print('ANALYSIS:');
  print('=' * 80);
  
  print('\nPROS:');
  print('  ✓ Extremely simple - no complex logic');
  print('  ✓ No manipulation means no bugs');
  print('  ✓ Whatever is in roomId is displayed as-is');
  print('  ✓ Consistent behavior across all environments');
  
  print('\nCONS:');
  print('  ✗ Different display based on what\'s in device.location');
  print('  ✗ Development: "Device Offline - north-tower-101"');
  print('  ✗ Staging: "Device Offline" (if location is null/empty)');
  print('  ✗ Or: "Device Offline - 101" (if location is numeric)');
  
  print('\n' + '=' * 80);
  print('KEY QUESTION:');
  print('=' * 80);
  
  print('\nWhat does staging/production API actually return for device.location?');
  print('');
  print('If staging returns:');
  print('  • null or "" → Notifications show just title');
  print('  • "101" → Notifications show "Device Offline - 101"');
  print('  • "Room 101" → Notifications show "Device Offline - Room 101"');
  print('  • "north-tower-101" → Same as development');
  
  print('\n' + '=' * 80);
  print('CRITICAL INSIGHT:');
  print('=' * 80);
  
  print('\nThe simple concatenation WILL work consistently IF:');
  print('');
  print('1. We ensure device.location has the same format in all environments');
  print('   OR');
  print('2. We accept that different environments show different room info');
  print('   OR');
  print('3. We fix the data source (API or Mock) to provide consistent location');
  
  print('\n' + '=' * 80);
  print('CURRENT TRUNCATION ISSUE:');
  print('=' * 80);
  
  print('\nThe CURRENT code has truncation logic:');
  print('  if (roomId.length > 10) {');
  print('    displayRoom = \'\${roomId.substring(0, 10)}...\';');
  print('  }');
  print('\nThis causes:');
  print('  "north-tower-101" (15 chars) → "north-towe..."');
  print('\nRemoving truncation would show:');
  print('  "north-tower-101" → "Device Offline - north-tower-101"');
  
  print('\n' + '=' * 80);
  print('RECOMMENDATION:');
  print('=' * 80);
  
  print('\nSimple concatenation works IF we also:');
  print('1. Remove the truncation logic');
  print('2. Remove the numeric vs text separator logic');
  print('3. Just use: return \'\$baseTitle - \$roomId\';');
  print('\nBut this means accepting that:');
  print('  • Dev shows: "Device Offline - north-tower-101"');
  print('  • Staging shows: "Device Offline" or "Device Offline - [whatever API returns]"');
}