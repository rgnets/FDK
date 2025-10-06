#!/usr/bin/env dart

// Test script to verify if Riverpod providers are properly generated
// and identify compilation issues

import 'dart:io';

void main() {
  print('=' * 80);
  print('PROVIDER GENERATION TEST');
  print('=' * 80);
  
  checkGeneratedFiles();
  analyzeProviderAnnotations();
  checkBuildRunnerConfig();
  suggestFixes();
}

void checkGeneratedFiles() {
  print('\n1. CHECKING GENERATED FILES');
  print('-' * 40);
  
  final providersPath = 'lib/features/devices/presentation/providers';
  final expectedFiles = [
    'devices_provider.g.dart',
    'device_ui_state_provider.g.dart',
  ];
  
  print('Checking in $providersPath:');
  for (final file in expectedFiles) {
    final path = '$providersPath/$file';
    final exists = File(path).existsSync();
    final status = exists ? '✅' : '❌';
    print('  $status $file');
    
    if (!exists) {
      print('      MISSING: This will cause compilation errors!');
    }
  }
  
  // Check for part directives
  print('\n2. CHECKING PART DIRECTIVES');
  print('-' * 40);
  
  final sourceFiles = [
    '$providersPath/devices_provider.dart',
    '$providersPath/device_ui_state_provider.dart',
  ];
  
  for (final file in sourceFiles) {
    if (File(file).existsSync()) {
      final content = File(file).readAsStringSync();
      final fileName = file.split('/').last;
      final genFileName = fileName.replaceAll('.dart', '.g.dart');
      
      if (content.contains("part '$genFileName'")) {
        print('✅ $fileName has correct part directive');
      } else {
        print('❌ $fileName missing part directive for $genFileName');
      }
      
      // Check for @riverpod annotations
      if (content.contains('@riverpod') || content.contains('@Riverpod')) {
        print('  ✓ Has Riverpod annotations');
      } else {
        print('  ✗ No Riverpod annotations found');
      }
    }
  }
}

void analyzeProviderAnnotations() {
  print('\n3. PROVIDER ANNOTATION ANALYSIS');
  print('-' * 40);
  
  print('Expected providers in devices_provider.dart:');
  print('  @Riverpod(keepAlive: true)');
  print('  class DevicesNotifier extends _\$DevicesNotifier');
  print('    - Should generate: devicesNotifierProvider');
  print('');
  print('  @Riverpod(keepAlive: true)');
  print('  class DeviceNotifier extends _\$DeviceNotifier');
  print('    - Should generate: deviceNotifierProvider');
  print('');
  print('  @Riverpod(keepAlive: true)');
  print('  class DeviceSearchNotifier extends _\$DeviceSearchNotifier');
  print('    - Should generate: deviceSearchNotifierProvider');
  
  print('\nExpected providers in device_ui_state_provider.dart:');
  print('  @riverpod');
  print('  class DeviceUIStateNotifier extends _\$DeviceUIStateNotifier');
  print('    - Should generate: deviceUIStateNotifierProvider');
  print('');
  print('  @riverpod');
  print('  List<Device> filteredDevicesList(ref)');
  print('    - Should generate: filteredDevicesListProvider');
  print('');
  print('  @riverpod');
  print('  DeviceStatistics deviceStatistics(ref)');
  print('    - Should generate: deviceStatisticsProvider');
}

void checkBuildRunnerConfig() {
  print('\n4. BUILD RUNNER CONFIGURATION');
  print('-' * 40);
  
  // Check pubspec.yaml
  if (File('pubspec.yaml').existsSync()) {
    final content = File('pubspec.yaml').readAsStringSync();
    
    print('Checking pubspec.yaml dependencies:');
    
    if (content.contains('riverpod_annotation:')) {
      print('  ✅ riverpod_annotation found');
    } else {
      print('  ❌ riverpod_annotation NOT found');
    }
    
    if (content.contains('riverpod_generator:')) {
      print('  ✅ riverpod_generator found');
    } else {
      print('  ❌ riverpod_generator NOT found');
    }
    
    if (content.contains('build_runner:')) {
      print('  ✅ build_runner found');
    } else {
      print('  ❌ build_runner NOT found');
    }
  }
  
  // Check build.yaml
  if (File('build.yaml').existsSync()) {
    print('\n✅ build.yaml exists');
  } else {
    print('\n⚠️ build.yaml not found (may use defaults)');
  }
}

void suggestFixes() {
  print('\n5. SUGGESTED FIXES');
  print('-' * 40);
  
  print('STEP 1: Ensure dependencies are installed');
  print('  flutter pub get');
  print('');
  
  print('STEP 2: Generate missing files');
  print('  dart run build_runner build --delete-conflicting-outputs');
  print('');
  
  print('STEP 3: If generation fails, check for errors:');
  print('  - Syntax errors in provider classes');
  print('  - Missing imports');
  print('  - Incorrect annotation usage');
  print('');
  
  print('STEP 4: Watch for changes during development');
  print('  dart run build_runner watch');
  print('');
  
  print('COMMON ISSUES:');
  print('  1. Using @riverpod instead of @Riverpod for classes');
  print('  2. Not extending _\$ClassName for notifiers');
  print('  3. Missing part directive in source file');
  print('  4. Incorrect file naming conventions');
  print('  5. Build runner cache issues (use --delete-conflicting-outputs)');
}