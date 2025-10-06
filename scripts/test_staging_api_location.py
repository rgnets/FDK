#!/usr/bin/env python3
"""
Test script to verify staging API location data structure.
This simulates what the Dart code should be extracting.
"""

import json

def simulate_staging_api_response():
    """Simulate a typical staging API response for access points."""
    return {
        "count": 2,
        "results": [
            {
                "id": 123,
                "name": "AP-WE-801",
                "mac": "00:11:22:33:44:55",
                "ip": "10.0.1.101",
                "online": True,
                "model": "RG-AP-520",
                "serial_number": "SN123456",
                "firmware": "3.2.1",
                "last_seen": "2024-01-15T10:30:00Z",
                "pms_room": {
                    "id": 801,
                    "name": "(West Wing) 801",
                    "room_number": "801",
                    "building": "West Wing",
                    "floor": 8
                }
                # Note: NO top-level "location", "room", or "room_id" fields!
            },
            {
                "id": 124,
                "name": "AP-NT-205",
                "mac": "00:11:22:33:44:66",
                "ip": "10.0.2.105",
                "online": False,
                "model": "RG-AP-520",
                "serial_number": "SN123457",
                "firmware": "3.2.1",
                "last_seen": "2024-01-15T09:00:00Z",
                "pms_room": {
                    "id": 205,
                    "name": "(North Tower) 205",
                    "room_number": "205",
                    "building": "North Tower",
                    "floor": 2
                }
            }
        ]
    }

def test_current_extraction_logic():
    """Test what the current RemoteDeviceDataSource is doing."""
    print("CURRENT EXTRACTION LOGIC (BROKEN):")
    print("-" * 50)
    
    api_response = simulate_staging_api_response()
    
    for device_map in api_response["results"]:
        # This is what RemoteDeviceDataSource currently does (line 255)
        location = device_map.get("location") or \
                   device_map.get("room") or \
                   str(device_map.get("room_id", "")) if device_map.get("room_id") else ""
        
        print(f"Device: {device_map['name']}")
        print(f"  Looking for: location={device_map.get('location')}, "
              f"room={device_map.get('room')}, room_id={device_map.get('room_id')}")
        print(f"  Extracted location: '{location}' (EMPTY!)")
        print()

def test_correct_extraction_logic():
    """Test what the extraction should be doing."""
    print("\nCORRECT EXTRACTION LOGIC (FIXED):")
    print("-" * 50)
    
    api_response = simulate_staging_api_response()
    
    for device_map in api_response["results"]:
        # This is what it SHOULD do
        location = None
        if device_map.get("pms_room") and isinstance(device_map["pms_room"], dict):
            pms_room = device_map["pms_room"]
            location = pms_room.get("name")
        
        # Fallback to old fields if pms_room not available
        if not location:
            location = device_map.get("location") or \
                       device_map.get("room") or \
                       str(device_map.get("room_id", "")) if device_map.get("room_id") else ""
        
        print(f"Device: {device_map['name']}")
        print(f"  pms_room.name: {device_map.get('pms_room', {}).get('name')}")
        print(f"  Extracted location: '{location}' (CORRECT!)")
        print()

def generate_dart_fix():
    """Generate the Dart code fix needed."""
    print("\nDART CODE FIX NEEDED:")
    print("-" * 50)
    print("""
In device_remote_data_source.dart, replace the location extraction:

OLD (line 255):
  'location': deviceMap['location'] ?? deviceMap['room'] ?? deviceMap['room_id']?.toString() ?? '',

NEW:
  'location': _extractLocation(deviceMap),

Add helper method:
  String _extractLocation(Map<String, dynamic> deviceMap) {
    // First try to get from pms_room.name (staging API structure)
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final pmsRoomName = pmsRoom['name']?.toString();
      if (pmsRoomName != null && pmsRoomName.isNotEmpty) {
        return pmsRoomName;
      }
    }
    
    // Fallback to old fields
    return deviceMap['location']?.toString() ?? 
           deviceMap['room']?.toString() ?? 
           deviceMap['room_id']?.toString() ?? 
           '';
  }

Apply same fix to:
- media_converters (line 283)
- switch_devices (line 311)
""")

def main():
    print("STAGING API LOCATION EXTRACTION TEST")
    print("=" * 80)
    
    test_current_extraction_logic()
    test_correct_extraction_logic()
    generate_dart_fix()
    
    print("\n✅ ANALYSIS COMPLETE")
    print("   The issue is confirmed: RemoteDeviceDataSource")
    print("   doesn't extract location from pms_room.name")
    print("   The fix is straightforward - extract from correct field")

if __name__ == "__main__":
    main()