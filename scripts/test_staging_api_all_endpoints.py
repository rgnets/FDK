#!/usr/bin/env python3
"""
Test all staging API endpoints with page_size=0
Analyzes access_points, media_converters, switches, and rooms
"""

import requests
import json
import sys
from typing import Dict, List, Any, Optional, Set

# Staging API Configuration
API_BASE_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def print_section(title: str):
    """Print a formatted section header"""
    print("\n" + "=" * 80)
    print(title)
    print("=" * 80)

def analyze_pms_room(devices: List[Dict], endpoint_name: str) -> Dict:
    """Analyze pms_room structure in devices"""
    analysis = {
        'has_pms_room': 0,
        'no_pms_room': 0,
        'unique_rooms': set(),
        'room_samples': [],
        'devices_by_room': {}
    }
    
    for device in devices:
        if 'pms_room' in device and device['pms_room']:
            analysis['has_pms_room'] += 1
            pms_room = device['pms_room']
            
            # Track unique rooms
            if isinstance(pms_room, dict):
                room_id = pms_room.get('id')
                room_name = pms_room.get('name', 'Unknown')
                if room_id:
                    analysis['unique_rooms'].add((room_id, room_name))
                    
                    # Group devices by room
                    if room_id not in analysis['devices_by_room']:
                        analysis['devices_by_room'][room_id] = {
                            'name': room_name,
                            'devices': []
                        }
                    analysis['devices_by_room'][room_id]['devices'].append({
                        'id': device.get('id'),
                        'name': device.get('name'),
                        'type': endpoint_name
                    })
                
                # Collect samples
                if len(analysis['room_samples']) < 3:
                    analysis['room_samples'].append({
                        'device_id': device.get('id'),
                        'device_name': device.get('name'),
                        'pms_room': pms_room
                    })
        else:
            analysis['no_pms_room'] += 1
    
    return analysis

