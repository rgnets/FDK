#!/usr/bin/env python3
"""Check what fields ONTs actually have for IP/MAC"""

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

print("=== CHECKING ONT/MEDIA CONVERTER FIELDS ===\n")

# Get a few ONTs to check their fields
url = f'{BASE_URL}/api/media_converters?page_size=5'
response = requests.get(url, headers=headers, verify=False)

if response.status_code == 200:
    data = response.json()
    
    if 'results' in data:
        devices = data['results']
    else:
        devices = data
    
    for i, device in enumerate(devices[:3]):
        print(f"ONT {i+1} - {device.get('name', 'unnamed')}:")
        
        # Check for IP-like fields
        ip_fields = ['ip', 'ip_address', 'ipAddress', 'host', 'loopback_ip', 'management_ip']
        for field in ip_fields:
            if field in device and device[field]:
                print(f"  {field}: {device[field]}")
        
        # Check for MAC-like fields  
        mac_fields = ['mac', 'mac_address', 'macAddress', 'scratch', 'serial_number']
        for field in mac_fields:
            if field in device and device[field]:
                print(f"  {field}: {device[field]}")
                
        # Check if there's IP in the metadata or other nested fields
        if 'infrastructure_device' in device and device['infrastructure_device']:
            print(f"  infrastructure_device: {device['infrastructure_device']}")
            
        print()