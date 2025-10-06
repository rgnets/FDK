#!/usr/bin/env python3
"""
Test script to analyze pms_room data in API device response
"""

import requests
import json
import sys
from typing import Dict, List, Any, Optional

# API Configuration
API_BASE_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def analyze_device_fields(devices: List[Dict[str, Any]]) -> None:
    """Analyze all fields in device objects, focusing on room-related data"""
    
    print("\n" + "=" * 80)
    print("ANALYZING DEVICE FIELDS")
    print("=" * 80)
    
    if not devices:
        print("No devices to analyze")
        return
    
    # Get all unique keys from all devices
    all_keys = set()
    for device in devices:
        all_keys.update(device.keys())
    
    print(f"\nTotal unique fields across all devices: {len(all_keys)}")
    print("\nAll fields found in device objects:")
    for key in sorted(all_keys):
        print(f"  - {key}")
    
    # Look for room-related fields
    room_related = [k for k in all_keys if 'room' in k.lower() or 'location' in k.lower() or 'pms' in k.lower()]
    
    if room_related:
        print("\n" + "=" * 80)
        print("ROOM-RELATED FIELDS")
        print("=" * 80)
        print("\nFields containing 'room', 'location', or 'pms':")
        for field in room_related:
            print(f"  - {field}")
            
            # Analyze values for this field
            values = {}
            null_count = 0
            
            for device in devices:
                value = device.get(field)
                if value is None:
                    null_count += 1
                else:
                    value_str = str(value)
                    if value_str not in values:
                        values[value_str] = 0
                    values[value_str] += 1
            
            print(f"    Null values: {null_count}")
            if values:
                print(f"    Non-null values: {sum(values.values())}")
                print(f"    Unique values: {len(values)}")
                if len(values) <= 10:
                    for val, count in sorted(values.items())[:10]:
                        print(f"      - {repr(val)}: {count} occurrences")

def test_pms_room_data():
    """Test the devices API with page_size=0 to analyze pms_room data"""
    
    print("=" * 80)
    print("TESTING PMS_ROOM DATA IN DEVICES API")
    print("=" * 80)
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Use page_size=0 to get all devices
    devices_url = f"{API_BASE_URL}/api/devices?page_size=0"
    print(f"\nEndpoint: GET {devices_url}")
    print(f"Headers: Authorization: Bearer [TOKEN]")
    
    try:
        print("\nSending request...")
        response = requests.get(devices_url, headers=headers, timeout=30)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            # Handle both list and dict responses
            if isinstance(data, list):
                devices = data
                print(f"\nResponse type: List")
                print(f"Total devices: {len(devices)}")
            else:
                devices = data.get('results', [])
                print(f"\nResponse type: Dict")
                print(f"Dict keys: {list(data.keys())}")
                print(f"Total count: {data.get('count', 'N/A')}")
                print(f"Devices in results: {len(devices)}")
            
            if devices:
                # Analyze device structure
                analyze_device_fields(devices)
                
                # Show sample devices with all their fields
                print("\n" + "=" * 80)
                print("SAMPLE DEVICE OBJECTS (First 3)")
                print("=" * 80)
                
                for i, device in enumerate(devices[:3], 1):
                    print(f"\nDevice {i}:")
                    print(json.dumps(device, indent=2, default=str))
                
                # Check specifically for pms_room object
                print("\n" + "=" * 80)
                print("CHECKING FOR PMS_ROOM OBJECT")
                print("=" * 80)
                
                has_pms_room_obj = 0
                has_pms_room_id = 0
                pms_room_samples = []
                
                for device in devices:
                    # Check for pms_room as an object
                    if 'pms_room' in device:
                        has_pms_room_obj += 1
                        if len(pms_room_samples) < 3:
                            pms_room_samples.append({
                                'device_id': device.get('id'),
                                'device_name': device.get('name'),
                                'pms_room': device.get('pms_room')
                            })
                    
                    # Check for pms_room_id field
                    if 'pms_room_id' in device:
                        value = device.get('pms_room_id')
                        if value is not None:
                            has_pms_room_id += 1
                
                print(f"\nDevices with 'pms_room' object: {has_pms_room_obj}")
                print(f"Devices with non-null 'pms_room_id': {has_pms_room_id}")
                
                if pms_room_samples:
                    print("\nSample devices with pms_room object:")
                    for sample in pms_room_samples:
                        print(f"\nDevice: {sample['device_name']} (ID: {sample['device_id']})")
                        print(f"pms_room: {json.dumps(sample['pms_room'], indent=2, default=str)}")
                
            else:
                print("\nNo devices returned")
                
        else:
            print(f"\nError response:")
            print(response.text[:1000])
            
    except requests.exceptions.RequestException as e:
        print(f"\nRequest failed: {e}")
        return 1
    except json.JSONDecodeError as e:
        print(f"\nFailed to parse JSON response: {e}")
        return 1
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        return 1
    
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print("\nBased on the API response:")
    print("1. Check if devices have a 'pms_room' nested object")
    print("2. Check if devices have 'pms_room_id' field")
    print("3. Check if devices have 'location' field")
    print("4. Determine what room information is available")
    
    return 0

if __name__ == "__main__":
    sys.exit(test_pms_room_data())