def test_endpoint(endpoint: str, display_name: str) -> Optional[List[Dict]]:
    """Test a specific API endpoint"""
    print_section(f"TESTING {display_name.upper()}")
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    url = f"{API_BASE_URL}/api/{endpoint}?page_size=0"
    print(f"Endpoint: GET {url}")
    
    try:
        print("Sending request...")
        response = requests.get(url, headers=headers, timeout=30)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 404:
            print(f"⚠️  Endpoint not found: /api/{endpoint}")
            return None
        
        if response.status_code != 200:
            print(f"Error: {response.status_code}")
            print(f"Response: {response.text[:500]}")
            return None
        
        data = response.json()
        
        # Handle different response formats
        if isinstance(data, list):
            devices = data
            print(f"Response type: LIST")
            print(f"Total items: {len(devices)}")
        elif isinstance(data, dict):
            # Try common patterns
            if 'results' in data:
                devices = data['results']
            elif 'data' in data:
                devices = data['data']
            elif 'items' in data:
                devices = data['items']
            else:
                print(f"Response type: DICT with keys: {list(data.keys())}")
                devices = []
        else:
            print(f"Unexpected response type: {type(data)}")
            return None
        
        if not devices:
            print("No items returned")
            return []
        
        # Analyze first device structure
        print(f"\n--- First {display_name} Structure ---")
        first = devices[0]
        for key in sorted(first.keys()):
            value = first[key]
            if isinstance(value, dict):
                print(f"  {key}: <object>")
                if key == 'pms_room':
                    for sub_key, sub_val in value.items():
                        print(f"    {sub_key}: {repr(sub_val)}")
            elif isinstance(value, list):
                print(f"  {key}: <array> ({len(value)} items)")
            else:
                value_str = repr(value) if len(repr(value)) < 50 else repr(value)[:50] + "..."
                print(f"  {key}: {value_str}")
        
        # Analyze pms_room presence
        analysis = analyze_pms_room(devices, endpoint)
        
        print(f"\n--- PMS Room Analysis ---")
        print(f"Devices with pms_room: {analysis['has_pms_room']}/{len(devices)}")
        print(f"Devices without pms_room: {analysis['no_pms_room']}/{len(devices)}")
        print(f"Unique rooms found: {len(analysis['unique_rooms'])}")
        
        if analysis['room_samples']:
            print(f"\n--- Sample pms_room Objects ---")
            for sample in analysis['room_samples']:
                print(f"Device: {sample['device_name']} (ID: {sample['device_id']})")
                print(f"  pms_room: {json.dumps(sample['pms_room'], indent=4)}")
        
        if analysis['unique_rooms']:
            print(f"\n--- Unique Rooms ---")
            for room_id, room_name in sorted(analysis['unique_rooms'], key=lambda x: x[0]):
                device_count = len(analysis['devices_by_room'][room_id]['devices'])
                print(f"  Room {room_id}: {room_name} ({device_count} devices)")
        
        return devices
        
    except requests.RequestException as e:
        print(f"Request error: {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"JSON error: {e}")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return None

def test_rooms_endpoint():
    """Test the rooms endpoint specifically"""
    print_section("TESTING ROOMS ENDPOINT")
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    url = f"{API_BASE_URL}/api/rooms?page_size=0"
    print(f"Endpoint: GET {url}")
    
    try:
        print("Sending request...")
        response = requests.get(url, headers=headers, timeout=30)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 404:
            print("⚠️  Rooms endpoint not found")
            return None
        
        if response.status_code != 200:
            print(f"Error: {response.status_code}")
            return None
        
        data = response.json()
        
        if isinstance(data, list):
            rooms = data
        elif isinstance(data, dict) and 'results' in data:
            rooms = data['results']
        else:
            print("Could not parse rooms response")
            return None
        
        print(f"Total rooms: {len(rooms)}")
        
        if rooms:
            print("\n--- Sample Rooms ---")
            for room in rooms[:5]:
                print(f"  ID: {room.get('id')}, Name: {room.get('name')}")
        
        return rooms
        
    except Exception as e:
        print(f"Error: {e}")
        return None

def main():
    print_section("STAGING API - COMPLETE ENDPOINT ANALYSIS")
    
    # Test all device endpoints
    all_results = {}
    
    # Test each endpoint
    endpoints = [
        ('access_points', 'Access Points'),
        ('media_converters', 'Media Converters (ONTs)'),
        ('switch_devices', 'Switches'),
        ('wlan_devices', 'WLAN Devices')
    ]
    
    for endpoint, display_name in endpoints:
        result = test_endpoint(endpoint, display_name)
        all_results[endpoint] = result
    
    # Test rooms
    rooms = test_rooms_endpoint()
    all_results['rooms'] = rooms
    
    # Aggregate analysis
    print_section("AGGREGATE ANALYSIS")
    
    # Collect all devices with pms_room
    all_devices_with_rooms = []
    room_mapping = {}
    
    for endpoint, devices in all_results.items():
        if devices and endpoint != 'rooms':
            for device in devices:
                if 'pms_room' in device and device['pms_room']:
                    pms_room = device['pms_room']
                    if isinstance(pms_room, dict):
                        room_id = pms_room.get('id')
                        room_name = pms_room.get('name')
                        
                        all_devices_with_rooms.append({
                            'device_id': device.get('id'),
                            'device_name': device.get('name'),
                            'device_type': endpoint,
                            'room_id': room_id,
                            'room_name': room_name
                        })
                        
                        if room_id not in room_mapping:
                            room_mapping[room_id] = {
                                'name': room_name,
                                'access_points': 0,
                                'media_converters': 0,
                                'switch_devices': 0,
                                'wlan_devices': 0
                            }
                        room_mapping[room_id][endpoint] += 1
    
    print(f"\nTotal devices with pms_room: {len(all_devices_with_rooms)}")
    print(f"Total unique rooms: {len(room_mapping)}")
    
    if room_mapping:
        print("\n--- Room Device Distribution ---")
        for room_id in sorted(room_mapping.keys())[:10]:  # Show first 10 rooms
            room = room_mapping[room_id]
            print(f"\nRoom {room_id}: {room['name']}")
            print(f"  Access Points: {room['access_points']}")
            print(f"  Media Converters: {room['media_converters']}")
            print(f"  Switches: {room['switch_devices']}")
            print(f"  WLAN Devices: {room['wlan_devices']}")
    
    print_section("PLAN FOR ROOM ASSIGNMENT")
    
    print("\n1. DATA AVAILABILITY:")
    for endpoint, result in all_results.items():
        if result is not None:
            status = "✓ Available" if result else "✗ No data"
            if endpoint != 'rooms' and result:
                with_room = sum(1 for d in result if 'pms_room' in d and d['pms_room'])
                print(f"   {endpoint}: {status} ({len(result)} items, {with_room} with pms_room)")
            elif endpoint == 'rooms':
                print(f"   {endpoint}: {status} ({len(result) if result else 0} items)")
        else:
            print(f"   {endpoint}: ✗ Endpoint not found")
    
    print("\n2. PMS_ROOM STRUCTURE:")
    print("   When present, pms_room contains:")
    print("   {")
    print('     "id": <integer>,')
    print('     "name": "<string>"')
    print("   }")
    
    print("\n3. ROOM ASSIGNMENT STRATEGY:")
    if any(r and any('pms_room' in d and d['pms_room'] for d in r) 
           for r in all_results.values() if r and r != rooms):
        print("   ✓ Use pms_room.id from device objects to assign devices to rooms")
        print("   ✓ pms_room.name provides human-readable room identifier")
        print("   ✓ Devices without pms_room have no room assignment")
    else:
        print("   ✗ No pms_room data found in any device endpoint")
        print("   ✗ Cannot determine room assignments from API data")
    
    print("\n4. MOCK DATA COMPATIBILITY:")
    print("   To match API structure, mock data should:")
    print("   - Include pms_room object with id and name for devices in rooms")
    print("   - Set pms_room to null for devices not in rooms")
    print("   - Use integer IDs matching room IDs")
    print("   - Use string names in format '(Building) Room'")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())