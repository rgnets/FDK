#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test: Simulate how the app fetches devices (parallel Future.wait)

void main() async {
  print('=' * 60);
  print('PARALLEL FETCH TEST (Simulating App Behavior)');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  // Simulate _fetchDeviceType from device_remote_data_source.dart
  Future<List<Map<String, dynamic>>> fetchDeviceType(String endpoint) async {
    try {
      print('\n  Starting fetch: $endpoint');
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse('$apiUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('    ⏱️ TIMEOUT for $endpoint');
          throw Exception('Timeout');
        },
      );
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats (matching app logic)
        List<dynamic> results = [];
        
        if (data == null) {
          print('    ⚠️ NULL data for $endpoint @ ${stopwatch.elapsedMilliseconds}ms');
          return []; // App returns empty list here
        } else if (data is List) {
          results = data;
          print('    ✅ List format: ${results.length} items @ ${stopwatch.elapsedMilliseconds}ms');
        } else if (data is Map) {
          if (data.containsKey('results')) {
            results = data['results'] as List;
            print('    ✅ Map.results format: ${results.length} items @ ${stopwatch.elapsedMilliseconds}ms');
          } else if (data.containsKey('data')) {
            results = data['data'] as List;
            print('    ✅ Map.data format: ${results.length} items @ ${stopwatch.elapsedMilliseconds}ms');
          } else {
            print('    ⚠️ Unknown Map format for $endpoint @ ${stopwatch.elapsedMilliseconds}ms');
            print('    Keys: ${data.keys.toList()}');
            return []; // App returns empty list here
          }
        } else {
          print('    ⚠️ Unexpected type: ${data.runtimeType} @ ${stopwatch.elapsedMilliseconds}ms');
          return []; // App returns empty list here
        }
        
        return results.cast<Map<String, dynamic>>();
      } else {
        print('    ❌ HTTP ${response.statusCode} for $endpoint');
        return []; // App returns empty list on error
      }
    } catch (e) {
      print('    ❌ Exception for $endpoint: $e');
      return []; // App returns empty list on exception
    }
  }
  
  print('\n\nTesting 10 iterations of parallel fetching:');
  print('-' * 60);
  
  final iterationResults = <Map<String, dynamic>>[];
  
  for (int i = 1; i <= 10; i++) {
    print('\n\nIteration $i:');
    print('=' * 40);
    
    final overallStart = Stopwatch()..start();
    
    // Simulate Future.wait as app does
    print('Starting Future.wait for all endpoints...');
    
    final results = await Future.wait([
      fetchDeviceType('/api/access_points.json?page_size=0'),
      fetchDeviceType('/api/media_converters.json?page_size=0'),
      fetchDeviceType('/api/switch_devices.json?page_size=0'),
      fetchDeviceType('/api/wlan_devices.json?page_size=0'),
    ]);
    
    overallStart.stop();
    
    final apCount = results[0].length;
    final ontCount = results[1].length;
    final switchCount = results[2].length;
    final wlanCount = results[3].length;
    final total = apCount + ontCount + switchCount + wlanCount;
    
    print('\nResults:');
    print('  Access Points: $apCount ${apCount == 0 ? "🚨 ZERO!" : "✅"}');
    print('  Media Converters: $ontCount ${ontCount == 0 ? "🚨 ZERO!" : "✅"}');
    print('  Switches: $switchCount ${switchCount == 0 ? "🚨 ZERO!" : "✅"}');
    print('  WLAN Controllers: $wlanCount ${wlanCount == 0 ? "🚨 ZERO!" : "✅"}');
    print('  Total: $total devices in ${overallStart.elapsedMilliseconds}ms');
    
    iterationResults.add({
      'iteration': i,
      'ap': apCount,
      'ont': ontCount,
      'switch': switchCount,
      'wlan': wlanCount,
      'total': total,
      'time_ms': overallStart.elapsedMilliseconds,
    });
    
    // Check for inconsistency
    if (i > 1) {
      final prev = iterationResults[i - 2];
      if (prev['ap'] != apCount || prev['ont'] != ontCount || 
          prev['switch'] != switchCount || prev['wlan'] != wlanCount) {
        print('\n  📊 COUNTS CHANGED FROM PREVIOUS!');
        print('    APs: ${prev['ap']} → $apCount');
        print('    ONTs: ${prev['ont']} → $ontCount');
        print('    Switches: ${prev['switch']} → $switchCount');
        print('    WLANs: ${prev['wlan']} → $wlanCount');
      }
    }
    
    // Wait before next iteration
    await Future.delayed(Duration(seconds: 3));
  }
  
  print('\n\n' + '=' * 60);
  print('FINAL ANALYSIS');
  print('=' * 60);
  
  // Analyze consistency
  final apCounts = iterationResults.map((r) => r['ap'] as int).toSet();
  final ontCounts = iterationResults.map((r) => r['ont'] as int).toSet();
  final switchCounts = iterationResults.map((r) => r['switch'] as int).toSet();
  final wlanCounts = iterationResults.map((r) => r['wlan'] as int).toSet();
  
  print('\nCount Variations:');
  print('  AP counts seen: $apCounts');
  print('  ONT counts seen: $ontCounts');
  print('  Switch counts seen: $switchCounts');
  print('  WLAN counts seen: $wlanCounts');
  
  // Check for zeros
  final apZeros = iterationResults.where((r) => r['ap'] == 0).length;
  final ontZeros = iterationResults.where((r) => r['ont'] == 0).length;
  final switchZeros = iterationResults.where((r) => r['switch'] == 0).length;
  final wlanZeros = iterationResults.where((r) => r['wlan'] == 0).length;
  
  print('\nZero Occurrences:');
  print('  APs returned 0: $apZeros/10 times');
  print('  ONTs returned 0: $ontZeros/10 times');
  print('  Switches returned 0: $switchZeros/10 times');
  print('  WLANs returned 0: $wlanZeros/10 times');
  
  if (apZeros > 0 || ontZeros > 0 || switchZeros > 0 || wlanZeros > 0) {
    print('\n🚨 INTERMITTENT ZERO PROBLEM CONFIRMED!');
    print('   Some device types intermittently return 0.');
  } else {
    print('\n✅ No intermittent zeros detected in this test run.');
  }
}