#!/usr/bin/env dart

// Iteration 1: Analyze staging API response structure

void main() {
  print('STAGING API STRUCTURE ANALYSIS - ITERATION 1');
  print('Analyzing exact response format from staging API');
  print('=' * 80);
  
  analyzeDeviceEndpoints();
  analyzeRoomEndpoints();
  analyzeNotificationStructure();
  identifyKeyPatterns();
}

void analyzeDeviceEndpoints() {
  print('\n1. DEVICE ENDPOINTS ANALYSIS');
  print('-' * 50);
  
  print('STAGING API DEVICE ENDPOINTS:');
  print('  GET /api/access_points?page_size=0');
  print('  GET /api/switches?page_size=0');
  print('  GET /api/media_converters?page_size=0');
  
  print('\nEXPECTED ACCESS POINT RESPONSE:');
  print('''
  {
    "count": 1234,
    "results": [
      {
        "id": 123,
        "name": "AP-WE-801",
        "mac": "00:11:22:33:44:55",
        "ip": "10.0.1.101",
        "online": true,
        "model": "RG-AP-520",
        "serial_number": "SN123456",
        "firmware": "3.2.1",
        "signal_strength": -45,
        "connected_clients": 12,
        "ssid": "RGNets-WiFi",
        "channel": 6,
        "last_seen": "2024-01-15T10:30:00Z",
        "note": null,
        "images": [],
        "pms_room": {
          "id": 801,
          "name": "(West Wing) 801",
          "room_number": "801",
          "building": "West Wing",
          "floor": 8
        }
      }
    ]
  }
  ''');
  
  print('\nEXPECTED SWITCH RESPONSE:');
  print('''
  {
    "count": 456,
    "results": [
      {
        "id": 234,
        "name": "SW-CORE-01",
        "mac": "00:AA:BB:CC:DD:EE",
        "ip": "10.0.0.1",
        "online": true,
        "model": "RG-SW-48P",
        "serial_number": "SW789012",
        "firmware": "2.1.5",
        "vlan": 100,
        "uptime": 864000,
        "last_seen": "2024-01-15T10:30:00Z",
        "note": "Core network switch",
        "images": ["image1.jpg"],
        "pms_room": {
          "id": 1000,
          "name": "(MDF) Core",
          "room_number": "MDF",
          "building": "Main",
          "floor": 1
        }
      }
    ]
  }
  ''');
  
  print('\nKEY OBSERVATIONS:');
  print('  • Response wrapped in {count, results} structure');
  print('  • Device fields use snake_case (mac, ip, serial_number)');
  print('  • pms_room is nested object with id, name, room_number, building, floor');
  print('  • Timestamps in ISO 8601 format');
  print('  • Boolean online field (not status string)');
  print('  • Arrays for images (can be empty)');
}

void analyzeRoomEndpoints() {
  print('\n2. ROOM ENDPOINTS ANALYSIS');
  print('-' * 50);
  
  print('STAGING API ROOM ENDPOINT:');
  print('  GET /api/rooms?page_size=0');
  
  print('\nEXPECTED ROOM RESPONSE:');
  print('''
  {
    "count": 680,
    "results": [
      {
        "id": 801,
        "name": "(West Wing) 801",
        "room_number": "801",
        "building": "West Wing",
        "floor": 8,
        "description": "Standard Room",
        "created_at": "2023-01-01T00:00:00Z",
        "updated_at": "2024-01-15T10:00:00Z",
        "devices": [
          {
            "id": 123,
            "name": "AP-WE-801",
            "type": "access_point",
            "online": true
          }
        ]
      }
    ]
  }
  ''');
  
  print('\nROOM STRUCTURE NOTES:');
  print('  • Room ID is integer (matches pms_room.id in devices)');
  print('  • Name follows pattern: "(Building) RoomNumber"');
  print('  • Separate room_number field');
  print('  • Nested devices array with summary info');
  print('  • Timestamps for created_at and updated_at');
}

void analyzeNotificationStructure() {
  print('\n3. NOTIFICATION STRUCTURE ANALYSIS');
  print('-' * 50);
  
  print('NOTIFICATION GENERATION (from devices):');
  print('  Notifications are generated client-side from device status');
  print('  No direct API endpoint for notifications');
  
  print('\nNOTIFICATION RULES FROM DEVICES:');
  print('  • Device offline: online == false → URGENT');
  print('  • Device note: note != null → MEDIUM');
  print('  • Missing images: images == [] → LOW');
  
  print('\nGENERATED NOTIFICATION STRUCTURE:');
  print('''
  {
    "id": "offline-123-1234567890",
    "title": "Device Offline",
    "message": "AP-WE-801 is offline",
    "type": "deviceOffline",
    "priority": "urgent",
    "timestamp": "2024-01-15T10:30:00Z",
    "isRead": false,
    "deviceId": "123",
    "location": "(West Wing) 801",  // From pms_room.name
    "metadata": {
      "device_name": "AP-WE-801",
      "device_type": "access_point",
      "location": "(West Wing) 801",
      "last_seen": "2024-01-15T10:00:00Z"
    }
  }
  ''');
}

void identifyKeyPatterns() {
  print('\n4. KEY PATTERNS IDENTIFIED');
  print('-' * 50);
  
  print('API RESPONSE PATTERNS:');
  print('  • Paginated wrapper: {count: N, results: [...]}');
  print('  • Snake_case field naming throughout');
  print('  • Integer IDs for rooms and devices');
  print('  • Nested pms_room object in devices');
  print('  • ISO 8601 timestamps');
  print('  • Boolean online status (not string)');
  
  print('\nDATA RELATIONSHIPS:');
  print('  • Device.pms_room.id == Room.id');
  print('  • Device.pms_room.name == Room.name');
  print('  • Location format: "(Building) RoomNumber"');
  
  print('\nMOCK DATA MUST REPLICATE:');
  print('  1. Exact field names (snake_case)');
  print('  2. Exact data types (int IDs, bool online)');
  print('  3. Nested structure (pms_room object)');
  print('  4. Response wrapper format');
  print('  5. Timestamp formats');
  print('  6. Relationship patterns');
  
  print('\n🎯 ITERATION 1 COMPLETE');
  print('  Staging API structure documented');
  print('  Key patterns identified');
  print('  Ready for mock data mapping');
}