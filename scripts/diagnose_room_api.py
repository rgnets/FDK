#!/usr/bin/env python3
import requests
import json
import base64
import os
from typing import Dict, List, Any

# Read environment variables or use defaults
API_BASE_URL = os.getenv('API_BASE_URL', 'https://iot.sysadmin.homes')
API_USERNAME = os.getenv('API_USERNAME', 'admin@sysadmin.homes')
API_KEY = os.getenv('API_KEY', '10e3606b68cd40b92c0bb0bd073fbc1ebedd8912bf854ad0bd8a92e02dda8854')

def get_auth_headers():
    """Generate authentication headers"""
    auth_string = f"{API_USERNAME}:{API_KEY}"
    auth_bytes = auth_string.encode('utf-8')
    auth_b64 = base64.b64encode(auth_bytes).decode('ascii')
    
    return {
        'Authorization': f'Basic {auth_b64}',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }

def fetch_all_rooms():
    """Fetch all rooms from API"""
    print("Fetching all rooms...")
    headers = get_auth_headers()
    all_rooms = []
    page = 1
    
    while True:
        try:
            response = requests.get(
                f"{API_BASE_URL}/api/pms_rooms.json?page={page}",
                headers=headers,
                timeout=30
            )
            response.raise_for_status()
            data = response.json()
            
            if 'results' in data and data['results']:
                all_rooms.extend(data['results'])
                print(f"  Page {page}: Got {len(data['results'])} rooms")
                page += 1
            else:
                break
                
        except Exception as e:
            print(f"Error fetching page {page}: {e}")
            break
    
    return all_rooms

def fetch_room_details(room_id: str):
    """Fetch detailed info for a specific room"""
    headers = get_auth_headers()
    
    try:
        response = requests.get(
            f"{API_BASE_URL}/api/pms_rooms/{room_id}.json",
            headers=headers,
            timeout=30
        )
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"Error fetching room {room_id} details: {e}")
        return None

def extract_device_ids(room_data: Dict[str, Any]) -> List[str]:
    """Extract all device IDs from room data"""
    device_ids = set()
    
    # Extract access points
    if 'access_points' in room_data and room_data['access_points']:
        for ap in room_data['access_points']:
            if isinstance(ap, dict) and 'id' in ap:
                device_ids.add(str(ap['id']))
    
    # Extract media converters
    if 'media_converters' in room_data and room_data['media_converters']:
        for mc in room_data['media_converters']:
            if isinstance(mc, dict) and 'id' in mc:
                device_ids.add(str(mc['id']))
    
    # Extract infrastructure devices
    if 'infrastructure_devices' in room_data and room_data['infrastructure_devices']:
        for device in room_data['infrastructure_devices']:
            if isinstance(device, dict) and 'id' in device:
                device_ids.add(str(device['id']))
    
    return list(device_ids)

