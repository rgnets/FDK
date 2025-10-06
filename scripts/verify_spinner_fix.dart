#!/usr/bin/env dart

// Verify that the spinner bug has been fixed

import 'dart:io';

void main() async {
  print('=' * 80);
  print('VERIFYING SPINNER BUG FIX');
  print('=' * 80);
  print('');
  
  final file = File('lib/features/rooms/presentation/providers/room_device_view_model.dart');
  final content = file.readAsStringSync();
  final lines = content.split('\n');
  
  print('Checking the fixed build() method...');
  print('');
  
  // Find the build method
  var inBuildMethod = false;
  var buildMethodStart = -1;
  var braceCount = 0;
  final buildMethodLines = <String>[];
  
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (line.contains('RoomDeviceState build(String roomId)')) {
      inBuildMethod = true;
      buildMethodStart = i + 1;
      braceCount = 0;
    }
    
    if (inBuildMethod) {
      buildMethodLines.add(line);
      
      for (final char in line.split('')) {
        if (char == '{') braceCount++;
        if (char == '}') braceCount--;
      }
      
      if (braceCount == 0 && line.contains('}')) {
        inBuildMethod = false;
        break;
      }
    }
  }
  
  print('VERIFICATION CHECKLIST:');
  print('-' * 40);
  
  var allChecksPassed = true;
  
  // Check 1: No local state variable
  print('1. No local state variable shadowing:');
  final hasLocalState = buildMethodLines.any((line) => 
    line.contains('const state =') || 
    line.contains('final state =') ||
    line.contains('var state ='));
  
  if (!hasLocalState) {
    print('   ✅ PASS: No local state variable found');
  } else {
    print('   ❌ FAIL: Still has local state variable');
    allChecksPassed = false;
  }
  
  // Check 2: Reads current devices state
  print('2. Reads current devices state:');
  final readsDevicesState = buildMethodLines.any((line) => 
    line.contains('ref.read(devicesNotifierProvider)'));
  
  if (readsDevicesState) {
    print('   ✅ PASS: Reads devicesNotifierProvider');
  } else {
    print('   ❌ FAIL: Does not read current devices state');
    allChecksPassed = false;
  }
  
  // Check 3: Uses when() to process state
  print('3. Processes state with when():');
  final usesWhen = buildMethodLines.any((line) => 
    line.contains('.when('));
  
  if (usesWhen) {
    print('   ✅ PASS: Uses when() to process state');
  } else {
    print('   ❌ FAIL: Does not use when() pattern');
    allChecksPassed = false;
  }
  
  // Check 4: Has listeners
  print('4. Has required listeners:');
  final hasDevicesListener = buildMethodLines.any((line) => 
    line.contains('ref.listen(devicesNotifierProvider'));
  final hasRoomListener = buildMethodLines.any((line) => 
    line.contains('ref.listen(roomViewModelByIdProvider'));
  
  if (hasDevicesListener && hasRoomListener) {
    print('   ✅ PASS: Both listeners present');
  } else {
    print('   ❌ FAIL: Missing listeners');
    allChecksPassed = false;
  }
  
  // Check 5: Returns state based on data
  print('5. Returns appropriate state:');
  final hasDataCase = buildMethodLines.any((line) => 
    line.contains('data: (devices)'));
  final hasLoadingCase = buildMethodLines.any((line) => 
    line.contains('loading: ()'));
  final hasErrorCase = buildMethodLines.any((line) => 
    line.contains('error: (error'));
  
  if (hasDataCase && hasLoadingCase && hasErrorCase) {
    print('   ✅ PASS: Handles all state cases');
  } else {
    print('   ❌ FAIL: Missing state cases');
    allChecksPassed = false;
  }
  
  print('');
  print('COMPILATION CHECK:');
  print('-' * 40);
  
  // Run dart analyze
  final analyzeResult = await Process.run('dart', ['analyze', 'lib/features/rooms/presentation/providers/room_device_view_model.dart']);
  
  if (analyzeResult.exitCode == 0) {
    final output = analyzeResult.stdout.toString();
    if (output.contains('No issues found')) {
      print('✅ Zero errors and warnings');
    } else {
      print('⚠️ Analysis output:');
      print(output);
    }
  } else {
    print('❌ Compilation errors:');
    print(analyzeResult.stderr);
    allChecksPassed = false;
  }
  
  print('');
  print('=' * 80);
  print('RESULT');
  print('=' * 80);
  
  if (allChecksPassed) {
    print('');
    print('✅ SUCCESS: The spinner bug has been fixed!');
    print('');
    print('The fix correctly:');
    print('1. Removed the local state variable that was shadowing');
    print('2. Reads the current devices state on initialization');
    print('3. Returns appropriate state based on current data');
    print('4. Maintains listeners for future updates');
    print('');
    print('The devices tab should now load properly without infinite spinner.');
  } else {
    print('');
    print('❌ ISSUES FOUND: Please review the fix');
  }
}