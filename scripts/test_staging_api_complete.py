#!/usr/bin/env python3
"""
Complete staging API test with page_size=0
Analyzes every line of the response to understand pms_room structure
"""

import requests
import json
import sys
from typing import Dict, List, Any, Optional, Set

# Staging API Configuration
API_BASE_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def print_section(title: str):
    """Print a formatted section header"""
    print("\n" + "=" * 80)
    print(title)
    print("=" * 80)

def analyze_value(value: Any, indent: int = 0) -> str:
    """Analyze and format a value for display"""
    spaces = "  " * indent
    if value is None:
        return f"{spaces}null"
    elif isinstance(value, bool):
        return f"{spaces}{str(value).lower()}"
    elif isinstance(value, (int, float)):
        return f"{spaces}{value}"
    elif isinstance(value, str):
        return f"{spaces}'{value}'"
    elif isinstance(value, list):
        return f"{spaces}[array with {len(value)} items]"
    elif isinstance(value, dict):
        return f"{spaces}[object]"
    else:
        return f"{spaces}{repr(value)}"

def deep_analyze_object(obj: Dict[str, Any], path: str = "", indent: int = 0) -> Dict[str, Any]:
    """Deep analysis of object structure"""
    analysis = {}
    spaces = "  " * indent
    
    for key, value in obj.items():
        full_path = f"{path}.{key}" if path else key
        
        # Print the field
        if isinstance(value, dict):
            print(f"{spaces}{key}: {{")
            sub_analysis = deep_analyze_object(value, full_path, indent + 1)
            analysis.update(sub_analysis)
            print(f"{spaces}}}")
        elif isinstance(value, list):
            print(f"{spaces}{key}: [")
            if value:
                if isinstance(value[0], dict):
                    print(f"{spaces}  // First item:")
                    deep_analyze_object(value[0], f"{full_path}[0]", indent + 1)
                else:
                    for i, item in enumerate(value[:3]):  # Show first 3 items
                        print(f"{spaces}  [{i}]: {analyze_value(item)}")
            print(f"{spaces}]")
        else:
            type_name = type(value).__name__
            print(f"{spaces}{key}: {analyze_value(value)} <{type_name}>")
        
        # Store analysis
        analysis[full_path] = {
            'type': type(value).__name__,
            'value': value,
            'is_null': value is None,
            'path': full_path
        }
    
    return analysis

