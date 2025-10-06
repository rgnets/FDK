#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test: Verify what device endpoints return with page_size=0

void main() async {
  print('=' * 60);
  print('DEVICE API ENDPOINTS VERIFICATION');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  // Test 1: Access Points endpoint
  print('\n1. ACCESS POINTS ENDPOINT (/api/access_points.json?page_size=0):');
  print('-' * 40);
  
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/access_points.json?page_size=0'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data is List) {
        print('✅ Response type: Direct List');
        print('   Total APs: ${data.length}');
        
        if (data.isNotEmpty) {
          final first = data.first as Map<String, dynamic>;
          print('   First AP keys: ${first.keys.toList()}');
          print('   Sample AP:');
          print('     id: ${first['id']}');
          print('     name: ${first['name'] ?? 'N/A'}');
          print('     type: ${first['type'] ?? 'N/A'}');
          print('     model: ${first['model'] ?? 'N/A'}');
        }
      } else if (data is Map && data['results'] != null) {
        final results = data['results'] as List;
        print('✅ Response type: Map with results');
        print('   Total APs: ${results.length}');
      } else {
        print('❌ Unexpected response format');
      }
    } else {
      print('❌ Status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  // Test 2: Media Converters endpoint
  print('\n2. MEDIA CONVERTERS ENDPOINT (/api/media_converters.json?page_size=0):');
  print('-' * 40);
  
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/media_converters.json?page_size=0'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data is List) {
        print('✅ Response type: Direct List');
        print('   Total MCs (ONTs): ${data.length}');
        
        if (data.isNotEmpty) {
          final first = data.first as Map<String, dynamic>;
          print('   First MC keys: ${first.keys.toList()}');
          print('   Sample MC:');
          print('     id: ${first['id']}');
          print('     name: ${first['name'] ?? 'N/A'}');
          print('     type: ${first['type'] ?? 'N/A'}');
          print('     model: ${first['model'] ?? 'N/A'}');
        }
      } else if (data is Map && data['results'] != null) {
        final results = data['results'] as List;
        print('✅ Response type: Map with results');
        print('   Total MCs: ${results.length}');
      } else {
        print('❌ Unexpected response format');
      }
    } else {
      print('❌ Status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  // Test 3: Check for switches endpoint
  print('\n3. SWITCHES ENDPOINT (potential endpoints):');
  print('-' * 40);
  
  // Try different possible switch endpoints
  final switchEndpoints = [
    '/api/switches.json',
    '/api/switch_devices.json',
    '/api/infrastructure_devices.json',
  ];
  
  for (final endpoint in switchEndpoints) {
    print('\n   Testing $endpoint:');
    try {
      final response = await http.get(
        Uri.parse('$apiUrl$endpoint?page_size=0'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          print('     ✅ Found! ${data.length} items');
        } else if (data is Map && data['results'] != null) {
          print('     ✅ Found! ${(data['results'] as List).length} items');
        }
      } else {
        print('     ❌ Status: ${response.statusCode}');
      }
    } catch (e) {
      print('     ❌ Not available or timeout');
    }
  }
  
  // Summary
  print('\n' + '=' * 60);
  print('DEVICE COUNT SUMMARY');
  print('=' * 60);
  
  print('\nExpected device types:');
  print('  • Access Points (APs)');
  print('  • Media Converters (ONTs)');
  print('  • Switches');
  
  print('\nProblem Investigation:');
  print('  If APs show as 0 in GUI, check:');
  print('  1. Is device_remote_data_source fetching APs?');
  print('  2. Is the device type classification correct?');
  print('  3. Are APs being filtered out somewhere?');
}