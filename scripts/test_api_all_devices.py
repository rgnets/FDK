#!/usr/bin/env python3
"""
Test script to get ALL devices and check their location fields
"""

import requests
import json
import sys

# API Configuration
API_BASE_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def test_all_devices():
    """Test the devices API with page_size=0 to get all devices"""
    
    print("=" * 80)
    print("TESTING ALL DEVICES - LOCATION FIELD")
    print("=" * 80)
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Use page_size=0 to get all devices
    devices_url = f"{API_BASE_URL}/api/devices?page_size=0"
    print(f"\nTesting: GET {devices_url}")
    
    try:
        response = requests.get(devices_url, headers=headers, timeout=10)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            # Handle both list and dict responses
            if isinstance(data, list):
                devices = data
                total_count = len(data)
            else:
                devices = data.get('results', [])
                total_count = data.get('count', 0)
            
            print(f"\nTotal devices in system: {total_count}")
            print(f"Devices returned: {len(devices)}")
            
            if devices:
                # Analyze location fields
                null_location = 0
                empty_location = 0
                has_location = 0
                location_values = set()
                
                null_pms = 0
                has_pms = 0
                pms_values = set()
                
                # Sample devices with non-null values
                samples_with_location = []
                samples_with_pms = []
                
                for device in devices:
                    location = device.get('location')
                    pms_room_id = device.get('pms_room_id')
                    
                    # Check location
                    if location is None:
                        null_location += 1
                    elif location == "":
                        empty_location += 1
                    else:
                        has_location += 1
                        location_values.add(str(location))
                        if len(samples_with_location) < 5:
                            samples_with_location.append({
                                'id': device.get('id'),
                                'name': device.get('name'),
                                'location': location,
                                'pms_room_id': pms_room_id
                            })
                    
                    # Check pms_room_id
                    if pms_room_id is None:
                        null_pms += 1
                    else:
                        has_pms += 1
                        pms_values.add(str(pms_room_id))
                        if len(samples_with_pms) < 5:
                            samples_with_pms.append({
                                'id': device.get('id'),
                                'name': device.get('name'),
                                'location': location,
                                'pms_room_id': pms_room_id
                            })
                
                print("\n" + "=" * 80)
                print("LOCATION FIELD STATISTICS")
                print("=" * 80)
                print(f"\nlocation field:")
                print(f"  null: {null_location}")
                print(f"  empty string: {empty_location}")
                print(f"  has value: {has_location}")
                
                if location_values:
                    print(f"\nUnique location values (first 10):")
                    for val in list(location_values)[:10]:
                        print(f"    {repr(val)}")
                
                print(f"\npms_room_id field:")
                print(f"  null: {null_pms}")
                print(f"  has value: {has_pms}")
                
                if pms_values:
                    print(f"\nUnique pms_room_id values (first 10):")
                    for val in list(pms_values)[:10]:
                        print(f"    {repr(val)}")
                
                if samples_with_location:
                    print("\n" + "=" * 80)
                    print("SAMPLE DEVICES WITH LOCATION VALUES")
                    print("=" * 80)
                    for sample in samples_with_location:
                        print(f"\nDevice: {sample['name']} (ID: {sample['id']})")
                        print(f"  location: {repr(sample['location'])}")
                        print(f"  pms_room_id: {repr(sample['pms_room_id'])}")
                
                if samples_with_pms:
                    print("\n" + "=" * 80)
                    print("SAMPLE DEVICES WITH PMS_ROOM_ID VALUES")
                    print("=" * 80)
                    for sample in samples_with_pms:
                        print(f"\nDevice: {sample['name']} (ID: {sample['id']})")
                        print(f"  location: {repr(sample['location'])}")
                        print(f"  pms_room_id: {repr(sample['pms_room_id'])}")
                
                # Check device types
                print("\n" + "=" * 80)
                print("DEVICE TYPES IN API")
                print("=" * 80)
                device_types = {}
                for device in devices:
                    dtype = device.get('type', 'unknown')
                    device_types[dtype] = device_types.get(dtype, 0) + 1
                
                for dtype, count in sorted(device_types.items()):
                    print(f"  {dtype}: {count}")
                
        else:
            print(f"Error response: {response.text[:500]}")
            
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(test_all_devices())