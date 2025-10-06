#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test 1: Verify API returns actual data with our fixed authentication

void main() async {
  print('=' * 60);
  print('TEST 1: API DATA RETRIEVAL VERIFICATION');
  print('=' * 60);
  
  // Use the staging credentials we configured
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const username = 'fetoolreadonly';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  // Create Basic Auth header
  final credentials = '$username:$apiKey';
  final bytes = utf8.encode(credentials);
  final base64Str = base64Encode(bytes);
  final authHeader = 'Basic $base64Str';
  
  print('\nConfiguration:');
  print('  API URL: $apiUrl');
  print('  Username: $username');
  print('  Auth Header: ${authHeader.substring(0, 30)}...');
  
  // Test 1: Fetch rooms
  print('\n1. FETCHING ROOMS:');
  print('-' * 40);
  
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/pms_rooms.json?page=1'),
      headers: {
        'Authorization': authHeader,
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    
    print('Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['results'] != null) {
        final results = data['results'] as List;
        print('✅ SUCCESS: Got ${results.length} rooms');
        
        // Analyze first room structure
        if (results.isNotEmpty) {
          final firstRoom = results[0];
          print('\nFirst Room Analysis:');
          print('  ID: ${firstRoom['id']}');
          print('  Name: ${firstRoom['room'] ?? firstRoom['name']}');
          print('  Building: ${firstRoom['building']}');
          print('  Floor: ${firstRoom['floor']}');
          
          // Check for devices
          final hasAccessPoints = firstRoom['access_points'] != null;
          final hasMediaConverters = firstRoom['media_converters'] != null;
          
          if (hasAccessPoints) {
            final aps = firstRoom['access_points'] as List;
            print('  Access Points: ${aps.length}');
          }
          
          if (hasMediaConverters) {
            final mcs = firstRoom['media_converters'] as List;
            print('  Media Converters: ${mcs.length}');
          }
          
          // Count total devices across all rooms
          int totalDevices = 0;
          int roomsWithDevices = 0;
          
          for (final room in results) {
            int roomDevices = 0;
            
            if (room['access_points'] != null) {
              roomDevices += (room['access_points'] as List).length;
            }
            if (room['media_converters'] != null) {
              roomDevices += (room['media_converters'] as List).length;
            }
            
            totalDevices += roomDevices;
            if (roomDevices > 0) roomsWithDevices++;
          }
          
          print('\nOverall Statistics:');
          print('  Total rooms: ${results.length}');
          print('  Rooms with devices: $roomsWithDevices');
          print('  Total devices: $totalDevices');
          
          // Check for specific test rooms
          print('\nLooking for test rooms 203 and 411:');
          
          for (final room in results) {
            final roomName = room['room']?.toString() ?? room['name']?.toString() ?? '';
            final roomId = room['id']?.toString() ?? '';
            
            if (roomName.contains('203') || roomId == '203') {
              print('  ✅ Found Room 203');
              final aps = room['access_points'] as List?;
              final mcs = room['media_converters'] as List?;
              print('    Devices: ${(aps?.length ?? 0) + (mcs?.length ?? 0)}');
            }
            
            if (roomName.contains('411') || roomId == '411') {
              print('  ✅ Found Room 411');
              final aps = room['access_points'] as List?;
              final mcs = room['media_converters'] as List?;
              print('    Devices: ${(aps?.length ?? 0) + (mcs?.length ?? 0)}');
            }
          }
        }
      } else {
        print('❌ No results field in response');
        print('Response keys: ${data.keys.toList()}');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      print('Response body: ${response.body.substring(0, 200 < response.body.length ? 200 : response.body.length)}...');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  // Test 2: Fetch a specific room
  print('\n2. FETCHING SPECIFIC ROOM (ID: 203):');
  print('-' * 40);
  
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/pms_rooms/203.json'),
      headers: {
        'Authorization': authHeader,
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    
    print('Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final room = jsonDecode(response.body);
      print('✅ SUCCESS: Got room data');
      print('  Room ID: ${room['id']}');
      print('  Room Name: ${room['room'] ?? room['name']}');
      
      // Extract device IDs
      final deviceIds = <String>{};
      
      if (room['access_points'] != null) {
        for (final ap in room['access_points']) {
          if (ap['id'] != null) {
            deviceIds.add(ap['id'].toString());
          }
        }
      }
      
      if (room['media_converters'] != null) {
        for (final mc in room['media_converters']) {
          if (mc['id'] != null) {
            deviceIds.add(mc['id'].toString());
          }
        }
      }
      
      print('  Extracted Device IDs: ${deviceIds.length}');
      if (deviceIds.isNotEmpty) {
        print('    Sample IDs: ${deviceIds.take(5).toList()}');
      }
    } else if (response.statusCode == 404) {
      print('⚠️  Room 203 not found - trying with page_size=0');
      
      // Try fetching all rooms to find room 203
      final allResponse = await http.get(
        Uri.parse('$apiUrl/api/pms_rooms.json?page_size=0'),
        headers: {
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 60));
      
      if (allResponse.statusCode == 200) {
        final data = jsonDecode(allResponse.body);
        final results = data['results'] as List?;
        
        if (results != null) {
          for (final room in results) {
            if (room['id']?.toString() == '203' || 
                room['room']?.toString()?.contains('203') == true) {
              print('  ✅ Found Room 203 in list');
              break;
            }
          }
        }
      }
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  
  print('\n' + '=' * 60);
  print('CONCLUSION');
  print('=' * 60);
  print('\nAPI Connection Status:');
  print('  - Authentication: Working with Basic Auth');
  print('  - Data retrieval: Check results above');
  print('  - If data is returned, issue is in app data processing');
  print('  - If no data, issue is still with API connection');
}