#!/usr/bin/env python3
"""
Test the staging API with CORRECT Authorization header format
"""

import requests
import json
from typing import Dict, Any

# Staging environment credentials from app config
API_BASE_URL = 'https://vgw1-01.dal-interurban.mdu.attwifi.com'
API_KEY = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'

def get_headers():
    """Return headers with Bearer Authorization format"""
    return {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
    }

def check_endpoint(endpoint: str, name: str) -> Dict[str, Any]:
    """Check an API endpoint and return field analysis"""
    print(f"\nChecking {name}...")
    print("-" * 40)
    
    try:
        response = requests.get(
            f"{API_BASE_URL}{endpoint}",
            headers=get_headers(),
            timeout=30,
            verify=False  # Disable SSL verification for staging
        )
        
        print(f"  Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            if 'results' in data and data['results']:
                results = data['results']
                print(f"✓ Found {len(results)} {name} on page 1")
                print(f"  Total count: {data.get('count', 'N/A')}")
                
                # Analyze first few items
                for i, item in enumerate(results[:3]):
                    print(f"\n  Item {i+1}:")
                    print(f"    ID: {item.get('id', 'N/A')}")
                    print(f"    Name: {item.get('name', 'N/A')}")
                    
                    # Check for pms_room_id
                    if 'pms_room_id' in item:
                        print(f"    ✓✓✓ HAS pms_room_id: {item['pms_room_id']}")
                    else:
                        print(f"    ✗✗✗ NO pms_room_id field")
                    
                    # Check other room-related fields
                    room_fields = ['room_id', 'room', 'room_number', 'location', 'pms_room']
                    for field in room_fields:
                        if field in item:
                            print(f"    {field}: {item[field]}")
                
                # Summary of pms_room_id presence
                with_pms = sum(1 for item in results if 'pms_room_id' in item)
                print(f"\n  SUMMARY: {with_pms}/{len(results)} items have pms_room_id")
                
                return {'success': True, 'has_pms_room_id': with_pms > 0}
            else:
                print(f"✗ No results in response")
                return {'success': False, 'has_pms_room_id': False}
        else:
            print(f"✗ HTTP {response.status_code}: {response.reason}")
            return {'success': False, 'has_pms_room_id': False}
            
    except Exception as e:
        print(f"✗ Error: {e}")
        return {'success': False, 'has_pms_room_id': False}

def check_specific_room(room_id: str):
    """Check a specific room's data"""
    print(f"\n{'='*60}")
    print(f"Checking Room {room_id} Details")
    print("-" * 60)
    
    try:
        response = requests.get(
            f"{API_BASE_URL}/api/pms_rooms/{room_id}.json",
            headers=get_headers(),
            timeout=30,
            verify=False
        )
        
        print(f"  Status Code: {response.status_code}")
        
        if response.status_code == 200:
            room = response.json()
            
            print(f"\n✓ Room {room_id} found")
            print(f"  Room name: {room.get('room', room.get('name', 'N/A'))}")
            print(f"  ID: {room.get('id', 'N/A')}")
            
            # Check devices
            aps = room.get('access_points', [])
            mcs = room.get('media_converters', [])
            switches = room.get('switch_devices', [])
            
            print(f"\n  Device counts:")
            print(f"    Access Points: {len(aps)}")
            print(f"    Media Converters: {len(mcs)}")
            print(f"    Switches: {len(switches)}")
            
            # Analyze access points
            if aps:
                print(f"\n  Access Points Analysis:")
                wrong_room_aps = []
                no_pms_room_id = []
                
                for ap in aps:
                    name = ap.get('name', '')
                    ap_id = ap.get('id', 'N/A')
                    
                    # Check if name suggests different room
                    import re
                    match = re.search(r'\d{3}', name)
                    if match and match.group() != room_id:
                        wrong_room_aps.append((name, match.group()))
                    
                    # Check for pms_room_id
                    if 'pms_room_id' not in ap:
                        no_pms_room_id.append(name)
                
                # First few APs
                for i, ap in enumerate(aps[:3]):
                    print(f"    AP {i+1}: {ap.get('name', 'N/A')} (ID: {ap.get('id', 'N/A')})")
                    if 'pms_room_id' in ap:
                        print(f"      pms_room_id: {ap['pms_room_id']}")
                    else:
                        print(f"      NO pms_room_id field!")
                
                if wrong_room_aps:
                    print(f"\n    ⚠️ WRONG ROOM APs ({len(wrong_room_aps)} found):")
                    for name, suggested_room in wrong_room_aps[:5]:
                        print(f"      - {name} (suggests room {suggested_room})")
                    if len(wrong_room_aps) > 5:
                        print(f"      ... and {len(wrong_room_aps) - 5} more")
                
                if no_pms_room_id:
                    print(f"\n    ✗ {len(no_pms_room_id)} APs without pms_room_id field")
            
            # Analyze media converters
            if mcs:
                print(f"\n  Media Converters Analysis:")
                wrong_room_mcs = []
                no_pms_room_id = []
                
                for mc in mcs:
                    name = mc.get('name', '')
                    
                    # Check if name suggests different room
                    import re
                    match = re.search(r'\d{3}', name)
                    if match and match.group() != room_id:
                        wrong_room_mcs.append((name, match.group()))
                    
                    # Check for pms_room_id
                    if 'pms_room_id' not in mc:
                        no_pms_room_id.append(name)
                
                # First few MCs
                for i, mc in enumerate(mcs[:3]):
                    print(f"    MC {i+1}: {mc.get('name', 'N/A')} (ID: {mc.get('id', 'N/A')})")
                    if 'pms_room_id' in mc:
                        print(f"      pms_room_id: {mc['pms_room_id']}")
                    else:
                        print(f"      NO pms_room_id field!")
                
                if wrong_room_mcs:
                    print(f"\n    ⚠️ WRONG ROOM MCs ({len(wrong_room_mcs)} found):")
                    for name, suggested_room in wrong_room_mcs[:5]:
                        print(f"      - {name} (suggests room {suggested_room})")
                    if len(wrong_room_mcs) > 5:
                        print(f"      ... and {len(wrong_room_mcs) - 5} more")
                
                if no_pms_room_id:
                    print(f"\n    ✗ {len(no_pms_room_id)} MCs without pms_room_id field")
                    
        else:
            print(f"✗ HTTP {response.status_code}: {response.reason}")
                
    except Exception as e:
        print(f"✗ Error: {e}")

def main():
    import warnings
    warnings.filterwarnings("ignore", message="Unverified HTTPS request")
    
    print("=" * 60)
    print("STAGING API ANALYSIS - CHECKING FOR pms_room_id")
    print("=" * 60)
    print(f"API URL: {API_BASE_URL}")
    print(f"Using Bearer Authorization header")
    
    # First test connection
    print("\nTesting connection...")
    try:
        response = requests.get(
            f"{API_BASE_URL}/api/whoami.json",
            headers=get_headers(),
            timeout=10,
            verify=False
        )
        if response.status_code == 200:
            data = response.json()
            print(f"✓ Connected as: {data.get('login', 'N/A')} (type: {data.get('type', 'N/A')})")
        else:
            print(f"✗ Connection failed: {response.status_code}")
            return
    except Exception as e:
        print(f"✗ Connection error: {e}")
        return
    
    # Check different endpoints
    ap_result = check_endpoint("/api/access_points.json?page=1", "Access Points")
    mc_result = check_endpoint("/api/media_converters.json?page=1", "Media Converters")
    
    # Check specific problematic rooms
    check_specific_room("203")
    check_specific_room("411")
    
    # Final Summary
    print("\n" + "=" * 60)
    print("FINAL ANALYSIS")
    print("=" * 60)
    
    if not ap_result['has_pms_room_id'] and not mc_result['has_pms_room_id']:
        print("\n⚠️ CRITICAL FINDING:")
        print("Neither access points nor media converters have pms_room_id field!")
        print("\nThis explains why after adding pms_room_id filtering, no devices appear.")
        print("\nRECOMMENDATIONS:")
        print("1. Remove pms_room_id filtering from room_repository.dart")
        print("2. Trust the API to return correct devices per room")
        print("3. The cross-contamination (room 203 showing 411 devices) is likely")
        print("   an API configuration issue, not a client-side filtering problem")
    else:
        print("\n✓ Devices have pms_room_id field")
        print("Check the detailed output above to see if values are correct")

if __name__ == "__main__":
    main()