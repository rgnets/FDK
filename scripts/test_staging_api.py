#!/usr/bin/env python3
"""
Test the staging API to check for pms_room_id field
"""

import requests
import json
import base64
from typing import Dict, Any

# Staging environment credentials
API_BASE_URL = 'https://vgw1-01.dal-interurban.mdu.attwifi.com'
API_USERNAME = 'fetoolreadonly'
API_KEY = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'

def get_auth_headers():
    auth_string = f"{API_USERNAME}:{API_KEY}"
    auth_b64 = base64.b64encode(auth_string.encode()).decode()
    return {
        'Authorization': f'Basic {auth_b64}',
        'Accept': 'application/json',
    }

def check_endpoint(endpoint: str, name: str) -> Dict[str, Any]:
    """Check an API endpoint and return field analysis"""
    print(f"\nChecking {name}...")
    print("-" * 40)
    
    try:
        response = requests.get(
            f"{API_BASE_URL}{endpoint}",
            headers=get_auth_headers(),
            timeout=30,
            verify=False  # Disable SSL verification for staging
        )
        response.raise_for_status()
        data = response.json()
        
        if 'results' in data and data['results']:
            first_item = data['results'][0]
            print(f"✓ Found {len(data['results'])} {name}")
            print(f"  First item keys: {list(first_item.keys())}")
            
            # Check for room fields
            room_fields = ['pms_room_id', 'room_id', 'room', 'room_number', 'location']
            found_fields = [f for f in room_fields if f in first_item]
            
            if found_fields:
                print(f"  Room association fields found: {found_fields}")
                for field in found_fields:
                    print(f"    {field}: {first_item[field]}")
            else:
                print("  ⚠️ No room association fields found!")
                
            # Check name for room number
            if 'name' in first_item:
                name_val = first_item['name']
                print(f"  Name: {name_val}")
                import re
                room_match = re.search(r'\d{3}', str(name_val))
                if room_match:
                    print(f"    Room number in name: {room_match.group()}")
                    
            return {'success': True, 'has_pms_room_id': 'pms_room_id' in first_item}
        else:
            print(f"✗ No results found")
            return {'success': False, 'has_pms_room_id': False}
            
    except Exception as e:
        print(f"✗ Error: {e}")
        return {'success': False, 'has_pms_room_id': False}

def check_specific_room(room_id: str):
    """Check a specific room's data"""
    print(f"\nChecking Room {room_id}...")
    print("-" * 40)
    
    try:
        response = requests.get(
            f"{API_BASE_URL}/api/pms_rooms/{room_id}.json",
            headers=get_auth_headers(),
            timeout=30,
            verify=False
        )
        response.raise_for_status()
        room = response.json()
        
        print(f"✓ Room {room_id} found")
        print(f"  Name: {room.get('room', room.get('name', 'N/A'))}")
        
        # Check devices
        aps = room.get('access_points', [])
        mcs = room.get('media_converters', [])
        
        print(f"  Access Points: {len(aps)}")
        print(f"  Media Converters: {len(mcs)}")
        
        # Check for wrong room devices
        wrong_devices = []
        for ap in aps:
            if 'name' in ap:
                import re
                match = re.search(r'\d{3}', ap['name'])
                if match and match.group() != room_id:
                    wrong_devices.append(f"AP: {ap['name']} (suggests room {match.group()})")
                    
        for mc in mcs:
            if 'name' in mc:
                import re
                match = re.search(r'\d{3}', mc['name'])
                if match and match.group() != room_id:
                    wrong_devices.append(f"MC: {mc['name']} (suggests room {match.group()})")
                    
        if wrong_devices:
            print(f"  ⚠️ Devices with wrong room numbers:")
            for device in wrong_devices[:5]:
                print(f"    - {device}")
            if len(wrong_devices) > 5:
                print(f"    ... and {len(wrong_devices) - 5} more")
                
        # Check if devices have pms_room_id
        if aps:
            first_ap = aps[0]
            if 'pms_room_id' in first_ap:
                print(f"  ✓ Access points have pms_room_id field")
                print(f"    Example: {first_ap.get('name', 'N/A')} -> pms_room_id: {first_ap['pms_room_id']}")
            else:
                print(f"  ✗ Access points DO NOT have pms_room_id field")
                
    except Exception as e:
        print(f"✗ Error: {e}")

def main():
    import warnings
    warnings.filterwarnings("ignore", message="Unverified HTTPS request")
    
    print("=" * 60)
    print("STAGING API FIELD CHECK")
    print("=" * 60)
    print(f"API URL: {API_BASE_URL}")
    print(f"Username: {API_USERNAME}")
    
    # Check different endpoints
    ap_result = check_endpoint("/api/access_points.json?page=1", "Access Points")
    mc_result = check_endpoint("/api/media_converters.json?page=1", "Media Converters")
    
    # Check specific rooms
    check_specific_room("203")
    check_specific_room("411")
    
    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    if not ap_result['has_pms_room_id'] and not mc_result['has_pms_room_id']:
        print("⚠️ CRITICAL: Neither access points nor media converters have pms_room_id field!")
        print("This explains why the current filtering code shows no devices.")
        print("\nRECOMMENDATION: The filtering logic needs to be changed to:")
        print("1. Remove the pms_room_id filtering entirely")
        print("2. Trust that the API returns correct devices per room")
        print("3. Or use device name patterns as secondary validation")
    else:
        print("✓ Devices have pms_room_id field")
        print("The filtering logic should work if properly implemented")

if __name__ == "__main__":
    main()