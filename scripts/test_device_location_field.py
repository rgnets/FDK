#!/usr/bin/env python3
"""
Test script to check what the API returns for device.location field
"""

import requests
import json
from typing import Dict, List, Any, Optional
import sys

# API Configuration
API_BASE_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def test_devices_api():
    """Test the devices API and check location field"""
    
    print("=" * 80)
    print("TESTING DEVICE LOCATION FIELD FROM API")
    print("=" * 80)
    
    # Prepare headers with Bearer token
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Test devices endpoint
    devices_url = f"{API_BASE_URL}/api/devices"
    print(f"\nTesting: GET {devices_url}")
    print("Headers: Authorization: Bearer [TOKEN]")
    
    # Initialize counters
    null_count = 0
    empty_count = 0
    numeric_count = 0
    text_count = 0
    unique_locations = set()
    
    try:
        response = requests.get(devices_url, headers=headers, timeout=10)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            # Handle both list and dict responses
            devices = []
            if isinstance(data, list):
                devices = data
            elif isinstance(data, dict):
                # Check for common keys that might contain the device list
                if 'devices' in data:
                    devices = data['devices']
                elif 'data' in data:
                    devices = data['data']
                elif 'items' in data:
                    devices = data['items']
                else:
                    # Print the structure to understand it
                    print(f"\nResponse is a dict with keys: {list(data.keys())}")
                    
                    # Check if it's a paginated response
                    if 'results' in data:
                        devices = data['results']
                    elif 'content' in data:
                        devices = data['content']
                    else:
                        # Maybe the dict itself contains device data
                        # Let's see what's in it
                        print("\nFirst 3 keys and their types:")
                        for key in list(data.keys())[:3]:
                            value_type = type(data[key]).__name__
                            print(f"  {key}: {value_type}")
                            if isinstance(data[key], dict):
                                device_keys = list(data[key].keys()) if isinstance(data[key], dict) else []
                                print(f"    Sub-keys: {device_keys[:5]}")
                        
                        # Try to extract devices if they're in a nested structure
                        for key, value in data.items():
                            if isinstance(value, list) and len(value) > 0:
                                # Found a list, might be devices
                                first_item = value[0]
                                if isinstance(first_item, dict) and 'id' in first_item:
                                    print(f"\nFound device list in key '{key}'")
                                    devices = value
                                    break
            
            if devices and isinstance(devices, list):
                print(f"\nFound {len(devices)} devices")
                
                # Analyze location field in first 5 devices
                print("\n" + "=" * 80)
                print("LOCATION FIELD ANALYSIS")
                print("=" * 80)
                
                location_samples = []
                
                for i, device in enumerate(devices[:10]):  # Check first 10 devices
                    device_id = device.get('id', 'unknown')
                    device_name = device.get('name', 'unknown')
                    location = device.get('location')
                    pms_room_id = device.get('pms_room_id')
                    
                    location_samples.append({
                        'id': device_id,
                        'name': device_name,
                        'location': location,
                        'pms_room_id': pms_room_id
                    })
                    
                    if location is not None:
                        unique_locations.add(str(location))
                
                # Print samples
                print("\nSample devices with location field:")
                for sample in location_samples:
                    print(f"\nDevice ID: {sample['id']}")
                    print(f"  Name: {sample['name']}")
                    print(f"  location: {repr(sample['location'])} (type: {type(sample['location']).__name__})")
                    print(f"  pms_room_id: {sample['pms_room_id']}")
                
                # Analyze location patterns
                print("\n" + "=" * 80)
                print("LOCATION VALUE PATTERNS")
                print("=" * 80)
                
                # Check all devices for location patterns
                for device in devices:
                    location = device.get('location')
                    
                    if location is None:
                        null_count += 1
                    elif location == "":
                        empty_count += 1
                    elif isinstance(location, (int, float)):
                        numeric_count += 1
                        unique_locations.add(str(location))
                    elif isinstance(location, str):
                        if location.strip() == "":
                            empty_count += 1
                        elif location.isdigit():
                            numeric_count += 1
                            unique_locations.add(location)
                        else:
                            text_count += 1
                            unique_locations.add(location)
                
                print(f"\nLocation field statistics:")
                print(f"  null: {null_count}")
                print(f"  empty string: {empty_count}")
                print(f"  numeric: {numeric_count}")
                print(f"  text: {text_count}")
                
                if unique_locations:
                    print(f"\nUnique location values (first 10):")
                    for loc in list(unique_locations)[:10]:
                        print(f"  - {repr(loc)}")
                
                # Check relationship with pms_room_id
                print("\n" + "=" * 80)
                print("LOCATION vs PMS_ROOM_ID RELATIONSHIP")
                print("=" * 80)
                
                matches = 0
                mismatches = 0
                
                for device in devices:
                    location = device.get('location')
                    pms_room_id = device.get('pms_room_id')
                    
                    if location is not None and pms_room_id is not None:
                        if str(location) == str(pms_room_id):
                            matches += 1
                        else:
                            mismatches += 1
                
                print(f"\nRelationship analysis:")
                print(f"  location == pms_room_id: {matches}")
                print(f"  location != pms_room_id: {mismatches}")
                
            else:
                print(f"Could not extract device list from response")
                print(f"Response type: {type(data)}")
                if isinstance(data, dict):
                    print(f"Response keys: {list(data.keys())}")
                
        else:
            print(f"Error response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return 1
    
    print("\n" + "=" * 80)
    print("CONCLUSION")
    print("=" * 80)
    print("\nBased on the API response, device.location field is:")
    if null_count > 0:
        print(f"  - {null_count} devices have null location")
    if empty_count > 0:
        print(f"  - {empty_count} devices have empty string location")
    if numeric_count > 0:
        print(f"  - {numeric_count} devices have numeric location")
    if text_count > 0:
        print(f"  - {text_count} devices have text location")
    
    return 0

def test_rooms_api():
    """Test rooms API to see room format"""
    
    print("\n" + "=" * 80)
    print("TESTING ROOMS API")
    print("=" * 80)
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    rooms_url = f"{API_BASE_URL}/api/rooms"
    print(f"\nTesting: GET {rooms_url}")
    
    try:
        response = requests.get(rooms_url, headers=headers, timeout=10)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            # Handle both list and dict responses
            rooms = []
            if isinstance(data, list):
                rooms = data
            elif isinstance(data, dict):
                # Check for common keys
                if 'rooms' in data:
                    rooms = data['rooms']
                elif 'data' in data:
                    rooms = data['data']
                elif 'items' in data:
                    rooms = data['items']
                else:
                    print(f"Response is a dict with keys: {list(data.keys())}")
            
            if rooms and isinstance(rooms, list):
                print(f"\nFound {len(rooms)} rooms")
                
                # Check first 5 rooms
                print("\nSample rooms:")
                for room in rooms[:5]:
                    room_id = room.get('id')
                    room_name = room.get('name')
                    print(f"  Room ID: {repr(room_id)}, Name: {repr(room_name)}")
            else:
                print(f"Could not extract room list from response")
                
        else:
            print(f"Error response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

if __name__ == "__main__":
    exit_code = test_devices_api()
    test_rooms_api()
    sys.exit(exit_code)