#!/usr/bin/env python3
"""
Test for cross-contamination issues and see if pms_room.id filtering would solve them
"""

import requests
import json
import warnings
from typing import Dict, List, Set
import re

warnings.filterwarnings('ignore')

# API configuration
API_BASE_URL = 'https://vgw1-01.dal-interurban.mdu.attwifi.com'
API_KEY = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'

def get_headers():
    return {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json',
    }

def fetch_all_rooms() -> Dict[str, int]:
    """Fetch all rooms and build a map of room_number -> api_id"""
    room_map = {}
    page = 1
    
    print("Fetching all rooms...")
    while True:
        response = requests.get(
            f"{API_BASE_URL}/api/pms_rooms.json?page={page}",
            headers=get_headers(),
            timeout=30,
            verify=False
        )
        if response.status_code != 200:
            break
        data = response.json()
        if not data.get('results'):
            break
        
        for room in data['results']:
            room_number = room.get('room', room.get('name', 'Unknown'))
            room_id = room.get('id')
            room_map[str(room_number)] = room_id
        
        page += 1
        if page > data.get('total_pages', 1):
            break
    
    print(f"  Found {len(room_map)} rooms")
    return room_map

def analyze_room_contamination(room_map: Dict[str, int]) -> Dict[str, Dict]:
    """Analyze each room for device contamination"""
    contamination_report = {}
    
    # Focus on rooms that might have issues
    test_rooms = ['203', '411', '204', '410', '412']  # Add more rooms as needed
    
    # Find these rooms in our map
    rooms_to_check = {}
    for room_num in test_rooms:
        if room_num in room_map:
            rooms_to_check[room_num] = room_map[room_num]
        else:
            print(f"  Room {room_num} not found in system")
    
    print(f"\nAnalyzing {len(rooms_to_check)} rooms for contamination...")
    
    for room_number, room_id in rooms_to_check.items():
        print(f"\n--- Room {room_number} (ID: {room_id}) ---")
        
        response = requests.get(
            f"{API_BASE_URL}/api/pms_rooms/{room_id}.json",
            headers=get_headers(),
            timeout=30,
            verify=False
        )
        
        if response.status_code != 200:
            print(f"  Error fetching room: {response.status_code}")
            continue
        
        room_data = response.json()
        aps = room_data.get('access_points', [])
        mcs = room_data.get('media_converters', [])
        
        # Analyze contamination
        analysis = {
            'room_number': room_number,
            'room_id': room_id,
            'total_aps': len(aps),
            'total_mcs': len(mcs),
            'correct_devices': [],
            'wrong_devices': [],
            'no_room_in_name': [],
            'pms_room_matches': [],
            'pms_room_mismatches': [],
            'no_pms_room': []
        }
        
        # Check each access point
        for ap in aps:
            device_info = {
                'type': 'AP',
                'id': ap.get('id'),
                'name': ap.get('name', 'N/A')
            }
            
            # Check name pattern
            name_match = re.search(r'RM(\d{3})', ap.get('name', ''))
            if name_match:
                suggested_room = name_match.group(1)
                if suggested_room == room_number:
                    analysis['correct_devices'].append(device_info)
                else:
                    device_info['suggested_room'] = suggested_room
                    analysis['wrong_devices'].append(device_info)
            else:
                analysis['no_room_in_name'].append(device_info)
            
            # Check pms_room
            pms_room = ap.get('pms_room')
            if pms_room and isinstance(pms_room, dict):
                pms_room_id = str(pms_room.get('id', ''))
                device_info['pms_room_id'] = pms_room_id
                device_info['pms_room_name'] = pms_room.get('name', 'N/A')
                
                if pms_room_id == str(room_id):
                    analysis['pms_room_matches'].append(device_info)
                else:
                    analysis['pms_room_mismatches'].append(device_info)
            else:
                analysis['no_pms_room'].append(device_info)
        
        # Check each media converter
        for mc in mcs:
            device_info = {
                'type': 'MC',
                'id': mc.get('id'),
                'name': mc.get('name', 'N/A')
            }
            
            # Check name pattern
            name_match = re.search(r'RM(\d{3})', mc.get('name', ''))
            if name_match:
                suggested_room = name_match.group(1)
                if suggested_room == room_number:
                    analysis['correct_devices'].append(device_info)
                else:
                    device_info['suggested_room'] = suggested_room
                    analysis['wrong_devices'].append(device_info)
            else:
                analysis['no_room_in_name'].append(device_info)
            
            # Check pms_room
            pms_room = mc.get('pms_room')
            if pms_room and isinstance(pms_room, dict):
                pms_room_id = str(pms_room.get('id', ''))
                device_info['pms_room_id'] = pms_room_id
                device_info['pms_room_name'] = pms_room.get('name', 'N/A')
                
                if pms_room_id == str(room_id):
                    analysis['pms_room_matches'].append(device_info)
                else:
                    analysis['pms_room_mismatches'].append(device_info)
            else:
                analysis['no_pms_room'].append(device_info)
        
        contamination_report[room_number] = analysis
        
        # Print summary for this room
        print(f"  Total devices: {len(aps) + len(mcs)}")
        print(f"  Devices with correct room in name: {len(analysis['correct_devices'])}")
        print(f"  Devices with WRONG room in name: {len(analysis['wrong_devices'])}")
        
        if analysis['wrong_devices']:
            print(f"  ⚠️ CONTAMINATION DETECTED!")
            for device in analysis['wrong_devices'][:3]:
                print(f"    - {device['type']}: {device['name']} (suggests room {device.get('suggested_room')})")
            if len(analysis['wrong_devices']) > 3:
                print(f"    ... and {len(analysis['wrong_devices']) - 3} more")
        
        print(f"\n  pms_room.id analysis:")
        print(f"    Devices with matching pms_room.id: {len(analysis['pms_room_matches'])}")
        print(f"    Devices with WRONG pms_room.id: {len(analysis['pms_room_mismatches'])}")
        print(f"    Devices without pms_room: {len(analysis['no_pms_room'])}")
        
        if analysis['pms_room_mismatches']:
            print(f"  ⚠️ PMS_ROOM MISMATCH!")
            for device in analysis['pms_room_mismatches'][:3]:
                print(f"    - {device['type']}: {device['name']} -> pms_room: {device.get('pms_room_name')}")
    
    return contamination_report

