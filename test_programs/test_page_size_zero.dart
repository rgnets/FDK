#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test: Check API response with page_size=0

void main() async {
  print('=' * 60);
  print('TEST API WITH page_size=0');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  print('\n1. Testing with page_size=0 (disable pagination):');
  print('-' * 40);
  
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/pms_rooms.json?page_size=0'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    
    print('Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseBody = response.body;
      
      // First check if response is JSON
      try {
        final data = jsonDecode(responseBody);
        
        print('Response type: ${data.runtimeType}');
        
        if (data is Map<String, dynamic>) {
          print('Response keys: ${data.keys.toList()}');
          
          // Check for results field
          if (data.containsKey('results')) {
            final results = data['results'];
            print('Results type: ${results.runtimeType}');
            
            if (results is List) {
              print('✅ Results is a List with ${results.length} items');
              
              // Check pagination info
              print('\nPagination info:');
              print('  count: ${data['count']}');
              print('  total_pages: ${data['total_pages']}');
              print('  page: ${data['page']}');
              print('  page_size: ${data['page_size']}');
              
              // Check first room structure
              if (results.isNotEmpty) {
                final firstRoom = results.first;
                print('\nFirst room type: ${firstRoom.runtimeType}');
                if (firstRoom is Map) {
                  print('First room keys: ${firstRoom.keys.toList().take(5)}...');
                }
              }
            } else {
              print('❌ Results is not a List: ${results.runtimeType}');
            }
          } else {
            print('❌ No results field in response');
          }
        } else if (data is List) {
          print('Response is a List with ${data.length} items');
          // Maybe the API returns array directly with page_size=0?
          if (data.isNotEmpty) {
            final firstItem = data.first;
            print('First item type: ${firstItem.runtimeType}');
            if (firstItem is Map) {
              print('First item keys: ${firstItem.keys.toList()}');
            }
          }
        } else {
          print('Unexpected response type: ${data.runtimeType}');
        }
      } catch (e) {
        print('JSON decode error: $e');
        print('Response body (first 500 chars): ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
      }
    } else {
      print('Non-200 response: ${response.body}');
    }
  } catch (e) {
    print('Request exception: $e');
  }
  
  print('\n2. Testing with page=1 for comparison:');
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
      
      if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        print('✅ With page=1: Got ${results.length} rooms');
        print('  Total count: ${data['count']}');
        print('  Total pages: ${data['total_pages']}');
      }
    }
  } catch (e) {
    print('Exception: $e');
  }
  
  print('\n' + '=' * 60);
  print('RECOMMENDATION');
  print('=' * 60);
  
  print('\nBased on the API behavior:');
  print('1. If page_size=0 returns all results, update getRooms() to use it');
  print('2. This would eliminate the need for pagination logic');
  print('3. Simpler, more efficient, and matches intended API usage');
}