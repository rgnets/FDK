#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Staging environment credentials
const apiBaseUrl = 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
const apiUsername = 'fetoolreadonly';
const apiKey = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';

Future<void> main() async {
  print('=' * 60);
  print('STAGING API CONNECTIVITY TEST');
  print('=' * 60);
  print('API URL: $apiBaseUrl');
  print('Username: $apiUsername');
  print('');
  
  // Test 1: Basic connectivity
  print('TEST 1: Basic Connectivity');
  print('-' * 40);
  await testBasicConnectivity();
  
  // Test 2: Rooms endpoint
  print('\nTEST 2: Rooms Endpoint');
  print('-' * 40);
  await testRoomsEndpoint();
  
  // Test 3: Check device fields
  print('\nTEST 3: Device Fields Check');
  print('-' * 40);
  await testDeviceFields();
  
  // Test 4: Specific rooms
  print('\nTEST 4: Specific Rooms (203 & 411)');
  print('-' * 40);
  await testSpecificRooms();
}

Map<String, String> getAuthHeaders() {
  final authString = '$apiUsername:$apiKey';
  final authBytes = utf8.encode(authString);
  final authB64 = base64Encode(authBytes);
  
  return {
    'Authorization': 'Basic $authB64',
    'Accept': 'application/json',
  };
}

Future<void> testBasicConnectivity() async {
  try {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pms_rooms.json?page=1'),
      headers: getAuthHeaders(),
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      print('✓ API is reachable');
      final data = jsonDecode(response.body);
      if (data['results'] != null) {
        print('✓ Response structure is valid');
        print('  Count: ${data['count'] ?? 0}');
        print('  Results on page 1: ${(data['results'] as List).length}');
      }
    } else {
      print('✗ API returned status ${response.statusCode}');
      print('  Response: ${response.body.substring(0, 200)}...');
    }
  } catch (e) {
    print('✗ Failed to connect: $e');
  }
}

Future<void> testRoomsEndpoint() async {
  try {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pms_rooms.json?page=1'),
      headers: getAuthHeaders(),
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      
      print('Found ${results.length} rooms on page 1');
      
      if (results.isNotEmpty) {
        final firstRoom = results.first;
        print('\nFirst room structure:');
        print('  ID: ${firstRoom['id']}');
        print('  Name/Room: ${firstRoom['room'] ?? firstRoom['name']}');
        print('  Building: ${firstRoom['building']}');
        print('  Floor: ${firstRoom['floor']}');
        
        // Check for device arrays
        if (firstRoom['access_points'] != null) {
          final aps = firstRoom['access_points'] as List;
          print('  Access Points: ${aps.length}');
        }
        if (firstRoom['media_converters'] != null) {
          final mcs = firstRoom['media_converters'] as List;
          print('  Media Converters: ${mcs.length}');
        }
      }
    }
  } catch (e) {
    print('✗ Error: $e');
  }
}

Future<void> testDeviceFields() async {
  try {
    // Test access points endpoint
    print('Checking Access Points endpoint:');
    final apResponse = await http.get(
      Uri.parse('$apiBaseUrl/api/access_points.json?page=1'),
      headers: getAuthHeaders(),
    ).timeout(Duration(seconds: 30));
    
    if (apResponse.statusCode == 200) {
      final data = jsonDecode(apResponse.body);
      if (data['results'] != null && (data['results'] as List).isNotEmpty) {
        final firstAp = data['results'][0];
        print('  First AP keys: ${firstAp.keys.toList()}');
        
        // Check for pms_room_id field
        if (firstAp.containsKey('pms_room_id')) {
          print('  ✓ Access points have pms_room_id field');
          print('    Example: ${firstAp['pms_room_id']}');
        } else {
          print('  ✗ Access points DO NOT have pms_room_id field');
        }
      }
    }
    
    // Test media converters endpoint
    print('\nChecking Media Converters endpoint:');
    final mcResponse = await http.get(
      Uri.parse('$apiBaseUrl/api/media_converters.json?page=1'),
      headers: getAuthHeaders(),
    ).timeout(Duration(seconds: 30));
    
    if (mcResponse.statusCode == 200) {
      final data = jsonDecode(mcResponse.body);
      if (data['results'] != null && (data['results'] as List).isNotEmpty) {
        final firstMc = data['results'][0];
        print('  First MC keys: ${firstMc.keys.toList()}');
        
        // Check for pms_room_id field
        if (firstMc.containsKey('pms_room_id')) {
          print('  ✓ Media converters have pms_room_id field');
          print('    Example: ${firstMc['pms_room_id']}');
        } else {
          print('  ✗ Media converters DO NOT have pms_room_id field');
        }
      }
    }
  } catch (e) {
    print('✗ Error: $e');
  }
}

