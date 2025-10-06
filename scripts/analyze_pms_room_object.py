#!/usr/bin/env python3
"""
Analyze the pms_room object structure in devices to understand how to filter correctly
"""

import requests
import json
import warnings
from collections import defaultdict
from typing import Dict, List, Any

warnings.filterwarnings('ignore')

# API configuration
API_BASE_URL = 'https://vgw1-01.dal-interurban.mdu.attwifi.com'
API_KEY = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'

def get_headers():
    return {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json',
    }

def fetch_all_devices() -> Dict[str, List[Dict]]:
    """Fetch all access points and media converters"""
    print("Fetching all devices from API...")
    
    devices = {
        'access_points': [],
        'media_converters': []
    }
    
    # Fetch all access points
    page = 1
    while True:
        response = requests.get(
            f"{API_BASE_URL}/api/access_points.json?page={page}",
            headers=get_headers(),
            timeout=30,
            verify=False
        )
        if response.status_code != 200:
            break
        data = response.json()
        if not data.get('results'):
            break
        devices['access_points'].extend(data['results'])
        print(f"  Fetched {len(data['results'])} APs from page {page}")
        page += 1
        if page > data.get('total_pages', 1):
            break
    
    # Fetch all media converters
    page = 1
    while True:
        response = requests.get(
            f"{API_BASE_URL}/api/media_converters.json?page={page}",
            headers=get_headers(),
            timeout=30,
            verify=False
        )
        if response.status_code != 200:
            break
        data = response.json()
        if not data.get('results'):
            break
        devices['media_converters'].extend(data['results'])
        print(f"  Fetched {len(data['results'])} MCs from page {page}")
        page += 1
        if page > data.get('total_pages', 1):
            break
    
    print(f"\nTotal devices fetched:")
    print(f"  Access Points: {len(devices['access_points'])}")
    print(f"  Media Converters: {len(devices['media_converters'])}")
    
    return devices

def analyze_pms_room_structure(devices: Dict[str, List[Dict]]):
    """Analyze the structure of pms_room objects in devices"""
    print("\n" + "="*60)
    print("ANALYZING PMS_ROOM OBJECT STRUCTURE")
    print("="*60)
    
    # Track different structures we find
    ap_structures = defaultdict(int)
    mc_structures = defaultdict(int)
    
    # Analyze access points
    print("\n--- Access Points Analysis ---")
    aps_with_pms_room = 0
    aps_without_pms_room = 0
    ap_pms_room_examples = []
    
    for ap in devices['access_points']:
        if 'pms_room' in ap and ap['pms_room'] is not None:
            aps_with_pms_room += 1
            # Record the structure
            if isinstance(ap['pms_room'], dict):
                structure = tuple(sorted(ap['pms_room'].keys()))
                ap_structures[structure] += 1
                if len(ap_pms_room_examples) < 3:
                    ap_pms_room_examples.append({
                        'device_name': ap.get('name', 'N/A'),
                        'device_id': ap.get('id', 'N/A'),
                        'pms_room': ap['pms_room']
                    })
            else:
                ap_structures[f"Non-dict: {type(ap['pms_room']).__name__}"] += 1
        else:
            aps_without_pms_room += 1
    
    print(f"  APs with pms_room: {aps_with_pms_room}")
    print(f"  APs without pms_room: {aps_without_pms_room}")
    
    if ap_structures:
        print(f"\n  pms_room structures found in APs:")
        for structure, count in ap_structures.items():
            print(f"    {structure}: {count} occurrences")
    
    if ap_pms_room_examples:
        print(f"\n  Sample AP pms_room objects:")
        for example in ap_pms_room_examples:
            print(f"    Device: {example['device_name']} (ID: {example['device_id']})")
            print(f"      pms_room: {json.dumps(example['pms_room'], indent=8)}")
    
    # Analyze media converters
    print("\n--- Media Converters Analysis ---")
    mcs_with_pms_room = 0
    mcs_without_pms_room = 0
    mc_pms_room_examples = []
    
    for mc in devices['media_converters']:
        if 'pms_room' in mc and mc['pms_room'] is not None:
            mcs_with_pms_room += 1
            # Record the structure
            if isinstance(mc['pms_room'], dict):
                structure = tuple(sorted(mc['pms_room'].keys()))
                mc_structures[structure] += 1
                if len(mc_pms_room_examples) < 3:
                    mc_pms_room_examples.append({
                        'device_name': mc.get('name', 'N/A'),
                        'device_id': mc.get('id', 'N/A'),
                        'pms_room': mc['pms_room']
                    })
            else:
                mc_structures[f"Non-dict: {type(mc['pms_room']).__name__}"] += 1
        else:
            mcs_without_pms_room += 1
    
    print(f"  MCs with pms_room: {mcs_with_pms_room}")
    print(f"  MCs without pms_room: {mcs_without_pms_room}")
    
    if mc_structures:
        print(f"\n  pms_room structures found in MCs:")
        for structure, count in mc_structures.items():
            print(f"    {structure}: {count} occurrences")
    
    if mc_pms_room_examples:
        print(f"\n  Sample MC pms_room objects:")
        for example in mc_pms_room_examples:
            print(f"    Device: {example['device_name']} (ID: {example['device_id']})")
            print(f"      pms_room: {json.dumps(example['pms_room'], indent=8)}")
    
    return aps_with_pms_room, aps_without_pms_room, mcs_with_pms_room, mcs_without_pms_room

