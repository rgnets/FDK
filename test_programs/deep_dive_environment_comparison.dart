#!/usr/bin/env dart

// Deep dive: Compare device data between staging and development

import 'dart:convert';

void main() {
  print('DEEP DIVE: ENVIRONMENT COMPARISON');
  print('Analyzing device data flow in both environments');
  print('=' * 80);
  
  analyzeDeviceDataFlow();
  compareEnvironmentPaths();
  identifyDataSources();
  generateTestPlan();
}

void analyzeDeviceDataFlow() {
  print('\n1. DEVICE DATA FLOW ANALYSIS');
  print('-' * 50);
  
  print('DEVELOPMENT ENVIRONMENT:');
  print('''
  1. AppConfig.isDevelopment == true
  2. DeviceRepository.getDevices() called
  3. Checks environment → uses MockDeviceDataSource
  4. MockDeviceDataSource.getDevices():
     a. Gets JSON from MockDataService (NEW after our changes)
     b. Parses JSON through Device.fromAccessPointJson() etc.
  5. Device entities have location from pms_room.name
  6. NotificationGenerationService uses device.location
  7. Notifications show location in UI ✓
  ''');
  
  print('\nSTAGING ENVIRONMENT:');
  print('''
  1. AppConfig.isDevelopment == false
  2. DeviceRepository.getDevices() called
  3. Checks environment → uses RemoteDeviceDataSource
  4. RemoteDeviceDataSource.getDevices():
     a. Fetches from API endpoints
     b. Parses JSON through SAME Device.fromAccessPointJson() etc.
  5. Device entities should have location from pms_room.name
  6. NotificationGenerationService uses device.location
  7. Notifications DON'T show location in UI ✗
  ''');
  
  print('\nKEY INSIGHT:');
  print('  Both use SAME parsing code (Device.fromAccessPointJson)');
  print('  Difference must be in JSON structure from API');
}

void compareEnvironmentPaths() {
  print('\n2. ENVIRONMENT PATH COMPARISON');
  print('-' * 50);
  
  print('CODE PATH VERIFICATION:');
  
  print('\n// device_repository.dart (simplified)');
  print('''
  Future<Either<Failure, List<Device>>> getDevices() async {
    if (AppConfig.isDevelopment) {
      return mockDataSource.getDevices();  // Development
    } else {
      return remoteDataSource.getDevices(); // Staging/Production
    }
  }
  ''');
  
  print('\n// mock_device_data_source.dart');
  print('''
  Future<List<DeviceModel>> getDevices() async {
    // After our changes, should get JSON and parse
    final apJson = MockDataService().getMockAccessPointsJson();
    final devices = [];
    for (final json in apJson['results']) {
      devices.add(Device.fromAccessPointJson(json));
    }
    return devices;
  }
  ''');
  
  print('\n// remote_device_data_source.dart');
  print('''
  Future<List<DeviceModel>> getDevices() async {
    // Fetch from real API
    final apResponse = await http.get('/api/access_points.json');
    final apJson = jsonDecode(apResponse.body);
    final devices = [];
    for (final json in apJson['results']) {
      devices.add(Device.fromAccessPointJson(json));
    }
    return devices;
  }
  ''');
  
  print('\nCRITICAL QUESTION:');
  print('  Are both data sources using Device.fromAccessPointJson()?');
  print('  Or is one creating Device entities differently?');
}

void identifyDataSources() {
  print('\n3. DATA SOURCE IDENTIFICATION');
  print('-' * 50);
  
  print('NEED TO CHECK:');
  
  print('\n1. MockDeviceDataSource implementation:');
  print('   - Does it return JSON that gets parsed?');
  print('   - Or does it create Device entities directly?');
  
  print('\n2. RemoteDeviceDataSource implementation:');
  print('   - How does it parse API responses?');
  print('   - Does it use Device.fromJson factories?');
  
  print('\n3. Device.fromAccessPointJson location extraction:');
  print('''
  // Current implementation (line 58):
  pmsRoomName = pmsRoom['name']?.toString();
  
  // Then (line 69):
  location: pmsRoomName ?? json['room']?.toString() ?? json['location']?.toString(),
  ''');
  
  print('\n4. Staging API response structure:');
  print('   - Does it have pms_room.name field?');
  print('   - Is pms_room null or missing?');
  print('   - Different field names?');
}

void generateTestPlan() {
  print('\n4. TEST PLAN');
  print('-' * 50);
  
  print('TESTS TO RUN:');
  
  print('\n1. Check MockDeviceDataSource:');
  print('   grep -n "class MockDeviceDataSource" lib/');
  print('   → See how it creates devices');
  
  print('\n2. Check RemoteDeviceDataSource:');
  print('   grep -n "class RemoteDeviceDataSource" lib/');
  print('   → See how it parses API responses');
  
  print('\n3. Create staging API test script:');
  print('   → Test actual API responses');
  print('   → Check pms_room structure');
  
  print('\n4. Add logging to Device factories:');
  print('   → Log json["pms_room"] value');
  print('   → Log extracted location');
  print('   → Compare dev vs staging');
  
  print('\n5. Check if MockDataService is used correctly:');
  print('   → After our JSON changes');
  print('   → Should return JSON, not entities');
  
  print('\n✅ NEXT STEPS:');
  print('   1. Find and analyze data source implementations');
  print('   2. Create API test scripts');
  print('   3. Add temporary logging');
}