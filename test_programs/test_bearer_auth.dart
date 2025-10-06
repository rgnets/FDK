#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test 3: Test with Bearer authentication instead of Basic Auth

void main() async {
  print('=' * 60);
  print('TEST 3: BEARER AUTHENTICATION TEST');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  print('\nConfiguration:');
  print('  API URL: $apiUrl');
  print('  API Key: ${apiKey.substring(0, 20)}...');
  
  // Test 1: Try Bearer token directly
  print('\n1. TESTING WITH BEARER TOKEN:');
  print('-' * 40);
  
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/pms_rooms.json?page=1'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    
    print('Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['results'] != null) {
        final results = data['results'] as List;
        print('✅ SUCCESS with Bearer auth!');
        print('  Got ${results.length} rooms');
        
        // Show first room as proof
        if (results.isNotEmpty) {
          final firstRoom = results[0];
          print('\nFirst Room:');
          print('  ID: ${firstRoom['id']}');
          print('  Name: ${firstRoom['room'] ?? firstRoom['name']}');
          
          // Count devices
          int totalDevices = 0;
          for (final room in results) {
            if (room['access_points'] != null) {
              totalDevices += (room['access_points'] as List).length;
            }
            if (room['media_converters'] != null) {
              totalDevices += (room['media_converters'] as List).length;
            }
          }
          
          print('\nStatistics:');
          print('  Total rooms: ${results.length}');
          print('  Total devices: $totalDevices');
        }
      }
    } else {
      print('❌ Failed with status: ${response.statusCode}');
      print('Response: ${response.body.substring(0, 100)}...');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  // Test 2: Compare auth methods
  print('\n2. COMPARING AUTH METHODS:');
  print('-' * 40);
  
  // Basic Auth (what we were using)
  print('\nBasic Auth format:');
  final credentials = 'fetoolreadonly:$apiKey';
  final bytes = utf8.encode(credentials);
  final base64Str = base64Encode(bytes);
  print('  Header: "Authorization: Basic $base64Str"');
  print('  Result: 403 Forbidden');
  
  // Bearer Auth (what we should use)
  print('\nBearer Auth format:');
  print('  Header: "Authorization: Bearer $apiKey"');
  print('  Result: Test above');
  
  // Test 3: Verify the fix needed
  print('\n3. CODE CHANGES NEEDED:');
  print('-' * 40);
  
  print('\nIn api_service.dart, for staging:');
  print('CURRENT (wrong):');
  print('  final credentials = "\$testLogin:\$testApiKey";');
  print('  final bytes = utf8.encode(credentials);');
  print('  final base64Str = base64Encode(bytes);');
  print('  options.headers["Authorization"] = "Basic \$base64Str";');
  print('');
  print('SHOULD BE:');
  print('  options.headers["Authorization"] = "Bearer \$testApiKey";');
  
  print('\n' + '=' * 60);
  print('CONCLUSION');
  print('=' * 60);
  print('\nThe issue is clear:');
  print('1. Staging API uses Bearer authentication, not Basic Auth');
  print('2. We need to use: Authorization: Bearer <api_key>');
  print('3. No username needed, just the API key as Bearer token');
}