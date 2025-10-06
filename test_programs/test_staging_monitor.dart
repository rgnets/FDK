#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Test: Monitor staging API responses in real-time

void main() async {
  print('=' * 60);
  print('STAGING API REAL-TIME MONITOR');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  print('\nMonitoring access_points endpoint every 5 seconds...');
  print('Press Ctrl+C to stop\n');
  print('-' * 60);
  
  int iteration = 0;
  final results = <Map<String, dynamic>>[];
  
  while (true) {
    iteration++;
    final timestamp = DateTime.now().toIso8601String();
    print('\n[$timestamp] Check #$iteration:');
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/access_points.json?page_size=0'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout after 30 seconds');
        },
      );
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final data = jsonDecode(responseBody);
        
        // Analyze response structure
        String dataType = 'unknown';
        int itemCount = 0;
        Map<String, dynamic>? firstItem;
        
        if (data == null) {
          dataType = 'null';
          print('  ⚠️ Response data is NULL!');
        } else if (data is List) {
          dataType = 'List';
          itemCount = data.length;
          if (data.isNotEmpty) {
            firstItem = data.first as Map<String, dynamic>;
          }
        } else if (data is Map) {
          dataType = 'Map';
          if (data.containsKey('results')) {
            final results = data['results'];
            if (results is List) {
              dataType = 'Map with results[]';
              itemCount = results.length;
              if (results.isNotEmpty) {
                firstItem = results.first as Map<String, dynamic>;
              }
            }
          } else if (data.containsKey('data')) {
            final innerData = data['data'];
            if (innerData is List) {
              dataType = 'Map with data[]';
              itemCount = innerData.length;
              if (innerData.isNotEmpty) {
                firstItem = innerData.first as Map<String, dynamic>;
              }
            }
          } else {
            dataType = 'Map (other structure)';
            print('  Map keys: ${data.keys.toList()}');
          }
        } else {
          dataType = 'Other: ${data.runtimeType}';
        }
        
        // Log results
        final result = {
          'iteration': iteration,
          'timestamp': timestamp,
          'status': response.statusCode,
          'time_ms': stopwatch.elapsedMilliseconds,
          'data_type': dataType,
          'item_count': itemCount,
          'response_size': responseBody.length,
        };
        results.add(result);
        
        // Display results
        if (itemCount == 0) {
          print('  🚨 ZERO ITEMS! Type: $dataType, Time: ${stopwatch.elapsedMilliseconds}ms');
          print('  Response size: ${responseBody.length} bytes');
          print('  First 500 chars: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
        } else {
          print('  ✅ $itemCount items, Type: $dataType, Time: ${stopwatch.elapsedMilliseconds}ms');
          if (firstItem != null) {
            print('  First item keys: ${firstItem.keys.take(5).toList()}...');
          }
        }
        
        // Check for anomalies
        if (results.length > 1) {
          final prevCount = results[results.length - 2]['item_count'] as int;
          if (prevCount != itemCount) {
            print('  📊 COUNT CHANGED: $prevCount → $itemCount');
          }
        }
        
      } else {
        print('  ❌ HTTP ${response.statusCode}: ${response.reasonPhrase}');
        print('  Response: ${response.body.substring(0, 200)}...');
      }
      
    } catch (e) {
      stopwatch.stop();
      print('  ❌ ERROR after ${stopwatch.elapsedMilliseconds}ms: $e');
      
      results.add({
        'iteration': iteration,
        'timestamp': timestamp,
        'status': -1,
        'time_ms': stopwatch.elapsedMilliseconds,
        'error': e.toString(),
      });
    }
    
    // Summary every 10 iterations
    if (iteration % 10 == 0) {
      print('\n' + '=' * 40);
      print('SUMMARY after $iteration checks:');
      final successCount = results.where((r) => (r['item_count'] ?? 0) > 0).length;
      final zeroCount = results.where((r) => r['item_count'] == 0).length;
      final errorCount = results.where((r) => r['status'] == -1).length;
      
      print('  Successful (>0 items): $successCount');
      print('  Zero items returned: $zeroCount');
      print('  Errors: $errorCount');
      
      if (zeroCount > 0) {
        print('\n  🚨 INTERMITTENT ZEROS DETECTED!');
        final zeroResults = results.where((r) => r['item_count'] == 0);
        for (final r in zeroResults) {
          print('    Iteration ${r['iteration']}: ${r['data_type']} @ ${r['time_ms']}ms');
        }
      }
      print('=' * 40);
    }
    
    // Wait before next check
    await Future.delayed(Duration(seconds: 5));
  }
}