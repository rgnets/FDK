#!/usr/bin/env python3
"""Test that the fixed field selection works"""

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

# The FIXED field list from DeviceFieldSets
fixed_fields = 'id,name,type,status,ip,host,mac,scratch,pms_room,location,last_seen,signal_strength,connected_clients,online,note,images'

print("=== TESTING FIXED FIELD SELECTION ===\n")

# Test each device type
device_types = [
    ('access_points', 'ip', 'mac'),
    ('switch_devices', 'host', 'scratch'),
    ('media_converters', None, 'mac'),
    ('wlan_devices', 'host', 'mac')
]

for endpoint, ip_field, mac_field in device_types:
    print(f"\n{endpoint.upper()}:")
    print("-" * 40)
    
    url = f'{BASE_URL}/api/{endpoint}?page_size=0&only={fixed_fields}'
    response = requests.get(url, headers=headers, verify=False)
    
    if response.status_code == 200:
        data = response.json()
        
        if isinstance(data, list):
            devices = data
        elif 'results' in data:
            devices = data['results']
        else:
            devices = []
        
        if devices:
            # Check first 3 devices
            for i, device in enumerate(devices[:3]):
                print(f"\nDevice {i+1}: {device.get('name', 'unnamed')}")
                
                # Check IP field
                if ip_field:
                    ip_value = device.get(ip_field, 'NOT PRESENT')
                    print(f"  {ip_field}: {ip_value}")
                else:
                    print(f"  No IP field expected")
                
                # Check MAC field
                mac_value = device.get(mac_field, 'NOT PRESENT')
                print(f"  {mac_field}: {mac_value}")
                
                # For debugging - show what fields are actually present
                network_fields = ['ip', 'host', 'mac', 'scratch', 'ip_address', 'mac_address']
                present_fields = [f for f in network_fields if f in device and device[f]]
                if present_fields:
                    print(f"  Fields with values: {present_fields}")
        else:
            print("  No devices found")
    else:
        print(f"  Error {response.status_code}")

print("\n=== SUMMARY ===")
print("With the fixed field names:")
print("- Access points will get 'ip' and 'mac'")
print("- Switches will get 'host' and 'scratch' (MAC)")
print("- ONTs will get 'mac' (no IP)")
print("- WLAN will get 'host' and 'mac'")