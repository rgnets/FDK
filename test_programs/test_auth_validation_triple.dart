#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Triple validation of the authentication issue

void main() async {
  print('=' * 60);
  print('TRIPLE VALIDATION OF AUTHENTICATION ISSUE');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const username = 'fetoolreadonly';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  // Test 1: Current implementation (Basic Auth) - should FAIL
  print('\nTEST 1: CURRENT IMPLEMENTATION (Basic Auth)');
  print('-' * 40);
  
  Future<bool> testBasicAuth() async {
    try {
      // This is what api_service.dart currently does
      final credentials = '$username:$apiKey';
      final bytes = utf8.encode(credentials);
      final base64Str = base64Encode(bytes);
      
      print('Creating header: Authorization: Basic ${base64Str.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$apiUrl/api/pms_rooms.json?page=1'),
        headers: {
          'Authorization': 'Basic $base64Str',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      print('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS - Basic Auth works');
        return true;
      } else {
        print('❌ FAILED - Status ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    }
  }
  
  final test1 = await testBasicAuth();
  
  // Test 2: Correct implementation (Bearer Auth) - should SUCCEED
  print('\nTEST 2: CORRECT IMPLEMENTATION (Bearer Auth)');
  print('-' * 40);
  
  Future<bool> testBearerAuth() async {
    try {
      // This is what it SHOULD do
      print('Creating header: Authorization: Bearer ${apiKey.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$apiUrl/api/pms_rooms.json?page=1'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      print('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        print('✅ SUCCESS - Bearer Auth works');
        print('   Got ${results?.length ?? 0} rooms');
        return true;
      } else {
        print('❌ FAILED - Status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    }
  }
  
  final test2 = await testBearerAuth();
  
  // Test 3: Mixed approach test - what if we need both?
  print('\nTEST 3: ALTERNATIVE TESTS');
  print('-' * 40);
  
  // Test 3a: X-API-Key header
  print('\n3a. Testing X-API-Key header:');
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/pms_rooms.json?page=1'),
      headers: {
        'X-API-Key': apiKey,
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 10));
    
    print('   Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('   ✅ X-API-Key works');
    } else {
      print('   ❌ X-API-Key failed');
    }
  } catch (e) {
    print('   ❌ Exception: $e');
  }
  
  // Test 3b: API key as query parameter
  print('\n3b. Testing API key as query parameter:');
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/pms_rooms.json?page=1&api_key=$apiKey'),
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 10));
    
    print('   Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('   ✅ Query parameter works');
    } else {
      print('   ❌ Query parameter failed');
    }
  } catch (e) {
    print('   ❌ Exception: $e');
  }
  
  // Summary
  print('\n' + '=' * 60);
  print('VALIDATION SUMMARY');
  print('=' * 60);
  
  print('\nResults:');
  print('  Test 1 (Basic Auth):  ${test1 ? "✅ PASS" : "❌ FAIL"}');
  print('  Test 2 (Bearer Auth): ${test2 ? "✅ PASS" : "❌ FAIL"}');
  
  print('\nCONCLUSION:');
  if (!test1 && test2) {
    print('✅ CONFIRMED: The issue is Basic Auth vs Bearer Auth');
    print('');
    print('The fix needed in api_service.dart line 51:');
    print('CURRENT:  options.headers["Authorization"] = "Basic \$base64Str";');
    print('SHOULD BE: options.headers["Authorization"] = "Bearer \$testApiKey";');
  } else if (test1 && test2) {
    print('⚠️ Both auth methods work - investigate further');
  } else if (!test1 && !test2) {
    print('❌ Neither auth method works - different issue');
  }
  
  // Code change simulation
  print('\n' + '=' * 60);
  print('PROPOSED CODE CHANGE');
  print('=' * 60);
  
  print('\nIn api_service.dart, lines 42-55:');
  print('');
  print('REPLACE:');
  print('```dart');
  print('if (EnvironmentConfig.isStaging) {');
  print('  // Staging uses Basic Auth  <-- WRONG COMMENT');
  print('  final testLogin = AppConfig.testCredentials["login"] ?? "fetoolreadonly";');
  print('  final testApiKey = AppConfig.testCredentials["apiKey"] ?? "";');
  print('  ');
  print('  if (testLogin.isNotEmpty && testApiKey.isNotEmpty) {');
  print('    // Create Basic Auth header  <-- WRONG');
  print('    final credentials = "\$testLogin:\$testApiKey";');
  print('    final bytes = utf8.encode(credentials);');
  print('    final base64Str = base64Encode(bytes);');
  print('    options.headers["Authorization"] = "Basic \$base64Str";  <-- WRONG');
  print('```');
  print('');
  print('WITH:');
  print('```dart');
  print('if (EnvironmentConfig.isStaging) {');
  print('  // Staging uses Bearer token authentication');
  print('  final testApiKey = AppConfig.testCredentials["apiKey"] ?? "";');
  print('  ');
  print('  if (testApiKey.isNotEmpty) {');
  print('    // Create Bearer token header');
  print('    options.headers["Authorization"] = "Bearer \$testApiKey";');
  print('    _logger.d("API_SERVICE: Using Bearer token for staging");');
  print('```');
}