def check_room_device_correlation(devices: Dict[str, List[Dict]]):
    """Check if pms_room.id correctly correlates with room assignments"""
    print("\n" + "="*60)
    print("CHECKING ROOM-DEVICE CORRELATION")
    print("="*60)
    
    # Build a map of pms_room.id to devices
    room_device_map = defaultdict(list)
    
    for ap in devices['access_points']:
        if 'pms_room' in ap and isinstance(ap['pms_room'], dict) and 'id' in ap['pms_room']:
            room_id = ap['pms_room']['id']
            room_device_map[room_id].append({
                'type': 'AP',
                'name': ap.get('name', 'N/A'),
                'id': ap.get('id', 'N/A'),
                'room_name': ap['pms_room'].get('name', 'N/A')
            })
    
    for mc in devices['media_converters']:
        if 'pms_room' in mc and isinstance(mc['pms_room'], dict) and 'id' in mc['pms_room']:
            room_id = mc['pms_room']['id']
            room_device_map[room_id].append({
                'type': 'MC',
                'name': mc.get('name', 'N/A'),
                'id': mc.get('id', 'N/A'),
                'room_name': mc['pms_room'].get('name', 'N/A')
            })
    
    print(f"\nFound devices assigned to {len(room_device_map)} rooms via pms_room.id")
    
    # Show sample room assignments
    print("\nSample room assignments (first 5 rooms with devices):")
    for i, (room_id, devices_in_room) in enumerate(list(room_device_map.items())[:5]):
        room_name = devices_in_room[0]['room_name'] if devices_in_room else 'Unknown'
        print(f"\n  Room ID {room_id} ({room_name}):")
        print(f"    Total devices: {len(devices_in_room)}")
        for device in devices_in_room[:3]:  # Show first 3 devices
            print(f"      - {device['type']}: {device['name']} (ID: {device['id']})")
        if len(devices_in_room) > 3:
            print(f"      ... and {len(devices_in_room) - 3} more devices")
    
    return room_device_map

