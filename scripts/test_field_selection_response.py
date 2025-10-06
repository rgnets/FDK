#!/usr/bin/env python3
"""Test what fields the API actually returns with field selection"""

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

# Test with field selection as used in the app
list_fields = 'id,name,type,status,ip_address,mac_address,pms_room,location,last_seen,signal_strength,connected_clients,online,note,images'

print("=== TESTING FIELD SELECTION API RESPONSE ===\n")

# Test access_points
url = f'{BASE_URL}/api/access_points?page_size=0&only={list_fields}'
print(f"Testing: {url}\n")

response = requests.get(url, headers=headers, verify=False)

if response.status_code == 200:
    data = response.json()
    
    # Get first device to check field names
    if 'results' in data and len(data['results']) > 0:
        first_device = data['results'][0]
        print("First device fields returned:")
        for key, value in first_device.items():
            print(f"  '{key}': {repr(value)[:100]}")
        
        print("\n=== CRITICAL CHECK ===")
        print(f"Has 'ip_address'? {'ip_address' in first_device}")
        print(f"Has 'mac_address'? {'mac_address' in first_device}")
        print(f"Has 'ip'? {'ip' in first_device}")
        print(f"Has 'mac'? {'mac' in first_device}")
        
        if 'ip_address' in first_device:
            print(f"\nip_address value: {first_device['ip_address']}")
        if 'mac_address' in first_device:
            print(f"mac_address value: {first_device['mac_address']}")
            
        # Check if fields are null/empty
        print("\n=== VALUE CHECK ===")
        ip_val = first_device.get('ip_address', 'FIELD_NOT_PRESENT')
        mac_val = first_device.get('mac_address', 'FIELD_NOT_PRESENT')
        print(f"ip_address: {ip_val}")
        print(f"mac_address: {mac_val}")
        
    elif isinstance(data, list) and len(data) > 0:
        first_device = data[0]
        print("First device fields (direct array):")
        for key, value in first_device.items():
            print(f"  '{key}': {repr(value)[:100]}")
else:
    print(f"Error: {response.status_code}")
    print(response.text)

print("\n=== TEST WITHOUT FIELD SELECTION ===\n")

# Compare with no field selection
url_no_fields = f'{BASE_URL}/api/access_points?page_size=1'
response2 = requests.get(url_no_fields, headers=headers, verify=False)

if response2.status_code == 200:
    data2 = response2.json()
    if 'results' in data2 and len(data2['results']) > 0:
        first_full = data2['results'][0]
        print("Fields in full response:")
        print(f"  Has 'ip': {'ip' in first_full}")
        print(f"  Has 'mac': {'mac' in first_full}")
        print(f"  Has 'ip_address': {'ip_address' in first_full}")
        print(f"  Has 'mac_address': {'mac_address' in first_full}")
        
        if 'ip' in first_full:
            print(f"  'ip' value: {first_full['ip']}")
        if 'mac' in first_full:
            print(f"  'mac' value: {first_full['mac']}")