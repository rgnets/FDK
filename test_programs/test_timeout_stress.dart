#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test: Multiple runs to check timing consistency

void main() async {
  print('=' * 60);
  print('TIMEOUT STRESS TEST - MULTIPLE RUNS');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  print('\nTesting access_points endpoint (the slow one) 5 times:');
  print('-' * 40);
  
  final times = <int>[];
  int timeouts = 0;
  int successes = 0;
  
  for (int i = 1; i <= 5; i++) {
    print('\nRun $i:');
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/access_points.json?page_size=0'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30), // Match production timeout
        onTimeout: () {
          stopwatch.stop();
          print('  ⏱️ TIMEOUT after ${stopwatch.elapsedMilliseconds}ms');
          timeouts++;
          times.add(stopwatch.elapsedMilliseconds);
          throw Exception('Timeout');
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
        times.add(stopwatch.elapsedMilliseconds);
        successes++;
        
        if (stopwatch.elapsedMilliseconds > 25000) {
          print('  🚨 DANGER: Response took >25 seconds!');
        } else if (stopwatch.elapsedMilliseconds > 20000) {
          print('  ⚠️ WARNING: Response took >20 seconds');
        }
      } else {
        print('  ❌ HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (!e.toString().contains('Timeout')) {
        print('  ❌ ERROR: $e');
      }
    }
    
    // Short delay between requests
    if (i < 5) {
      await Future.delayed(Duration(seconds: 2));
    }
  }
  
  print('\n\n' + '=' * 60);
  print('RESULTS SUMMARY');
  print('=' * 60);
  
  print('\nTiming Statistics:');
  print('  Successful requests: $successes/5');
  print('  Timeouts: $timeouts/5');
  
  if (times.isNotEmpty) {
    times.sort();
    final avg = times.reduce((a, b) => a + b) ~/ times.length;
    print('\n  Min time: ${times.first}ms');
    print('  Max time: ${times.last}ms');
    print('  Avg time: ${avg}ms');
    print('  Median: ${times[times.length ~/ 2]}ms');
  }
  
  print('\n\nCONCLUSION:');
  print('-' * 40);
  
  if (timeouts > 0) {
    print('❌ TIMEOUT ISSUE CONFIRMED!');
    print('   The 30-second timeout is being exceeded.');
    print('   This explains the intermittent zero values.');
  } else if (times.any((t) => t > 25000)) {
    print('⚠️ NEAR-TIMEOUT CONDITION!');
    print('   Responses are dangerously close to 30s limit.');
    print('   Under heavier load, timeouts are likely.');
  } else if (times.any((t) => t > 20000)) {
    print('⚠️ SLOW RESPONSES DETECTED');
    print('   Some responses exceed 20 seconds.');
    print('   Consider increasing timeout as preventive measure.');
  } else {
    print('✅ No timeout issues detected');
    print('   All responses well within 30s limit.');
  }
  
  print('\n\nRECOMMENDATION:');
  if (timeouts > 0 || times.any((t) => t > 25000)) {
    print('🔧 Increase timeout from 30s to 60s in core_providers.dart');
    print('   This would prevent intermittent failures.');
  }
}