def simulate_filtering_scenarios(contamination_report: Dict[str, Dict]):
    """Simulate different filtering scenarios"""
    print("\n" + "="*60)
    print("FILTERING SIMULATION RESULTS")
    print("="*60)
    
    for room_number, analysis in contamination_report.items():
        print(f"\nRoom {room_number}:")
        print("-" * 40)
        
        total_devices = analysis['total_aps'] + analysis['total_mcs']
        
        # Scenario 1: No filtering (current after reverting)
        no_filter_count = total_devices
        print(f"  No filtering: {no_filter_count} devices (includes contamination)")
        
        # Scenario 2: Filter by pms_room_id (doesn't exist)
        pms_room_id_filter = 0  # Since no devices have pms_room_id
        print(f"  Filter by pms_room_id: {pms_room_id_filter} devices (field doesn't exist!)")
        
        # Scenario 3: Filter by pms_room.id
        pms_room_obj_filter = len(analysis['pms_room_matches']) + len(analysis['no_pms_room'])
        print(f"  Filter by pms_room.id: {pms_room_obj_filter} devices")
        
        # Scenario 4: Filter by name pattern
        name_filter = len(analysis['correct_devices']) + len(analysis['no_room_in_name'])
        print(f"  Filter by name pattern: {name_filter} devices")
        
        # Show which method would work best
        if len(analysis['wrong_devices']) > 0:
            print(f"\n  ⚠️ This room has contamination!")
            if pms_room_obj_filter < total_devices:
                print(f"  ✅ pms_room.id filtering would remove {total_devices - pms_room_obj_filter} wrong devices")
            if name_filter < total_devices:
                print(f"  ✅ Name pattern filtering would remove {total_devices - name_filter} wrong devices")

def main():
    print("="*60)
    print("CROSS-CONTAMINATION ANALYSIS")
    print("="*60)
    
    # Fetch all rooms
    room_map = fetch_all_rooms()
    
    # Analyze contamination
    contamination_report = analyze_room_contamination(room_map)
    
    # Simulate filtering
    simulate_filtering_scenarios(contamination_report)
    
    # Final recommendations
    print("\n" + "="*60)
    print("FINAL RECOMMENDATIONS")
    print("="*60)
    
    has_contamination = any(
        len(analysis['wrong_devices']) > 0 
        for analysis in contamination_report.values()
    )
    
    has_pms_room = any(
        len(analysis['pms_room_matches']) > 0 
        for analysis in contamination_report.values()
    )
    
    if not has_contamination:
        print("\n✅ No contamination detected in tested rooms!")
        print("   The API appears to be returning correct devices.")
        print("\n   RECOMMENDATION: Remove all filtering and trust the API response.")
    else:
        print("\n⚠️ Contamination detected in some rooms!")
        
        if has_pms_room:
            print("\n   RECOMMENDATION: Use pms_room.id filtering:")
            print("   1. Check if device has pms_room object")
            print("   2. If yes, compare pms_room.id with room's API ID")
            print("   3. If no pms_room, include the device by default")
            print("\n   Code pattern:")
            print("   final pmsRoom = device['pms_room'] as Map?;")
            print("   final deviceRoomId = pmsRoom?['id']?.toString();")
            print("   if (deviceRoomId == null || deviceRoomId == roomId) { include(); }")
        else:
            print("\n   WARNING: No devices have pms_room object!")
            print("   RECOMMENDATION: Use name-based filtering as fallback")

if __name__ == "__main__":
    main()