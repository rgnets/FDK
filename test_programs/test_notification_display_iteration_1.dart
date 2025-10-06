#!/usr/bin/env dart

// Test Iteration 1: Analyze notification display differences

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? roomId;
  final String? deviceId;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.roomId,
    this.deviceId,
  });
}

// Current implementation from notifications_screen.dart (lines 25-47)
String formatNotificationTitle(AppNotification notification) {
  final baseTitle = notification.title;
  final roomId = notification.roomId;
  
  // Add room to title if available
  if (roomId != null && roomId.isNotEmpty) {
    // Truncate room name if longer than 10 characters
    var displayRoom = roomId;
    if (roomId.length > 10) {
      displayRoom = '${roomId.substring(0, 10)}...';
    }
    
    // Check if roomId looks like a number
    final isNumeric = RegExp(r'^\d+$').hasMatch(roomId);
    if (isNumeric) {
      return '$baseTitle $displayRoom';  // "Device Offline 003"
    } else {
      return '$baseTitle - $displayRoom'; // "Device Offline - Conference..."
    }
  }
  
  return baseTitle;
}

void testScenario(String name, AppNotification notification) {
  print('\n$name:');
  print('  Input: title="${notification.title}", roomId="${notification.roomId}"');
  print('  Output: "${formatNotificationTitle(notification)}"');
}

void main() {
  print('NOTIFICATION DISPLAY ANALYSIS - ITERATION 1');
  print('=' * 80);
  
  print('CURRENT LOGIC:');
  print('1. If roomId is null or empty: show base title only');
  print('2. If roomId > 10 chars: truncate with "..."');
  print('3. If roomId is numeric: use space separator');
  print('4. If roomId is text: use dash separator');
  
  print('\n' + '=' * 80);
  print('TEST SCENARIOS');
  print('=' * 80);
  
  // Development scenarios (MockDataService)
  print('\n--- DEVELOPMENT (Mock Data) ---');
  
  // From MockDataService: roomId = device.location
  // Example: 'north-tower-101', 'south-tower-201', etc.
  testScenario('Dev: Long room ID',
    AppNotification(
      id: 'notif-1',
      title: 'Device Offline',
      message: 'AP-1 is offline',
      roomId: 'north-tower-101',  // > 10 chars
    ),
  );
  
  testScenario('Dev: Short room ID',
    AppNotification(
      id: 'notif-2',
      title: 'Device Offline',
      message: 'AP-2 is offline',
      roomId: 'NT-101',  // <= 10 chars
    ),
  );
  
  testScenario('Dev: No room ID',
    AppNotification(
      id: 'notif-3',
      title: 'Device Offline',
      message: 'AP-3 is offline',
      roomId: null,
    ),
  );
  
  // Staging scenarios
  print('\n--- STAGING (API/Generated) ---');
  
  // From NotificationGenerationService: roomId = device.location
  // But what format is device.location in staging?
  testScenario('Staging: Numeric room ID',
    AppNotification(
      id: 'notif-4',
      title: 'Device Offline',
      message: 'AP-4 is offline',
      roomId: '101',  // Numeric
    ),
  );
  
  testScenario('Staging: Empty room ID',
    AppNotification(
      id: 'notif-5',
      title: 'Device Offline',
      message: 'AP-5 is offline',
      roomId: '',  // Empty string
    ),
  );
  
  testScenario('Staging: Null room ID',
    AppNotification(
      id: 'notif-6',
      title: 'Device Offline',
      message: 'AP-6 is offline',
      roomId: null,
    ),
  );
  
  print('\n' + '=' * 80);
  print('POTENTIAL ISSUES');
  print('=' * 80);
  
  print('\n1. Room ID Format Difference:');
  print('   - Development: "north-tower-101" (text, > 10 chars)');
  print('   - Staging: might be "101" (numeric) or empty/null');
  print('   Result: Different separators and truncation');
  
  print('\n2. Device Location Field:');
  print('   - MockDataService sets device.location to room ID string');
  print('   - API might return different format or empty');
  print('   - NotificationGenerationService uses device.location as roomId');
  
  print('\n3. Title Differences:');
  print('   - Dev: "Device Offline - north-towe..."');
  print('   - Staging: "Device Offline 101" or just "Device Offline"');
  
  print('\n' + '=' * 80);
  print('KEY INSIGHT');
  print('=' * 80);
  print('\nThe display difference depends on:');
  print('1. What value is in device.location');
  print('2. Whether it\'s numeric or text');
  print('3. Whether it\'s > 10 characters');
}