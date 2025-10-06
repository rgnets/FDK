#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test: Analyze timeout configurations and actual API response times

void main() async {
  print('=' * 60);
  print('TIMEOUT CONFIGURATION ANALYSIS');
  print('=' * 60);
  
  print('\nCURRENT TIMEOUT SETTINGS IN CODEBASE:');
  print('-' * 40);
  
  print('\n1. core_providers.dart (lines 42-43):');
  print('   Dio BaseOptions:');
  print('   • connectTimeout: Duration(seconds: 30)');
  print('   • receiveTimeout: Duration(seconds: 30)');
  print('   This is the MAIN Dio instance used by ApiService');
  
  print('\n2. api_service.dart testConnection (lines 285-286):');
  print('   Test Dio instance:');
  print('   • connectTimeout: Duration(seconds: 10)');
  print('   • receiveTimeout: Duration(seconds: 10)');
  print('   Only used for connection testing');
  
  print('\n3. My test programs:');
  print('   • Most use 30 second timeout');
  print('   • Some use 5 second timeout for testing');
  
  print('\n\n⚠️ KEY OBSERVATION:');
  print('The main Dio instance has 30 second timeouts.');
  print('This SHOULD be sufficient for most API calls.');
  
  // Test actual API response times
  print('\n\nTESTING ACTUAL API RESPONSE TIMES:');
  print('-' * 40);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  final endpoints = [
    '/api/access_points.json?page_size=0',
    '/api/media_converters.json?page_size=0',
    '/api/switch_devices.json?page_size=0',
    '/api/wlan_devices.json?page_size=0',
    '/api/pms_rooms.json?page_size=0',
  ];
  
  for (final endpoint in endpoints) {
    print('\n$endpoint:');
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await http.get(
        Uri.parse('$apiUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 60), // Use 60s to see actual times
        onTimeout: () {
          stopwatch.stop();
          print('  ⏱️ TIMEOUT after ${stopwatch.elapsedMilliseconds}ms');
          throw Exception('Timeout after ${stopwatch.elapsedMilliseconds}ms');
        },
      );
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int itemCount = 0;
        
        if (data is List) {
          itemCount = data.length;
        } else if (data is Map && data['results'] != null) {
          itemCount = (data['results'] as List).length;
        }
        
        print('  ✅ SUCCESS in ${stopwatch.elapsedMilliseconds}ms (${itemCount} items)');
        
        // Analyze if this is close to timeout
        if (stopwatch.elapsedMilliseconds > 25000) {
          print('  ⚠️ WARNING: Response took >25 seconds!');
          print('     This is dangerously close to 30s timeout');
        } else if (stopwatch.elapsedMilliseconds > 15000) {
          print('  ⚠️ Note: Response took >15 seconds');
        }
      } else {
        print('  ❌ HTTP ${response.statusCode} in ${stopwatch.elapsedMilliseconds}ms');
      }
    } catch (e) {
      stopwatch.stop();
      print('  ❌ ERROR after ${stopwatch.elapsedMilliseconds}ms: $e');
      
      if (stopwatch.elapsedMilliseconds >= 59000) {
        print('  💀 This would timeout with 30s limit!');
      }
    }
  }
  
  print('\n\n' + '=' * 60);
  print('ANALYSIS RESULTS');
  print('=' * 60);
  
  print('\nPOSSIBLE ISSUES:');
  print('1. If access_points takes >30 seconds, it will timeout');
  print('2. With page_size=0, we\'re fetching ALL data at once');
  print('3. Large datasets might exceed timeout limits');
  
  print('\nWHY INTERMITTENT:');
  print('• Server load varies throughout the day');
  print('• Network latency fluctuates');
  print('• Data size might vary (more devices = longer response)');
  
  print('\n\nRECOMMENDATIONS (without changing production):');
  print('-' * 40);
  
  print('\n1. IMMEDIATE: Monitor actual response times');
  print('   Check if responses are close to 30s limit');
  
  print('\n2. CONSIDER: The retry logic might help but...');
  print('   If endpoint takes 35s, it will fail 3 times');
  print('   Total time: 3 × 30s = 90s of waiting!');
  
  print('\n3. POTENTIAL FIX OPTIONS:');
  print('   a. Increase timeout to 60 seconds');
  print('   b. Use pagination instead of page_size=0');
  print('   c. Cache responses to avoid repeated calls');
  print('   d. Fetch device types sequentially not in parallel');
  
  print('\n4. ROOT CAUSE HYPOTHESIS:');
  print('   The 30-second timeout might be too short for');
  print('   fetching all 220 access points at once!');
}