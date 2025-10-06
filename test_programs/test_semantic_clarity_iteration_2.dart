#!/usr/bin/env dart

// Test Iteration 2: Semantic clarity analysis - Fixed

// Option A: Separate fields
class NotificationWithBothFields {
  final int? roomId;
  final String? location;
  
  NotificationWithBothFields({this.roomId, this.location});
  
  String format(String title) {
    if (location != null && location!.isNotEmpty) {
      return '$title - $location';
    }
    return title;
  }
}

// Option B: Single location field
class NotificationWithLocation {
  final String? location;
  
  NotificationWithLocation({this.location});
  
  String format(String title) {
    if (location != null && location!.isNotEmpty) {
      return '$title - $location';
    }
    return title;
  }
}

// Current (wrong) implementation
class NotificationWithMisnamedField {
  final String? roomId;  // Contains location, not ID!
  
  NotificationWithMisnamedField({this.roomId});
  
  String format(String title) {
    if (roomId != null && roomId!.isNotEmpty) {
      return '$title - $roomId';
    }
    return title;
  }
}

void main() {
  print('SEMANTIC CLARITY ANALYSIS - ITERATION 2');
  print('=' * 80);
  
  print('\nTHE PROBLEM:');
  print('  Current: notification.roomId = device.location');
  print('  Issue: Field named "roomId" contains a location string');
  print('  This violates Clean Architecture semantic clarity');
  
  print('\n' + '=' * 80);
  print('CURRENT (WRONG) IMPLEMENTATION');
  print('=' * 80);
  
  final wrong1 = NotificationWithMisnamedField(roomId: '(Interurban) 007');
  final wrong2 = NotificationWithMisnamedField(roomId: null);
  
  print('Field name: roomId (but contains location!)');
  print('With data: "${wrong1.format("Device Offline")}"');
  print('No data: "${wrong2.format("Device Offline")}"');
  print('❌ Semantically incorrect - roomId should be a number');
  
  print('\n' + '=' * 80);
  print('OPTION A: BOTH FIELDS (Most Complete)');
  print('=' * 80);
  
  final optionA1 = NotificationWithBothFields(
    roomId: 12, 
    location: '(Interurban) 007'
  );
  final optionA2 = NotificationWithBothFields(
    roomId: null, 
    location: null
  );
  
  print('Fields: roomId (int) AND location (String)');
  print('With data: "${optionA1.format("Device Offline")}"');
  print('No data: "${optionA2.format("Device Offline")}"');
  print('✓ Semantically correct');
  print('✓ Preserves both ID and name');
  
  print('\n' + '=' * 80);
  print('OPTION B: LOCATION ONLY (Simpler)');
  print('=' * 80);
  
  final optionB1 = NotificationWithLocation(location: '(Interurban) 007');
  final optionB2 = NotificationWithLocation(location: null);
  
  print('Field: location (String)');
  print('With data: "${optionB1.format("Device Offline")}"');
  print('No data: "${optionB2.format("Device Offline")}"');
  print('✓ Semantically correct');
  print('✓ Simple and clear');
  
  print('\n' + '=' * 80);
  print('DATA FLOW ANALYSIS');
  print('=' * 80);
  
  print('\nAPI provides:');
  print('  pms_room: {');
  print('    "id": 12,');
  print('    "name": "(Interurban) 007"');
  print('  }');
  
  print('\nDevice entity should have:');
  print('  pmsRoomId: 12              // from pms_room.id');
  print('  location: "(Interurban) 007"  // from pms_room.name');
  
  print('\nNotification should have:');
  print('  Option A: roomId: 12, location: "(Interurban) 007"');
  print('  Option B: location: "(Interurban) 007"');
  
  print('\nDisplay uses:');
  print('  return "\$baseTitle - \$location"');
  
  print('\n' + '=' * 80);
  print('ARCHITECTURAL COMPLIANCE');
  print('=' * 80);
  
  print('\n✓ CLEAN ARCHITECTURE:');
  print('  - Clear semantic naming');
  print('  - Single responsibility');
  print('  - No ambiguity');
  
  print('\n✓ MVVM:');
  print('  - Model represents data accurately');
  print('  - View uses correct fields');
  
  print('\n✓ DEPENDENCY INJECTION:');
  print('  - No impact');
  
  print('\n✓ RIVERPOD:');
  print('  - State management unchanged');
  
  print('\n✓ GO_ROUTER:');
  print('  - No routing impact');
  
  print('\n' + '=' * 80);
  print('RECOMMENDATION');
  print('=' * 80);
  
  print('\nYOU ARE CORRECT!');
  print('\nThe notification should have a "location" field, not misuse "roomId".');
  print('\nImplementation steps:');
  print('  1. Add location field to AppNotification entity');
  print('  2. Update NotificationGenerationService to set location');
  print('  3. Update NotificationsScreen to use notification.location');
  print('  4. Display: return "\$baseTitle - \$location"');
  
  print('\nThis ensures semantic clarity and architectural correctness.');
}