def test_staging_api():
    """Test staging API with complete analysis"""
    
    print_section("STAGING API TEST - COMPLETE ANALYSIS")
    
    # Prepare headers
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    # Build URL with page_size=0
    url = f"{API_BASE_URL}/api/devices?page_size=0"
    
    print(f"\nEndpoint: {url}")
    print(f"Method: GET")
    print(f"Headers:")
    print(f"  Authorization: Bearer [REDACTED]")
    print(f"  Content-Type: application/json")
    print(f"  Accept: application/json")
    
    try:
        # Make request
        print("\nSending request to staging API...")
        response = requests.get(url, headers=headers, timeout=30)
        
        print(f"Response Status: {response.status_code}")
        print(f"Response Headers:")
        for key, value in response.headers.items():
            if key.lower() in ['content-type', 'content-length', 'date']:
                print(f"  {key}: {value}")
        
        if response.status_code != 200:
            print(f"\nError Response:")
            print(response.text[:1000])
            return 1
        
        # Parse response
        data = response.json()
        
        print_section("RESPONSE TYPE ANALYSIS")
        
        if isinstance(data, list):
            print(f"Response is a LIST")
            print(f"Total devices: {len(data)}")
            devices = data
        elif isinstance(data, dict):
            print(f"Response is a DICTIONARY")
            print(f"Keys: {list(data.keys())}")
            
            # Try to find devices in common patterns
            if 'results' in data:
                devices = data['results']
                print(f"Found devices in 'results' key: {len(devices)} items")
            elif 'data' in data:
                devices = data['data']
                print(f"Found devices in 'data' key: {len(devices)} items")
            elif 'devices' in data:
                devices = data['devices']
                print(f"Found devices in 'devices' key: {len(devices)} items")
            else:
                print("Could not find device list in response")
                print("Full structure:")
                print(json.dumps(data, indent=2)[:2000])
                return 1
        else:
            print(f"Unexpected response type: {type(data)}")
            return 1
        
        if not devices:
            print("No devices in response")
            return 0
        
        print_section("FIRST DEVICE - LINE BY LINE ANALYSIS")
        
        first_device = devices[0]
        print("\nDevice structure:")
        field_analysis = deep_analyze_object(first_device)
        
        print_section("SEARCHING FOR PMS_ROOM FIELDS")
        
        # Search for pms_room related fields
        pms_fields = []
        room_fields = []
        location_fields = []
        
        for field_path, info in field_analysis.items():
            lower_path = field_path.lower()
            if 'pms' in lower_path:
                pms_fields.append((field_path, info))
            if 'room' in lower_path:
                room_fields.append((field_path, info))
            if 'location' in lower_path:
                location_fields.append((field_path, info))
        
        print("\n1. Fields containing 'pms':")
        if pms_fields:
            for path, info in pms_fields:
                print(f"   {path}:")
                print(f"     Type: {info['type']}")
                print(f"     Value: {info['value']}")
                print(f"     Is null: {info['is_null']}")
        else:
            print("   NONE FOUND")
        
        print("\n2. Fields containing 'room':")
        if room_fields:
            for path, info in room_fields:
                print(f"   {path}:")
                print(f"     Type: {info['type']}")
                print(f"     Value: {info['value']}")
                print(f"     Is null: {info['is_null']}")
        else:
            print("   NONE FOUND")
        
        print("\n3. Fields containing 'location':")
        if location_fields:
            for path, info in location_fields:
                print(f"   {path}:")
                print(f"     Type: {info['type']}")
                print(f"     Value: {info['value']}")
                print(f"     Is null: {info['is_null']}")
        else:
            print("   NONE FOUND")
        
        print_section("ALL UNIQUE FIELDS ACROSS ALL DEVICES")
        
        # Collect all unique field paths
        all_fields = set()
        for device in devices:
            def collect_fields(obj, prefix=""):
                if isinstance(obj, dict):
                    for key in obj.keys():
                        field_path = f"{prefix}.{key}" if prefix else key
                        all_fields.add(field_path)
                        if isinstance(obj[key], dict):
                            collect_fields(obj[key], field_path)
            
            collect_fields(device)
        
        print(f"\nTotal unique field paths: {len(all_fields)}")
        print("\nAll fields (sorted):")
        for field in sorted(all_fields):
            print(f"  {field}")
        
        print_section("FIELD PRESENCE ANALYSIS")
        
        # Check how many devices have each potentially relevant field
        check_fields = ['pms_room', 'pms_room_id', 'location', 'room', 'room_id']
        
        for field_name in check_fields:
            count = sum(1 for d in devices if field_name in d)
            print(f"{field_name}: {count}/{len(devices)} devices")
        
        print_section("SAMPLE DEVICES (First 3)")
        
        for i, device in enumerate(devices[:3], 1):
            print(f"\n--- Device {i} ---")
            print(json.dumps(device, indent=2, default=str))
        
        print_section("DATA MAPPING ANALYSIS")
        
        print("\nExpected fields in app's DeviceModel:")
        expected_fields = [
            'id', 'name', 'type', 'status', 'pms_room_id',
            'ip_address', 'mac_address', 'location', 'last_seen',
            'model', 'serial_number', 'firmware'
        ]
        
        print("\nField mapping status:")
        for expected in expected_fields:
            # Check various forms
            found = False
            actual_field = None
            
            # Direct match
            if expected in all_fields:
                found = True
                actual_field = expected
            # Snake case variant
            elif expected.replace('_', '') in [f.replace('_', '') for f in all_fields]:
                found = True
                for f in all_fields:
                    if f.replace('_', '') == expected.replace('_', ''):
                        actual_field = f
                        break
            # Simplified match (just the key part)
            elif expected.split('_')[-1] in [f.split('.')[-1] for f in all_fields]:
                found = True
                for f in all_fields:
                    if f.split('.')[-1] == expected.split('_')[-1]:
                        actual_field = f
                        break
            
            status = "✓" if found else "✗"
            print(f"  {status} {expected} -> {actual_field if found else 'NOT FOUND'}")
        
        print_section("SUMMARY")
        
        print("\n1. Response Structure:")
        print(f"   - Type: {'LIST' if isinstance(data, list) else 'DICT'}")
        print(f"   - Total devices: {len(devices)}")
        
        print("\n2. PMS Room Data:")
        print(f"   - pms_room field exists: {'YES' if pms_fields else 'NO'}")
        print(f"   - pms_room_id field exists: {'YES' if any('pms_room_id' in str(f) for f in all_fields) else 'NO'}")
        print(f"   - location field exists: {'YES' if location_fields else 'NO'}")
        
        print("\n3. Available Device Fields:")
        top_level_fields = [f for f in all_fields if '.' not in f]
        print(f"   Top-level fields: {', '.join(sorted(top_level_fields)[:10])}")
        
        print("\n4. Mock Data Adjustments Needed:")
        print("   Based on the actual API response, mock data should:")
        if not pms_fields and not location_fields:
            print("   - Set pmsRoomId to null (field doesn't exist in API)")
            print("   - Set location to null (field doesn't exist in API)")
        else:
            print("   - Match the exact structure found in API")
        
    except requests.RequestException as e:
        print(f"\nRequest error: {e}")
        return 1
    except json.JSONDecodeError as e:
        print(f"\nJSON parsing error: {e}")
        return 1
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(test_staging_api())