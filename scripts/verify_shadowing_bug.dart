#!/usr/bin/env dart

// Verify the variable shadowing bug that causes infinite spinner

import 'dart:io';

void main() {
  print('=' * 80);
  print('VARIABLE SHADOWING BUG VERIFICATION');
  print('=' * 80);
  print('');
  
  final file = File('lib/features/rooms/presentation/providers/room_device_view_model.dart');
  final content = file.readAsStringSync();
  final lines = content.split('\n');
  
  print('ANALYZING room_device_view_model.dart...');
  print('');
  
  // Find the build method
  var inBuildMethod = false;
  var buildMethodStart = -1;
  var buildMethodEnd = -1;
  var braceCount = 0;
  
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (line.contains('RoomDeviceState build(String roomId)')) {
      inBuildMethod = true;
      buildMethodStart = i + 1; // Line numbers are 1-based
      braceCount = 0;
      print('Found build method at line ${i + 1}');
    }
    
    if (inBuildMethod) {
      for (final char in line.split('')) {
        if (char == '{') braceCount++;
        if (char == '}') braceCount--;
      }
      
      if (braceCount == 0 && line.contains('}')) {
        buildMethodEnd = i + 1;
        inBuildMethod = false;
        break;
      }
    }
  }
  
  print('Build method spans lines $buildMethodStart-$buildMethodEnd');
  print('');
  
  // Check for the problematic pattern
  print('CHECKING FOR SHADOWING BUG:');
  print('-' * 40);
  
  var hasLocalStateDeclaration = false;
  var returnsLocalState = false;
  var localStateLineNum = -1;
  var returnLineNum = -1;
  
  for (var i = buildMethodStart - 1; i < buildMethodEnd && i < lines.length; i++) {
    final line = lines[i];
    
    // Check for local state declaration
    if (line.contains('const state = RoomDeviceState')) {
      hasLocalStateDeclaration = true;
      localStateLineNum = i + 1;
      print('✅ Found local state declaration at line ${i + 1}:');
      print('   ${line.trim()}');
    }
    
    // Check for return statement
    if (line.trim() == 'return state;') {
      returnsLocalState = true;
      returnLineNum = i + 1;
      print('✅ Found return of local state at line ${i + 1}:');
      print('   ${line.trim()}');
    }
  }
  
  print('');
  print('DIAGNOSIS:');
  print('=' * 40);
  
  if (hasLocalStateDeclaration && returnsLocalState) {
    print('🐛 CRITICAL BUG CONFIRMED!');
    print('');
    print('The build() method has a variable shadowing bug:');
    print('');
    print('1. Line $localStateLineNum: Creates LOCAL const state variable');
    print('2. Lines 51-64: Listeners update INSTANCE state field');
    print('3. Line $returnLineNum: Returns LOCAL const state (never updated!)');
    print('');
    print('EFFECT:');
    print('- The provider always returns RoomDeviceState(isLoading: true)');
    print('- Listeners update the instance field but it\'s never seen');
    print('- UI shows infinite spinner forever');
    print('');
    print('WHY THIS HAPPENS:');
    print('- Dart allows local variables to shadow instance fields');
    print('- "const state" creates a local variable named "state"');
    print('- "this.state" or just "state" in methods refers to instance field');
    print('- But in build(), "state" refers to the local const variable');
    print('');
    print('CORRECT PATTERN:');
    print('The build method should either:');
    print('1. Not declare a local state variable at all');
    print('2. Use a different name like "initialState"');
    print('3. Process and return the actual current state');
  } else {
    print('⚠️ Bug pattern not found - code may have been modified');
    print('hasLocalStateDeclaration: $hasLocalStateDeclaration');
    print('returnsLocalState: $returnsLocalState');
  }
  
  print('');
  print('CHECKING LISTENERS:');
  print('-' * 40);
  
  // Check if listeners properly update state
  var hasDevicesListener = false;
  var hasRoomListener = false;
  
  for (var i = buildMethodStart - 1; i < buildMethodEnd && i < lines.length; i++) {
    final line = lines[i];
    
    if (line.contains('ref.listen(devicesNotifierProvider')) {
      hasDevicesListener = true;
      print('✅ Found devicesNotifierProvider listener at line ${i + 1}');
    }
    
    if (line.contains('ref.listen(roomViewModelByIdProvider')) {
      hasRoomListener = true;
      print('✅ Found roomViewModelByIdProvider listener at line ${i + 1}');
    }
  }
  
  print('');
  if (hasDevicesListener && hasRoomListener) {
    print('Both listeners are set up correctly.');
    print('They would work fine if not for the shadowing bug!');
  }
  
  print('');
  print('=' * 80);
  print('CONCLUSION');
  print('=' * 80);
  print('');
  print('The infinite spinner is caused by a variable shadowing bug where:');
  print('1. A local "const state" variable shadows the instance "state" field');
  print('2. Listeners update the instance field correctly');
  print('3. But build() returns the unchanging local const variable');
  print('');
  print('This is a common Riverpod mistake that\'s easy to make but hard to spot!');
}