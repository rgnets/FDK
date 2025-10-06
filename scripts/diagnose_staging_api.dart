#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Direct test of staging API to diagnose room name issue
void main() async {
  print('=' * 80);
  print('STAGING API DIRECT DIAGNOSIS');
  print('=' * 80);
  
  // Staging API credentials from CLAUDE.md
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  const baseUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    },
    validateStatus: (status) => status != null && status < 500,
  ));
  
  // Accept self-signed certificates (as per the codebase)
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };
  
  try {
    print('\n1. TESTING /api/pms_rooms.json WITH PAGINATION:');
    print('-' * 40);
    
    // First test with regular pagination
    final paginatedResponse = await dio.get('/api/pms_rooms.json?page=1&page_size=5');
    
    if (paginatedResponse.statusCode == 200) {
      print('Status: ${paginatedResponse.statusCode} OK');
      print('Response type: ${paginatedResponse.data.runtimeType}');
      
      if (paginatedResponse.data is Map) {
        final data = paginatedResponse.data as Map<String, dynamic>;
        print('Response keys: ${data.keys.toList()}');
        
        if (data['results'] != null && data['results'] is List) {
          final results = data['results'] as List;
          print('Number of results: ${results.length}');
          
          if (results.isNotEmpty) {
            print('\nFirst room with pagination:');
            final firstRoom = results.first as Map<String, dynamic>;
            print('  Keys: ${firstRoom.keys.toList()}');
            print('  ID: ${firstRoom['id']}');
            print('  Name: ${firstRoom['name']} (type: ${firstRoom['name'].runtimeType})');
            print('  Name is null: ${firstRoom['name'] == null}');
            print('  Full data: ${json.encode(firstRoom)}');
          }
        }
      }
    } else {
      print('Error: Status ${paginatedResponse.statusCode}');
    }
    
    print('\n2. TESTING /api/pms_rooms.json?page_size=0:');
    print('-' * 40);
    
    // Test with page_size=0 (as used in the app)
    final unpaginatedResponse = await dio.get('/api/pms_rooms.json?page_size=0');
    
    if (unpaginatedResponse.statusCode == 200) {
      print('Status: ${unpaginatedResponse.statusCode} OK');
      print('Response type: ${unpaginatedResponse.data.runtimeType}');
      
      // Check if it returns a List directly
      if (unpaginatedResponse.data is List) {
        final results = unpaginatedResponse.data as List;
        print('DIRECT LIST RESPONSE!');
        print('Number of rooms: ${results.length}');
        
        if (results.isNotEmpty) {
          print('\nFirst few rooms:');
          for (int i = 0; i < 3 && i < results.length; i++) {
            final room = results[i] as Map<String, dynamic>;
            print('  Room ${i + 1}:');
            print('    ID: ${room['id']}');
            print('    Name: ${room['name']}');
            print('    Name is null: ${room['name'] == null}');
          }
          
          // Check for rooms with null names
          print('\nScanning for null names...');
          int nullNameCount = 0;
          for (final room in results) {
            if (room is Map && room['name'] == null) {
              nullNameCount++;
              print('  Found null name: Room ID ${room['id']}');
              if (nullNameCount <= 3) {
                print('    Full data: ${json.encode(room)}');
              }
            }
          }
          print('Total rooms with null names: $nullNameCount / ${results.length}');
        }
      } 
      // Check if it returns a Map with results
      else if (unpaginatedResponse.data is Map) {
        final data = unpaginatedResponse.data as Map<String, dynamic>;
        print('MAP RESPONSE');
        print('Response keys: ${data.keys.toList()}');
        
        if (data['results'] != null && data['results'] is List) {
          final results = data['results'] as List;
          print('Number of results: ${results.length}');
          
          if (results.isNotEmpty) {
            print('\nFirst few rooms:');
            for (int i = 0; i < 3 && i < results.length; i++) {
              final room = results[i] as Map<String, dynamic>;
              print('  Room ${i + 1}:');
              print('    ID: ${room['id']}');
              print('    Name: ${room['name']}');
              print('    Name is null: ${room['name'] == null}');
            }
          }
        }
      } else {
        print('Unexpected response type: ${unpaginatedResponse.data.runtimeType}');
      }
    } else {
      print('Error: Status ${unpaginatedResponse.statusCode}');
    }
    
    print('\n3. TESTING SPECIFIC ROOM (e.g., /api/pms_rooms/128.json):');
    print('-' * 40);
    
    // Test fetching a specific room
    try {
      final singleRoomResponse = await dio.get('/api/pms_rooms/128.json');
      
      if (singleRoomResponse.statusCode == 200) {
        print('Status: ${singleRoomResponse.statusCode} OK');
        final room = singleRoomResponse.data as Map<String, dynamic>;
        print('Room 128 details:');
        print('  Keys: ${room.keys.toList()}');
        print('  ID: ${room['id']}');
        print('  Name: ${room['name']}');
        print('  Name type: ${room['name'].runtimeType}');
        print('  Name is null: ${room['name'] == null}');
        print('  Full data: ${json.encode(room)}');
      } else {
        print('Error: Status ${singleRoomResponse.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch room 128: $e');
      // Try another room ID
      try {
        print('\nTrying room 1000...');
        final altResponse = await dio.get('/api/pms_rooms/1000.json');
        if (altResponse.statusCode == 200) {
          final room = altResponse.data as Map<String, dynamic>;
          print('Room 1000: Name="${room['name']}", ID=${room['id']}');
        }
      } catch (e2) {
        print('Failed to fetch room 1000: $e2');
      }
    }
    
    print('\n4. ANALYSIS:');
    print('-' * 40);
    print('Key findings will be displayed above.');
    print('Look for:');
    print('  - Response format differences between paginated and page_size=0');
    print('  - Whether any rooms actually have null names');
    print('  - The exact structure of the API response');
    
  } catch (e) {
    print('\nERROR: $e');
    if (e is DioException) {
      print('Response: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
    }
  }
  
  print('\n' + '=' * 80);
  print('DIAGNOSIS COMPLETE');
  print('=' * 80);
}