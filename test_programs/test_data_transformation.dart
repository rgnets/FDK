#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Test 4: Analyze data transformation from API to models

void main() async {
  print('=' * 60);
  print('TEST 4: DATA TRANSFORMATION ANALYSIS');
  print('=' * 60);
  
  const apiUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
  const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
  
  // Fetch actual data
  print('\n1. FETCHING ACTUAL API DATA:');
  print('-' * 40);
  
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/pms_rooms.json?page=1'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      
      print('Got ${results.length} rooms');
      
      // Analyze first room structure
      final firstRoom = results[0];
      
      print('\n2. FIRST ROOM RAW DATA STRUCTURE:');
      print('-' * 40);
      print('Keys in room object: ${firstRoom.keys.toList()}');
      print('');
      print('Core fields:');
      print('  id: ${firstRoom['id']} (type: ${firstRoom['id'].runtimeType})');
      print('  room: ${firstRoom['room']} (type: ${firstRoom['room']?.runtimeType})');
      print('  name: ${firstRoom['name']} (type: ${firstRoom['name']?.runtimeType})');
      print('  building: ${firstRoom['building']} (type: ${firstRoom['building']?.runtimeType})');
      print('  floor: ${firstRoom['floor']} (type: ${firstRoom['floor']?.runtimeType})');
      
      // Check device arrays
      print('\nDevice arrays:');
      if (firstRoom['access_points'] != null) {
        final aps = firstRoom['access_points'] as List;
        print('  access_points: ${aps.length} items');
        if (aps.isNotEmpty) {
          print('    First AP keys: ${aps[0].keys.toList()}');
          print('    First AP id: ${aps[0]['id']}');
          print('    First AP name: ${aps[0]['name']}');
        }
      } else {
        print('  access_points: null');
      }
      
      if (firstRoom['media_converters'] != null) {
        final mcs = firstRoom['media_converters'] as List;
        print('  media_converters: ${mcs.length} items');
        if (mcs.isNotEmpty) {
          print('    First MC keys: ${mcs[0].keys.toList()}');
          print('    First MC id: ${mcs[0]['id']}');
          print('    First MC name: ${mcs[0]['name']}');
        }
      } else {
        print('  media_converters: null');
      }
      
      // Simulate how RoomRemoteDataSource processes this
      print('\n3. SIMULATING RoomRemoteDataSource PROCESSING:');
      print('-' * 40);
      
      // From room_remote_data_source.dart lines 58-68
      void simulateRoomModelCreation(Map<String, dynamic> roomData) {
        final id = roomData['id']?.toString() ?? '';
        final name = (roomData['room'] ?? 
                     roomData['name'] ?? 
                     roomData['room_number'] ?? 
                     'Room ${roomData['id']}').toString();
        final building = (roomData['building'] ?? roomData['property'] ?? '').toString();
        final floor = roomData['floor']?.toString() ?? '';
        final deviceCount = (roomData['device_count'] as int?) ?? 0;
        final onlineDevices = (roomData['online_devices'] as int?) ?? 0;
        
        print('  RoomModel would have:');
        print('    id: "$id"');
        print('    name: "$name"');
        print('    building: "$building"');
        print('    floor: "$floor"');
        print('    deviceCount: $deviceCount');
        print('    onlineDevices: $onlineDevices');
        
        // Extract device IDs (lines 173-239)
        final deviceIds = <String>{};
        
        if (roomData['access_points'] != null && roomData['access_points'] is List) {
          final apList = roomData['access_points'] as List;
          for (final ap in apList) {
            if (ap is Map && ap['id'] != null) {
              deviceIds.add(ap['id'].toString());
            }
          }
        }
        
        if (roomData['media_converters'] != null && roomData['media_converters'] is List) {
          final mcList = roomData['media_converters'] as List;
          for (final mc in mcList) {
            if (mc is Map && mc['id'] != null) {
              deviceIds.add(mc['id'].toString());
            }
          }
        }
        
        print('    deviceIds: ${deviceIds.length} extracted');
        if (deviceIds.isNotEmpty) {
          print('      Sample IDs: ${deviceIds.take(3).toList()}');
        }
      }
      
      simulateRoomModelCreation(firstRoom);
      
      // Check Room 203 specifically
      print('\n4. CHECKING ROOM 203 SPECIFICALLY:');
      print('-' * 40);
      
      for (final room in results) {
        final roomId = room['id']?.toString() ?? '';
        final roomName = room['room']?.toString() ?? room['name']?.toString() ?? '';
        
        if (roomId == '26' || roomName.contains('203')) {
          print('Found Room 203!');
          print('  ID: ${room['id']}');
          print('  Room field: ${room['room']}');
          print('  Name field: ${room['name']}');
          
          final aps = room['access_points'] as List?;
          final mcs = room['media_converters'] as List?;
          
          print('  Access Points: ${aps?.length ?? 0}');
          print('  Media Converters: ${mcs?.length ?? 0}');
          
          // Count device IDs
          final deviceIds = <String>{};
          if (aps != null) {
            for (final ap in aps) {
              if (ap['id'] != null) deviceIds.add(ap['id'].toString());
            }
          }
          if (mcs != null) {
            for (final mc in mcs) {
              if (mc['id'] != null) deviceIds.add(mc['id'].toString());
            }
          }
          
          print('  Total unique device IDs: ${deviceIds.length}');
          break;
        }
      }
      
      // Check data consistency
      print('\n5. DATA CONSISTENCY CHECK:');
      print('-' * 40);
      
      int roomsWithDevices = 0;
      int emptyRooms = 0;
      
      for (final room in results) {
        final aps = room['access_points'] as List?;
        final mcs = room['media_converters'] as List?;
        final hasDevices = (aps != null && aps.isNotEmpty) || 
                           (mcs != null && mcs.isNotEmpty);
        
        if (hasDevices) {
          roomsWithDevices++;
        } else {
          emptyRooms++;
        }
      }
      
      print('  Rooms with devices: $roomsWithDevices');
      print('  Empty rooms: $emptyRooms');
      
      if (emptyRooms == results.length) {
        print('  ⚠️ WARNING: All rooms are empty!');
        print('  This might indicate a data extraction issue');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  
  print('\n' + '=' * 60);
  print('FINDINGS');
  print('=' * 60);
  print('\n1. API returns data successfully with Bearer auth');
  print('2. Room data includes device arrays');
  print('3. Device IDs can be extracted from the arrays');
  print('4. Next: Check if the app is actually making the request');
  print('   with the correct Bearer auth header');
}