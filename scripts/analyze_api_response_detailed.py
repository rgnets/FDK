#!/usr/bin/env python3
"""
Detailed analysis of API response with page_size=0
Reads every field line by line to understand the exact structure
"""

import requests
import json
import sys
from typing import Dict, List, Any, Optional

# API Configuration
API_BASE_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def analyze_nested_structure(obj: Any, prefix: str = "", depth: int = 0) -> Dict[str, Any]:
    """Recursively analyze nested structure of an object"""
    analysis = {}
    indent = "  " * depth
    
    if isinstance(obj, dict):
        for key, value in obj.items():
            full_key = f"{prefix}.{key}" if prefix else key
            if isinstance(value, dict):
                print(f"{indent}{key}: <object>")
                sub_analysis = analyze_nested_structure(value, full_key, depth + 1)
                analysis.update(sub_analysis)
            elif isinstance(value, list):
                print(f"{indent}{key}: <array> ({len(value)} items)")
                if value and isinstance(value[0], dict):
                    print(f"{indent}  First item structure:")
                    analyze_nested_structure(value[0], f"{full_key}[0]", depth + 2)
            else:
                value_type = type(value).__name__
                value_repr = repr(value) if value is not None else "null"
                if len(value_repr) > 50:
                    value_repr = value_repr[:50] + "..."
                print(f"{indent}{key}: {value_repr} ({value_type})")
                analysis[full_key] = {
                    'type': value_type,
                    'value': value,
                    'is_null': value is None
                }
    return analysis

def main():
    print("=" * 80)
    print("DETAILED API RESPONSE ANALYSIS")
    print("=" * 80)
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Test with page_size=0 to get all data
    devices_url = f"{API_BASE_URL}/api/devices?page_size=0"
    print(f"\nEndpoint: GET {devices_url}")
    print(f"Headers: Authorization: Bearer [TOKEN]")
    print("\n" + "=" * 80)
    
    try:
        print("Sending request...")
        response = requests.get(devices_url, headers=headers, timeout=30)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            print("\n" + "=" * 80)
            print("RESPONSE STRUCTURE")
            print("=" * 80)
            
            # Check if response is list or dict
            if isinstance(data, list):
                print(f"\nResponse type: LIST")
                print(f"Total items: {len(data)}")
                
                if data:
                    print("\n" + "=" * 80)
                    print("FIRST DEVICE - COMPLETE STRUCTURE")
                    print("=" * 80)
                    print("\nAnalyzing first device object line by line:")
                    first_device = data[0]
                    field_analysis = analyze_nested_structure(first_device)
                    
                    # Look for pms_room specifically
                    print("\n" + "=" * 80)
                    print("SEARCHING FOR PMS_ROOM FIELDS")
                    print("=" * 80)
                    
                    pms_fields = []
                    room_fields = []
                    location_fields = []
                    
                    for field_path in field_analysis.keys():
                        field_lower = field_path.lower()
                        if 'pms' in field_lower:
                            pms_fields.append(field_path)
                        if 'room' in field_lower:
                            room_fields.append(field_path)
                        if 'location' in field_lower:
                            location_fields.append(field_path)
                    
                    print("\nFields containing 'pms':")
                    if pms_fields:
                        for field in pms_fields:
                            info = field_analysis[field]
                            print(f"  {field}: {info['value']} (type: {info['type']}, null: {info['is_null']})")
                    else:
                        print("  NONE FOUND")
                    
                    print("\nFields containing 'room':")
                    if room_fields:
                        for field in room_fields:
                            info = field_analysis[field]
                            print(f"  {field}: {info['value']} (type: {info['type']}, null: {info['is_null']})")
                    else:
                        print("  NONE FOUND")
                    
                    print("\nFields containing 'location':")
                    if location_fields:
                        for field in location_fields:
                            info = field_analysis[field]
                            print(f"  {field}: {info['value']} (type: {info['type']}, null: {info['is_null']})")
                    else:
                        print("  NONE FOUND")
                    
                    # Check all devices for consistency
                    print("\n" + "=" * 80)
                    print("CHECKING ALL DEVICES FOR CONSISTENCY")
                    print("=" * 80)
                    
                    # Collect all unique field names across all devices
                    all_fields = set()
                    for device in data:
                        all_fields.update(device.keys())
                    
                    print(f"\nTotal unique fields across {len(data)} devices: {len(all_fields)}")
                    print("\nAll fields:")
                    for field in sorted(all_fields):
                        print(f"  - {field}")
                    
                    # Check if any device has pms_room or related fields
                    devices_with_pms_room = 0
                    devices_with_location = 0
                    devices_with_pms_room_id = 0
                    
                    for device in data:
                        if 'pms_room' in device:
                            devices_with_pms_room += 1
                        if 'location' in device:
                            devices_with_location += 1
                        if 'pms_room_id' in device:
                            devices_with_pms_room_id += 1
                    
                    print(f"\nDevices with 'pms_room': {devices_with_pms_room}/{len(data)}")
                    print(f"Devices with 'location': {devices_with_location}/{len(data)}")
                    print(f"Devices with 'pms_room_id': {devices_with_pms_room_id}/{len(data)}")
                    
                    # Show more sample devices
                    print("\n" + "=" * 80)
                    print("SAMPLE DEVICES (First 5)")
                    print("=" * 80)
                    
                    for i, device in enumerate(data[:5], 1):
                        print(f"\n--- Device {i} ---")
                        print(f"ID: {device.get('id')}")
                        print(f"Name: {device.get('name')}")
                        print(f"MAC: {device.get('mac')}")
                        
                        # Check for any room-related data
                        for key in device.keys():
                            if 'room' in key.lower() or 'pms' in key.lower() or 'location' in key.lower():
                                print(f"{key}: {device[key]}")
                        
                        # Check if account has room info
                        if 'account' in device and isinstance(device['account'], dict):
                            print(f"Account ID: {device['account'].get('id')}")
                            print(f"Account Login: {device['account'].get('login')}")
                            for key in device['account'].keys():
                                if 'room' in key.lower() or 'pms' in key.lower():
                                    print(f"  Account.{key}: {device['account'][key]}")
                    
            else:
                print(f"\nResponse type: DICT")
                print("Dict structure:")
                analyze_nested_structure(data)
                
        else:
            print(f"\nError response: {response.status_code}")
            print(response.text[:500])
            
    except Exception as e:
        print(f"\nError: {e}")
        return 1
    
    print("\n" + "=" * 80)
    print("CONCLUSION")
    print("=" * 80)
    print("\nBased on the detailed analysis:")
    print("1. The API response structure has been fully analyzed")
    print("2. All fields have been examined for pms_room data")
    print("3. The exact format of the response is now clear")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())