Future<void> testSpecificRooms() async {
  try {
    // Fetch all rooms and find 203 and 411
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pms_rooms.json?page_size=0'),
      headers: getAuthHeaders(),
    ).timeout(Duration(seconds: 60));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      
      dynamic room203;
      dynamic room411;
      
      for (final room in results) {
        final roomName = room['room']?.toString() ?? room['name']?.toString() ?? '';
        final roomId = room['id']?.toString() ?? '';
        
        if (roomName.contains('203') || roomId == '203') {
          room203 = room;
        }
        if (roomName.contains('411') || roomId == '411') {
          room411 = room;
        }
      }
      
      if (room203 != null) {
        print('Room 203 found:');
        print('  ID: ${room203['id']}');
        print('  Name: ${room203['room'] ?? room203['name']}');
        
        final aps = room203['access_points'] as List?;
        final mcs = room203['media_converters'] as List?;
        
        print('  Access Points: ${aps?.length ?? 0}');
        print('  Media Converters: ${mcs?.length ?? 0}');
        
        // Extract device IDs
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
      } else {
        print('✗ Room 203 not found');
      }
      
      if (room411 != null) {
        print('\nRoom 411 found:');
        print('  ID: ${room411['id']}');
        print('  Name: ${room411['room'] ?? room411['name']}');
        
        final aps = room411['access_points'] as List?;
        final mcs = room411['media_converters'] as List?;
        
        print('  Access Points: ${aps?.length ?? 0}');
        print('  Media Converters: ${mcs?.length ?? 0}');
        
        // Extract device IDs
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
      } else {
        print('✗ Room 411 not found');
      }
      
      // Check for device overlap
      if (room203 != null && room411 != null) {
        print('\nCHECKING FOR DEVICE OVERLAP:');
        
        final room203Devices = <String>{};
        final room411Devices = <String>{};
        
        // Extract Room 203 devices
        final aps203 = room203['access_points'] as List?;
        final mcs203 = room203['media_converters'] as List?;
        if (aps203 != null) {
          for (final ap in aps203) {
            if (ap['id'] != null) room203Devices.add(ap['id'].toString());
          }
        }
        if (mcs203 != null) {
          for (final mc in mcs203) {
            if (mc['id'] != null) room203Devices.add(mc['id'].toString());
          }
        }
        
        // Extract Room 411 devices
        final aps411 = room411['access_points'] as List?;
        final mcs411 = room411['media_converters'] as List?;
        if (aps411 != null) {
          for (final ap in aps411) {
            if (ap['id'] != null) room411Devices.add(ap['id'].toString());
          }
        }
        if (mcs411 != null) {
          for (final mc in mcs411) {
            if (mc['id'] != null) room411Devices.add(mc['id'].toString());
          }
        }
        
        final overlap = room203Devices.intersection(room411Devices);
        if (overlap.isNotEmpty) {
          print('  ⚠️ FOUND ${overlap.length} OVERLAPPING DEVICES!');
          print('  This is the root cause of cross-room data display');
          for (final deviceId in overlap.take(5)) {
            print('    - Device ID: $deviceId');
          }
        } else {
          print('  ✓ No overlapping devices found');
        }
      }
    }
  } catch (e) {
    print('✗ Error: $e');
  }
}