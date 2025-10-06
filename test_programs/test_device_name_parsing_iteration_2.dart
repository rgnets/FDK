#!/usr/bin/env dart

// Test Iteration 2: Verify device name parsing approach

class Device {
  final String name;
  final String? location;
  
  Device({required this.name, this.location});
}

String? extractRoomFromDeviceName(String deviceName) {
  // Common patterns in device names:
  // "AP-NT-101-1" -> "NT-101"
  // "ONT-ST-201-1" -> "ST-201"
  // "SW-EW-301" -> "EW-301"
  // "WLAN-WW-401-2" -> "WW-401"
  
  // Split by hyphen
  final parts = deviceName.split('-');
  
  if (parts.length >= 3) {
    // Extract building code and room number
    // Skip the device type prefix (AP, ONT, SW, WLAN)
    final building = parts[1]; // NT, ST, EW, WW
    final roomNumber = parts[2]; // 101, 201, 301
    
    // Return formatted room
    return '$building-$roomNumber';
  }
  
  // Fallback: return null if pattern doesn't match
  return null;
}

void testDeviceNameParsing() {
  print('DEVICE NAME PARSING TEST');
  print('=' * 80);
  
  final testCases = [
    // Development mock devices
    Device(name: 'AP-NT-101-1', location: 'north-tower-101'),
    Device(name: 'AP-NT-101-2', location: 'north-tower-101'),
    Device(name: 'ONT-NT-101-1', location: 'north-tower-101'),
    Device(name: 'SW-NT-101', location: 'north-tower-101'),
    
    // Other building examples
    Device(name: 'AP-ST-201-1', location: 'south-tower-201'),
    Device(name: 'ONT-EW-301-1', location: 'east-wing-301'),
    Device(name: 'WLAN-WW-401-2', location: 'west-wing-401'),
    Device(name: 'SW-CH-101', location: 'central-hub-101'),
    
    // Edge cases
    Device(name: 'AP-1', location: null), // Short name
    Device(name: 'Device', location: null), // No pattern
    Device(name: 'AP_NT_101_1', location: null), // Underscores instead
  ];
  
  for (final device in testCases) {
    final extractedRoom = extractRoomFromDeviceName(device.name);
    print('\nDevice: ${device.name}');
    print('  Current location: ${device.location ?? "null"}');
    print('  Extracted room: ${extractedRoom ?? "null"}');
    print('  Match: ${extractedRoom != null ? "✓" : "✗"}');
  }
}

void testNotificationDisplay() {
  print('\n' + '=' * 80);
  print('NOTIFICATION DISPLAY WITH PARSED ROOM');
  print('=' * 80);
  
  // Simulate notification title formatting with parsed room
  String formatNotificationTitle(String baseTitle, String? roomId) {
    if (roomId != null && roomId.isNotEmpty) {
      // Consistent format: always use dash separator
      // Room is already in short format (e.g., "NT-101")
      return '$baseTitle - $roomId';
    }
    return baseTitle;
  }
  
  final scenarios = [
    ('Device Offline', 'NT-101'),
    ('Device Offline', 'ST-201'),
    ('Device Has Note', 'EW-301'),
    ('Missing Images', 'WW-401'),
    ('Device Offline', null),
  ];
  
  print('\nFormatted titles:');
  for (final (title, room) in scenarios) {
    final formatted = formatNotificationTitle(title, room);
    print('  $formatted');
  }
}

void analyzeImplementation() {
  print('\n' + '=' * 80);
  print('IMPLEMENTATION ANALYSIS');
  print('=' * 80);
  
  print('\n1. CHANGES NEEDED:');
  print('   • Modify NotificationGenerationService._generateDeviceNotifications');
  print('   • Add room extraction logic');
  print('   • Store extracted room instead of device.location');
  
  print('\n2. CODE LOCATION:');
  print('   File: /lib/core/services/notification_generation_service.dart');
  print('   Lines: 83 (roomId field in notification creation)');
  
  print('\n3. BENEFITS:');
  print('   • No architectural changes');
  print('   • No new dependencies');
  print('   • Works with existing data');
  print('   • Consistent across environments');
  
  print('\n4. RISKS:');
  print('   • Depends on device naming convention');
  print('   • May not work for all device types');
  print('   • Need fallback for non-standard names');
  
  print('\n5. FALLBACK STRATEGY:');
  print('   • If parsing fails, use device.location as before');
  print('   • Ensures backward compatibility');
  print('   • Handles edge cases gracefully');
}

void main() {
  testDeviceNameParsing();
  testNotificationDisplay();
  analyzeImplementation();
  
  print('\n' + '=' * 80);
  print('CONCLUSION');
  print('=' * 80);
  print('\nDevice name parsing is a viable solution that:');
  print('  1. Maintains Clean Architecture principles');
  print('  2. Works with existing data flow');
  print('  3. Provides consistent room display');
  print('  4. Requires minimal code changes');
  print('  5. No replicated code paths');
}