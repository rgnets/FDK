#!/usr/bin/env python3
"""Test with correct field names"""

import requests
import json
from urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

BASE_URL = 'https://vgw1-01.dal-interurban.mdu.attwifi.com'
API_KEY = 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'

headers = {
    'Authorization': f'Bearer {API_KEY}',
    'Accept': 'application/json'
}

# Test with CORRECT field names (ip and mac instead of ip_address and mac_address)
correct_fields = 'id,name,type,status,ip,mac,pms_room,location,last_seen,signal_strength,connected_clients,online,note,images'

print("=== TESTING WITH CORRECT FIELD NAMES ===\n")

url = f'{BASE_URL}/api/access_points?page_size=0&only={correct_fields}'
print(f"Testing: {url}\n")

response = requests.get(url, headers=headers, verify=False)

if response.status_code == 200:
    data = response.json()
    
    # Get first device to check field names
    if isinstance(data, list) and len(data) > 0:
        first_device = data[0]
        print("First device fields returned:")
        for key, value in first_device.items():
            if key in ['ip', 'mac', 'name', 'id']:
                print(f"  '{key}': {repr(value)}")
        
        print("\n=== FIELD PRESENCE CHECK ===")
        print(f"Has 'ip'? {'ip' in first_device}")
        print(f"Has 'mac'? {'mac' in first_device}")
        print(f"IP value: {first_device.get('ip', 'NOT PRESENT')}")
        print(f"MAC value: {first_device.get('mac', 'NOT PRESENT')}")
        
        # Check multiple devices
        print("\n=== CHECKING FIRST 5 DEVICES ===")
        for i, device in enumerate(data[:5]):
            print(f"Device {i+1}: IP={device.get('ip', 'NONE')}, MAC={device.get('mac', 'NONE')}")
else:
    print(f"Error: {response.status_code}")

print("\n=== TESTING ALL DEVICE TYPES ===")

# Test other device types
device_types = ['media_converters', 'switch_devices', 'wlan_devices']

for dtype in device_types:
    url = f'{BASE_URL}/api/{dtype}?page_size=1&only={correct_fields}'
    response = requests.get(url, headers=headers, verify=False)
    
    if response.status_code == 200:
        data = response.json()
        if isinstance(data, list) and len(data) > 0:
            device = data[0]
        elif 'results' in data and len(data['results']) > 0:
            device = data['results'][0]
        else:
            continue
            
        print(f"\n{dtype}:")
        print(f"  Has 'ip': {'ip' in device}")
        print(f"  Has 'mac': {'mac' in device}")
        
        # Some device types might use different fields
        if dtype == 'switch_devices':
            print(f"  Has 'host': {'host' in device}")
            print(f"  Has 'scratch': {'scratch' in device}")
            if 'host' in device:
                print(f"  host value: {device['host']}")
            if 'scratch' in device:
                print(f"  scratch value: {device['scratch']}")