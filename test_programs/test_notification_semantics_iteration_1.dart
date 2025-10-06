#!/usr/bin/env dart

// Test Iteration 1: Analyze notification field semantics

class Device {
  final String id;
  final String name;
  final int? pmsRoomId;      // Should be the room ID number (e.g., 12)
  final String? location;     // Should be the room name/location (e.g., "(Interurban) 007")
  
  Device({
    required this.id,
    required this.name,
    this.pmsRoomId,
    this.location,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? roomId;       // Currently stores device.location
  final Map<String, dynamic>? metadata;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.roomId,
    this.metadata,
  });
}

void analyzeCurrentImplementation() {
  print('CURRENT IMPLEMENTATION ANALYSIS');
  print('=' * 80);
  
  print('\n1. NotificationGenerationService (line 83):');
  print('   Sets: roomId: device.location');
  print('   Problem: "roomId" field contains location string, not ID');
  
  print('\n2. NotificationsScreen _formatNotificationTitle:');
  print('   Uses: notification.roomId for display');
  print('   Expects: A string to concatenate with title');
  
  print('\n3. Semantic Issue:');
  print('   - "roomId" implies an identifier (number)');
  print('   - But it contains location (string)');
  print('   - This is semantically incorrect');
}

void analyzeApiData() {
  print('\n' + '=' * 80);
  print('API DATA STRUCTURE');
  print('=' * 80);
  
  print('\nFrom API analysis:');
  print('  pms_room: {');
  print('    "id": 12,              // The actual room ID');
  print('    "name": "(Interurban) 007"  // The room location/name');
  print('  }');
  
  print('\nCorrect mapping should be:');
  print('  device.pmsRoomId = pms_room.id     // 12');
  print('  device.location = pms_room.name    // "(Interurban) 007"');
}

void proposeSolution() {
  print('\n' + '=' * 80);
  print('PROPOSED SOLUTION');
  print('=' * 80);
  
  print('\nOption 1: Use location field in notification (SEMANTICALLY CORRECT)');
  print('  Change NotificationGenerationService:');
  print('    FROM: roomId: device.location');
  print('    TO:   location: device.location  // Add new field');
  print('    OR:   roomId: device.pmsRoomId   // Use actual ID');
  print('          location: device.location  // Add location field');
  print('');
  print('  Change NotificationsScreen:');
  print('    FROM: final roomId = notification.roomId;');
  print('          return \$baseTitle - \$roomId');
  print('    TO:   final location = notification.location;');
  print('          return \$baseTitle - \$location');
  
  print('\nOption 2: Keep using roomId but understand it contains location');
  print('  No code changes needed');
  print('  Just acknowledge that roomId is misnamed');
  print('  It actually contains the location string');
}

void testDisplayScenarios() {
  print('\n' + '=' * 80);
  print('DISPLAY SCENARIOS');
  print('=' * 80);
  
  // Test with different data
  final scenarios = [
    ('With API data', 12, '(Interurban) 007'),
    ('With mock data', 101, 'North Tower 101'),
    ('No room', null, null),
  ];
  
  for (final (scenario, roomId, location) in scenarios) {
    print('\n$scenario:');
    print('  pmsRoomId: $roomId');
    print('  location: $location');
    print('  Display options:');
    print('    Using roomId: "Device Offline - $roomId"  // Shows number');
    print('    Using location: "Device Offline - $location"  // Shows name');
    print('  Better display: Using location (shows meaningful name)');
  }
}

void verifyArchitecture() {
  print('\n' + '=' * 80);
  print('ARCHITECTURAL COMPLIANCE');
  print('=' * 80);
  
  print('\nClean Architecture:');
  print('  ✓ Domain entities should have clear, semantic fields');
  print('  ✓ roomId should be an ID, location should be a location');
  print('  ✓ Presentation layer formats for display');
  
  print('\nMVVM:');
  print('  ✓ Model represents data correctly');
  print('  ✓ View displays formatted data');
  print('  ✓ ViewModel transforms as needed');
  
  print('\nSingle Responsibility:');
  print('  ✓ Each field has one clear purpose');
  print('  ✓ No ambiguity in field meanings');
}

void main() {
  analyzeCurrentImplementation();
  analyzeApiData();
  proposeSolution();
  testDisplayScenarios();
  verifyArchitecture();
  
  print('\n' + '=' * 80);
  print('CONCLUSION');
  print('=' * 80);
  print('\nYou are correct:');
  print('  1. roomId should contain the ID (number)');
  print('  2. location should contain the name/location');
  print('  3. Display should use: \$baseTitle - \$location');
  print('\nThis is semantically correct and architecturally sound.');
}