def main():
    print("=== DIAGNOSING ROOM 203 AND 411 DATA ISSUE ===\n")
    print(f"API Base URL: {API_BASE_URL}")
    print(f"Username: {API_USERNAME}\n")
    
    # Fetch all rooms
    all_rooms = fetch_all_rooms()
    print(f"\nTotal rooms fetched: {len(all_rooms)}\n")
    
    # Find rooms 203 and 411
    room_203 = None
    room_411 = None
    
    for room in all_rooms:
        room_name = room.get('room', room.get('name', ''))
        room_id = str(room.get('id', ''))
        
        if '203' in room_name or room_id == '203':
            room_203 = room
            print(f"Found Room 203:")
            print(f"  ID: {room_id}")
            print(f"  Name: {room_name}")
            print(f"  Building: {room.get('building', 'N/A')}")
            print(f"  Floor: {room.get('floor', 'N/A')}")
            device_ids = extract_device_ids(room)
            print(f"  Device IDs: {device_ids}")
            print(f"  Device Count: {len(device_ids)}\n")
        
        if '411' in room_name or room_id == '411':
            room_411 = room
            print(f"Found Room 411:")
            print(f"  ID: {room_id}")
            print(f"  Name: {room_name}")
            print(f"  Building: {room.get('building', 'N/A')}")
            print(f"  Floor: {room.get('floor', 'N/A')}")
            device_ids = extract_device_ids(room)
            print(f"  Device IDs: {device_ids}")
            print(f"  Device Count: {len(device_ids)}\n")
    
    if not room_203:
        print("WARNING: Room 203 not found!\n")
    if not room_411:
        print("WARNING: Room 411 not found!\n")
    
    # Check for overlapping devices
    if room_203 and room_411:
        print("Checking for overlapping device IDs...")
        room_203_devices = set(extract_device_ids(room_203))
        room_411_devices = set(extract_device_ids(room_411))
        overlap = room_203_devices.intersection(room_411_devices)
        
        if overlap:
            print(f"⚠️ FOUND {len(overlap)} OVERLAPPING DEVICES between Room 203 and 411:")
            for device_id in overlap:
                print(f"  - Device ID: {device_id}")
        else:
            print("✓ No overlapping device IDs found\n")
    
    # Fetch detailed info for each room
    if room_203:
        room_203_id = str(room_203['id'])
        print(f"\nFetching detailed info for Room 203 (ID: {room_203_id})...")
        details = fetch_room_details(room_203_id)
        
        if details:
            print("Room 203 Detailed Info:")
            print(f"  Room ID: {details.get('id')}")
            print(f"  Room Name: {details.get('room', details.get('name', 'N/A'))}")
            
            # Show devices
            aps = details.get('access_points', [])
            mcs = details.get('media_converters', [])
            ports = details.get('switch_ports', [])
            
            print(f"  Access Points ({len(aps)}):")
            for ap in aps[:5]:  # Show first 5
                print(f"    - ID: {ap.get('id')}, Name: {ap.get('name', 'N/A')}")
            if len(aps) > 5:
                print(f"    ... and {len(aps) - 5} more")
            
            print(f"  Media Converters ({len(mcs)}):")
            for mc in mcs[:5]:
                print(f"    - ID: {mc.get('id')}, Name: {mc.get('name', 'N/A')}")
            if len(mcs) > 5:
                print(f"    ... and {len(mcs) - 5} more")
            
            print(f"  Switch Ports ({len(ports)}):")
            for port in ports[:5]:
                print(f"    - ID: {port.get('id')}, Name: {port.get('name', 'N/A')}")
            if len(ports) > 5:
                print(f"    ... and {len(ports) - 5} more")
    
    if room_411:
        room_411_id = str(room_411['id'])
        print(f"\nFetching detailed info for Room 411 (ID: {room_411_id})...")
        details = fetch_room_details(room_411_id)
        
        if details:
            print("Room 411 Detailed Info:")
            print(f"  Room ID: {details.get('id')}")
            print(f"  Room Name: {details.get('room', details.get('name', 'N/A'))}")
            
            # Show devices
            aps = details.get('access_points', [])
            mcs = details.get('media_converters', [])
            ports = details.get('switch_ports', [])
            
            print(f"  Access Points ({len(aps)}):")
            for ap in aps[:5]:
                print(f"    - ID: {ap.get('id')}, Name: {ap.get('name', 'N/A')}")
            if len(aps) > 5:
                print(f"    ... and {len(aps) - 5} more")
            
            print(f"  Media Converters ({len(mcs)}):")
            for mc in mcs[:5]:
                print(f"    - ID: {mc.get('id')}, Name: {mc.get('name', 'N/A')}")
            if len(mcs) > 5:
                print(f"    ... and {len(mcs) - 5} more")
            
            print(f"  Switch Ports ({len(ports)}):")
            for port in ports[:5]:
                print(f"    - ID: {port.get('id')}, Name: {port.get('name', 'N/A')}")
            if len(ports) > 5:
                print(f"    ... and {len(ports) - 5} more")
    
    # Check if device IDs appear in wrong rooms
    if room_203 and room_411:
        print("\n=== CROSS-CHECKING DEVICE ASSIGNMENTS ===")
        
        # Check if any Room 203 devices are incorrectly showing in Room 411 data
        room_203_details = fetch_room_details(str(room_203['id']))
        room_411_details = fetch_room_details(str(room_411['id']))
        
        if room_203_details and room_411_details:
            room_203_all_devices = extract_device_ids(room_203_details)
            room_411_all_devices = extract_device_ids(room_411_details)
            
            print(f"\nRoom 203 has {len(room_203_all_devices)} total devices")
            print(f"Room 411 has {len(room_411_all_devices)} total devices")
            
            # Check for duplicates
            duplicates = set(room_203_all_devices).intersection(set(room_411_all_devices))
            if duplicates:
                print(f"\n⚠️ CRITICAL: Found {len(duplicates)} devices assigned to BOTH rooms!")
                print("This is likely the cause of the cross-room data display issue.")
                print("Duplicate device IDs:")
                for device_id in list(duplicates)[:10]:  # Show first 10
                    print(f"  - {device_id}")
                if len(duplicates) > 10:
                    print(f"  ... and {len(duplicates) - 10} more")
            else:
                print("\n✓ No duplicate device assignments found between rooms")
    
    print("\n=== DIAGNOSIS COMPLETE ===")

if __name__ == "__main__":
    main()