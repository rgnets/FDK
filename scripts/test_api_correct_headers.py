#!/usr/bin/env python3
"""
Test the staging API with CORRECT header format (X-API-Key and X-API-Login)
"""

import requests
import json
from typing import Dict, Any

# Staging environment credentials
API_BASE_URL = 'https://vgw1-01.dal-interurban.mdu.attwifi.com'
API_LOGIN = 'fetoolreadonly'
API_KEY = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'

def get_headers():
    """Return headers with X-API-Key and X-API-Login format"""
    return {
        'X-API-Key': API_KEY,
        'X-API-Login': API_LOGIN,
        'Accept': 'application/json',
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
                first_item = data['results'][0]
                print(f"✓ Found {len(data['results'])} {name} on page 1")
                print(f"  Total count: {data.get('count', 'N/A')}")
                print(f"\n  First item keys: {list(first_item.keys())[:10]}...")
                
                # Check for room fields
                room_fields = ['pms_room_id', 'room_id', 'room', 'room_number', 'location']
                found_fields = [f for f in room_fields if f in first_item]
                
                if 'pms_room_id' in first_item:
                    print(f"  ✓✓✓ HAS pms_room_id field! Value: {first_item['pms_room_id']}")
                else:
                    print(f"  ✗✗✗ NO pms_room_id field found!")
                
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
                
                # Check ID field
                if 'id' in first_item:
                    print(f"  ID: {first_item['id']}")
                        
                return {'success': True, 'has_pms_room_id': 'pms_room_id' in first_item}
            else:
                print(f"✗ No results in response")
                print(f"  Response: {json.dumps(data, indent=2)[:500]}")
                return {'success': False, 'has_pms_room_id': False}
        else:
            print(f"✗ HTTP {response.status_code}: {response.reason}")
            try:
                error_data = response.json()
                print(f"  Error: {json.dumps(error_data, indent=2)[:500]}")
            except:
                print(f"  Response: {response.text[:500]}")
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
            headers=get_headers(),
            timeout=30,
            verify=False
        )
        
        print(f"  Status Code: {response.status_code}")
        
        if response.status_code == 200:
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
            for ap in aps[:3]:  # Check first 3 APs
                if 'name' in ap:
                    print(f"    AP: {ap['name']}")
                    import re
                    match = re.search(r'\d{3}', ap['name'])
                    if match and match.group() != room_id:
                        wrong_devices.append(f"AP: {ap['name']} (suggests room {match.group()})")
                        
            for mc in mcs[:3]:  # Check first 3 MCs
                if 'name' in mc:
                    print(f"    MC: {mc['name']}")
                    import re
                    match = re.search(r'\d{3}', mc['name'])
                    if match and match.group() != room_id:
                        wrong_devices.append(f"MC: {mc['name']} (suggests room {match.group()})")
                        
            if wrong_devices:
                print(f"\n  ⚠️ Devices with WRONG room numbers:")
                for device in wrong_devices:
                    print(f"    - {device}")
                    
            # Check if devices have pms_room_id
            if aps:
                first_ap = aps[0]
                print(f"\n  Checking first AP for pms_room_id...")
                if 'pms_room_id' in first_ap:
                    print(f"  ✓ Access points HAVE pms_room_id field")
                    print(f"    Example: {first_ap.get('name', 'N/A')} -> pms_room_id: {first_ap['pms_room_id']}")
                else:
                    print(f"  ✗ Access points DO NOT have pms_room_id field")
                    print(f"    Available fields: {list(first_ap.keys())[:10]}...")
                    
            if mcs:
                first_mc = mcs[0]
                print(f"\n  Checking first MC for pms_room_id...")
                if 'pms_room_id' in first_mc:
                    print(f"  ✓ Media converters HAVE pms_room_id field")
                    print(f"    Example: {first_mc.get('name', 'N/A')} -> pms_room_id: {first_mc['pms_room_id']}")
                else:
                    print(f"  ✗ Media converters DO NOT have pms_room_id field")
                    print(f"    Available fields: {list(first_mc.keys())[:10]}...")
        else:
            print(f"✗ HTTP {response.status_code}: {response.reason}")
                
    except Exception as e:
        print(f"✗ Error: {e}")

def main():
    import warnings
    warnings.filterwarnings("ignore", message="Unverified HTTPS request")
    
    print("=" * 60)
    print("STAGING API FIELD CHECK (CORRECT HEADERS)")
    print("=" * 60)
    print(f"API URL: {API_BASE_URL}")
    print(f"Login: {API_LOGIN}")
    print(f"Using Headers: X-API-Key and X-API-Login")
    
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
        print("\nRECOMMENDATION:")
        print("1. Remove the pms_room_id filtering from room_repository.dart")
        print("2. Trust that the API returns correct devices per room")
        print("3. The cross-contamination issue (room 203 showing 411 devices) is an API-level problem")
    else:
        print("✓ Devices have pms_room_id field")
        print("The filtering logic should work if properly implemented")
        print("Check if the pms_room_id values are correctly populated")

if __name__ == "__main__":
    main()