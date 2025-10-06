#!/usr/bin/env python3
"""
Test script to verify RG Nets API connectivity with test credentials
"""

import requests
import json
import sys
from urllib3.exceptions import InsecureRequestWarning

# Suppress SSL warnings for self-signed certificates
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

# Test credentials from QR code
CREDENTIALS = {
    'fqdn': 'vgw1-01.dal-interurban.mdu.attwifi.com',
    'login': 'fetoolreadonly',
    'api_key': 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'
}

BASE_URL = f"https://{CREDENTIALS['fqdn']}"

def test_endpoint(endpoint, description):
    """Test a single API endpoint"""
    print(f"\n{'='*60}")
    print(f"Testing: {description}")
    print(f"Endpoint: {endpoint}")
    print(f"{'='*60}")
    
    url = f"{BASE_URL}{endpoint}"
    params = {'api_key': CREDENTIALS['api_key']}
    headers = {
        'Accept': 'application/json',
        'X-API-Login': CREDENTIALS['login'],
        'X-API-Key': CREDENTIALS['api_key']
    }
    
    try:
        response = requests.get(url, params=params, headers=headers, verify=False, timeout=10)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            # Check if it's a paginated response
            if isinstance(data, dict) and 'count' in data:
                print(f"✅ SUCCESS - Paginated response")
                print(f"  Total items: {data.get('count', 0)}")
                print(f"  Page: {data.get('page', 1)}")
                print(f"  Page size: {data.get('page_size', 30)}")
                print(f"  Total pages: {data.get('total_pages', 1)}")
                
                if 'results' in data and data['results']:
                    print(f"  First item sample:")
                    first_item = data['results'][0]
                    for key in list(first_item.keys())[:5]:
                        print(f"    {key}: {first_item.get(key)}")
                        
            elif isinstance(data, list):
                print(f"✅ SUCCESS - Array response")
                print(f"  Total items: {len(data)}")
                
                if data:
                    print(f"  First item sample:")
                    first_item = data[0]
                    for key in list(first_item.keys())[:5]:
                        print(f"    {key}: {first_item.get(key)}")
                        
            elif isinstance(data, dict):
                print(f"✅ SUCCESS - Object response")
                for key in list(data.keys())[:5]:
                    print(f"  {key}: {data.get(key)}")
            else:
                print(f"✅ SUCCESS - Response type: {type(data)}")
                print(f"  Data: {str(data)[:200]}")
                
        elif response.status_code == 404:
            print(f"❌ NOT FOUND - Endpoint does not exist")
        elif response.status_code == 401:
            print(f"❌ UNAUTHORIZED - Check API credentials")
        else:
            print(f"⚠️  Unexpected status: {response.status_code}")
            print(f"  Response: {response.text[:200]}")
            
    except requests.exceptions.Timeout:
        print(f"❌ TIMEOUT - Request took too long")
    except requests.exceptions.ConnectionError as e:
        print(f"❌ CONNECTION ERROR - Cannot reach server")
        print(f"  Error: {str(e)[:200]}")
    except Exception as e:
        print(f"❌ ERROR: {type(e).__name__}")
        print(f"  Details: {str(e)[:200]}")

def main():
    print("RG Nets API Connection Test")
    print(f"Server: {BASE_URL}")
    print(f"Login: {CREDENTIALS['login']}")
    print(f"API Key: {CREDENTIALS['api_key'][:20]}...")
    
    # Test endpoints based on API documentation
    endpoints = [
        ('/api/whoami.json', 'Authentication Check'),
        ('/api/devices.json', 'Generic Devices'),
        ('/api/access_points.json', 'Access Points'),
        ('/api/switch_devices.json', 'Switch Devices'),
        ('/api/wlan_devices.json', 'WLAN Devices'),
        ('/api/pms_rooms.json', 'PMS Rooms'),
        ('/api/media_converters.json', 'Media Converters (ONTs)'),
        ('/api/locations.json', 'Locations (May not exist)'),
        ('/api/notifications.json', 'Notifications (May not exist)'),
    ]
    
    for endpoint, description in endpoints:
        test_endpoint(endpoint, description)
    
    print("\n" + "="*60)
    print("Test completed!")
    print("="*60)

if __name__ == "__main__":
    main()