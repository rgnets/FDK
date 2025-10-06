#!/usr/bin/env dart

/// Analyze what causes "three lines vs two lines" display difference
void main() {
  print('DISPLAY LINES ANALYSIS');
  print('=' * 80);
  
  print('\nPOSSIBLE INTERPRETATIONS OF "THREE LINES VS TWO LINES":');
  
  print('\n1. In Notifications Screen:');
  print('   Line 1: Title with location (e.g., "(North Tower) 205 Device Offline")');
  print('   Line 2: Message line 1 (e.g., "AP-Room1000-A is offline")');
  print('   Line 3: Message line 2 (if message wraps)');
  
  print('\n2. Device Names Difference:');
  print('   Mock: "AP-Room1000-A" (longer, might wrap)');
  print('   Staging: "AP-WE-801" (shorter, fits on one line)');
  
  print('\n3. The ACTUAL issue might be:');
  print('   Mock device names use format: "AP-Room{roomId}{suffix}"');
  print('   Where roomId is 1000+ (4 digits), making names longer');
  print('   Staging might use shorter names like "AP-WE-801"');
  
  print('\nLet\'s check mock device name generation...');
  
  // From mock_data_service.dart line 288
  final mockRoomId = '1000'; // Starting at 1000
  final mockApName = 'AP-Room$mockRoomId-A';
  print('\nMock AP name: "$mockApName" (${mockApName.length} chars)');
  
  // Staging format from Python test
  final stagingApName = 'AP-WE-801';
  print('Staging AP name: "$stagingApName" (${stagingApName.length} chars)');
  
  print('\nDifference: ${mockApName.length - stagingApName.length} characters');
  
  print('\nTHE REAL ISSUE:');
  print('Mock uses room IDs starting at 1000 (4 digits)');
  print('This makes device names longer: "AP-Room1000" vs "AP-WE-801"');
  print('The extra length causes text wrapping in the UI!');
  
  print('\nSOLUTION:');
  print('1. Keep room IDs but change device naming convention');
  print('2. Use building prefix + room number like staging');
  print('3. Example: "AP-NT-205" instead of "AP-Room1000"');
}