def fetch_and_compare_room_apis(room_device_map: Dict[int, List[Dict]]):
    """Compare what the room API returns vs what pms_room.id indicates"""
    print("\n" + "="*60)
    print("COMPARING ROOM API VS PMS_ROOM.ID FILTERING")
    print("="*60)
    
    # Test with specific rooms
    test_rooms = [
        {'room_number': '203', 'api_id': 26},
        {'room_number': '411', 'api_id': 68},
    ]
    
    for room_info in test_rooms:
        room_num = room_info['room_number']
        api_id = room_info['api_id']
        
        print(f"\n--- Testing Room {room_num} (API ID: {api_id}) ---")
        
        # Fetch what the API returns for this room
        response = requests.get(
            f"{API_BASE_URL}/api/pms_rooms/{api_id}.json",
            headers=get_headers(),
            timeout=30,
            verify=False
        )
        
        if response.status_code == 200:
            room_data = response.json()
            api_aps = room_data.get('access_points', [])
            api_mcs = room_data.get('media_converters', [])
            
            print(f"  API returns for room {room_num}:")
            print(f"    Access Points: {len(api_aps)}")
            print(f"    Media Converters: {len(api_mcs)}")
            
            # Get device IDs from API
            api_device_ids = set()
            for ap in api_aps:
                api_device_ids.add(f"AP-{ap.get('id')}")
            for mc in api_mcs:
                api_device_ids.add(f"MC-{mc.get('id')}")
            
            # Check what pms_room.id filtering would give us
            pms_room_devices = room_device_map.get(api_id, [])
            pms_device_ids = set()
            for device in pms_room_devices:
                pms_device_ids.add(f"{device['type']}-{device['id']}")
            
            print(f"\n  pms_room.id filtering would give:")
            print(f"    Total devices: {len(pms_room_devices)}")
            
            # Compare the two approaches
            if api_device_ids == pms_device_ids:
                print(f"\n  ✅ MATCH: API and pms_room.id filtering give same results!")
            else:
                print(f"\n  ❌ MISMATCH: Different results!")
                
                only_in_api = api_device_ids - pms_device_ids
                only_in_pms = pms_device_ids - api_device_ids
                
                if only_in_api:
                    print(f"    Devices only in API response: {only_in_api}")
                if only_in_pms:
                    print(f"    Devices only via pms_room.id: {only_in_pms}")

def main():
    print("="*60)
    print("PMS_ROOM OBJECT ANALYSIS")
    print("="*60)
    
    # Fetch all devices
    devices = fetch_all_devices()
    
    # Analyze pms_room structure
    ap_with, ap_without, mc_with, mc_without = analyze_pms_room_structure(devices)
    
    # Check room-device correlation
    room_device_map = check_room_device_correlation(devices)
    
    # Compare with room API
    fetch_and_compare_room_apis(room_device_map)
    
    # Final summary
    print("\n" + "="*60)
    print("SUMMARY AND RECOMMENDATIONS")
    print("="*60)
    
    total_aps = len(devices['access_points'])
    total_mcs = len(devices['media_converters'])
    
    print(f"\nDevice coverage with pms_room object:")
    print(f"  Access Points: {ap_with}/{total_aps} ({100*ap_with/total_aps:.1f}%) have pms_room")
    print(f"  Media Converters: {mc_with}/{total_mcs} ({100*mc_with/total_mcs:.1f}%) have pms_room")
    
    if ap_with > 0 or mc_with > 0:
        print(f"\n✅ RECOMMENDATION: Use pms_room.id for filtering!")
        print(f"   Instead of looking for 'pms_room_id', use:")
        print(f"   - ap['pms_room']['id'] for access points")
        print(f"   - mc['pms_room']['id'] for media converters")
        print(f"\n   Code change needed in room_repository.dart:")
        print(f"   FROM: final apRoomId = ap['pms_room_id']?.toString();")
        print(f"   TO:   final apRoomId = (ap['pms_room'] as Map?)?['id']?.toString();")
    else:
        print(f"\n❌ WARNING: No devices have pms_room object!")
        print(f"   Cannot use pms_room.id for filtering.")

if __name__ == "__main__":
    main()