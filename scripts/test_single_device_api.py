#!/usr/bin/env python3
"""
Test Single Device API Endpoints
Verify exact data structure and fields returned for individual devices
"""

import json
import requests
import time
from typing import Dict, Any, Optional
from datetime import datetime

# Configuration
API_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def format_time(ms: float) -> str:
    """Format time in appropriate units"""
    if ms < 1000:
        return f"{ms:.0f}ms"
    else:
        return f"{ms/1000:.1f}s"

def format_size(bytes: int) -> str:
    """Format size in appropriate units"""
    if bytes < 1024:
        return f"{bytes}B"
    elif bytes < 1024 * 1024:
        return f"{bytes/1024:.1f}KB"
    else:
        return f"{bytes/(1024*1024):.2f}MB"

def test_single_device_endpoint(endpoint: str, device_id: str) -> Dict[str, Any]:
    """Test fetching a single device"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    
    url = f"{API_URL}/api/{endpoint}/{device_id}.json"
    
    print(f"\nTesting: GET {endpoint}/{device_id}.json")
    print("-" * 60)
    
    start = time.perf_counter()
    try:
        response = requests.get(url, headers=headers, timeout=30)
        elapsed = (time.perf_counter() - start) * 1000
        
        print(f"  Status: {response.status_code}")
        print(f"  Time: {format_time(elapsed)}")
        print(f"  Size: {format_size(len(response.content))}")
        
        if response.status_code == 200:
            data = response.json()
            
            # Analyze structure
            if isinstance(data, dict):
                print(f"  Type: Single object")
                print(f"  Fields: {len(data.keys())}")
                print(f"  Top-level keys: {list(data.keys())[:10]}")
                
                # Check for critical fields
                critical_fields = ['id', 'name', 'online', 'mac_address', 'ip_address', 
                                 'pms_room', 'pms_room_id', 'last_seen', 'updated_at']
                present = [f for f in critical_fields if f in data]
                missing = [f for f in critical_fields if f not in data]
                
                print(f"\n  Critical fields present: {present}")
                if missing:
                    print(f"  Critical fields missing: {missing}")
                
                return {
                    'success': True,
                    'time_ms': elapsed,
                    'size_bytes': len(response.content),
                    'data': data,
                    'field_count': len(data.keys())
                }
            else:
                print(f"  Unexpected response type: {type(data)}")
                return {'success': False, 'error': 'Unexpected response type'}
        else:
            print(f"  Error: HTTP {response.status_code}")
            print(f"  Response: {response.text[:200]}")
            return {'success': False, 'error': f'HTTP {response.status_code}'}
            
    except Exception as e:
        print(f"  Exception: {e}")
        return {'success': False, 'error': str(e)}

def find_valid_device_ids():
    """Find valid device IDs from list endpoints"""
    print("="*80)
    print("FINDING VALID DEVICE IDs")
    print("="*80)
    
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    
    device_ids = {}
    
    # Endpoints to check
    endpoints = [
        ('access_points', 'access_points'),
        ('switches', 'switch_devices'),
        ('media_converters', 'media_converters'),
        ('wlan_controllers', 'wlan_devices'),
        ('rooms', 'pms_rooms')
    ]
    
    for name, endpoint in endpoints:
        try:
            url = f"{API_URL}/api/{endpoint}.json?page_size=5"  # Get just a few
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                # Handle both list and object responses
                if isinstance(data, list):
                    items = data
                elif isinstance(data, dict) and 'results' in data:
                    items = data['results']
                else:
                    items = []
                
                if items:
                    # Get first valid ID
                    for item in items:
                        if isinstance(item, dict) and 'id' in item:
                            device_ids[name] = str(item['id'])
                            print(f"  {name:20s}: Found ID {item['id']} - {item.get('name', 'unnamed')}")
                            break
            
        except Exception as e:
            print(f"  {name:20s}: Error - {str(e)[:40]}")
    
    return device_ids

def test_all_single_endpoints():
    """Test single device fetch for all device types"""
    print("\n" + "="*80)
    print("SINGLE DEVICE API TESTING")
    print("="*80)
    
    # First find valid IDs
    device_ids = find_valid_device_ids()
    
    if not device_ids:
        print("\n❌ No valid device IDs found")
        return
    
    # Test each endpoint
    results = {}
    
    for device_type, device_id in device_ids.items():
        # Map to correct endpoint name
        endpoint_map = {
            'access_points': 'access_points',
            'switches': 'switch_devices',
            'media_converters': 'media_converters',
            'wlan_controllers': 'wlan_devices',
            'rooms': 'pms_rooms'
        }
        
        endpoint = endpoint_map.get(device_type, device_type)
        result = test_single_device_endpoint(endpoint, device_id)
        results[device_type] = result
    
    return results

def analyze_detail_view_requirements(results: Dict):
    """Analyze what data is available for detail views"""
    print("\n" + "="*80)
    print("DETAIL VIEW DATA ANALYSIS")
    print("="*80)
    
    for device_type, result in results.items():
        if result.get('success') and result.get('data'):
            data = result['data']
            
            print(f"\n{device_type.upper()} Detail View Fields:")
            print("-" * 60)
            
            # Categorize fields by importance
            categories = {
                'Identity': ['id', 'name', 'serial_number', 'mac_address'],
                'Status': ['online', 'status', 'last_seen', 'updated_at'],
                'Network': ['ip_address', 'mac_address', 'hostname', 'port'],
                'Location': ['pms_room', 'pms_room_id', 'location', 'building', 'floor'],
                'Hardware': ['model', 'firmware_version', 'hardware_version', 'manufacturer'],
                'Configuration': ['config', 'settings', 'profile', 'mode']
            }
            
            for category, fields in categories.items():
                present = [f for f in fields if f in data]
                if present:
                    print(f"  {category}:")
                    for field in present:
                        value = data[field]
                        if isinstance(value, dict):
                            print(f"    • {field}: <object with {len(value)} fields>")
                        elif isinstance(value, list):
                            print(f"    • {field}: <array with {len(value)} items>")
                        elif isinstance(value, str) and len(value) > 50:
                            print(f"    • {field}: {value[:50]}...")
                        else:
                            print(f"    • {field}: {value}")
            
            # Count total fields
            print(f"\n  Total fields available: {len(data.keys())}")
            print(f"  Response size: {format_size(result['size_bytes'])}")
            print(f"  Response time: {format_time(result['time_ms'])}")

def test_refresh_patterns():
    """Test different refresh patterns and their impact"""
    print("\n" + "="*80)
    print("REFRESH PATTERN ANALYSIS")
    print("="*80)
    
    # Calculate impact of 5-minute refresh
    refresh_intervals = [5, 10, 15, 30, 60]  # minutes
    work_hours = 8
    total_minutes = work_hours * 60
    
    print("\n📊 API Call Frequency Analysis (8-hour workday):")
    print("-" * 60)
    print("Interval | Refreshes | Bandwidth | Battery Impact")
    print("---------|-----------|-----------|---------------")
    
    for interval in refresh_intervals:
        refreshes = total_minutes // interval
        # Assume 38KB per refresh (from our tests)
        bandwidth_mb = (refreshes * 38) / 1024
        # Battery impact estimate (rough)
        battery_percent = refreshes * 0.1  # 0.1% per API call
        
        print(f"{interval:3d} min  | {refreshes:9d} | {bandwidth_mb:8.1f}MB | {battery_percent:.1f}%")
    
    print("\n⚠️ 5-Minute Refresh Considerations:")
    print("  • 96 API calls per day (vs 16 with 30-min)")
    print("  • 3.6MB daily bandwidth (vs 0.6MB)")
    print("  • ~10% battery drain from network alone")
    print("  • Risk of rate limiting from API")
    print("  • UI state management complexity")

def test_incremental_updates():
    """Test if API supports incremental updates"""
    print("\n" + "="*80)
    print("INCREMENTAL UPDATE TESTING")
    print("="*80)
    
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    
    # Test if API supports modified_since or similar
    test_params = [
        ('modified_since', '2025-08-24T00:00:00Z'),
        ('updated_after', '2025-08-24T00:00:00Z'),
        ('since', '2025-08-24T00:00:00Z'),
        ('if-modified-since', '2025-08-24T00:00:00Z')
    ]
    
    print("\nTesting incremental update parameters:")
    print("-" * 60)
    
    for param_name, param_value in test_params:
        try:
            url = f"{API_URL}/api/access_points.json?page_size=1&{param_name}={param_value}"
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code == 304:
                print(f"  {param_name:20s}: ✅ Supports incremental (304 Not Modified)")
            elif response.status_code == 200:
                data = response.json()
                # Check if response is filtered
                if isinstance(data, list):
                    count = len(data)
                elif isinstance(data, dict) and 'results' in data:
                    count = len(data['results'])
                else:
                    count = 0
                print(f"  {param_name:20s}: ❓ Returns 200 ({count} items)")
            else:
                print(f"  {param_name:20s}: ❌ Error {response.status_code}")
                
        except Exception as e:
            print(f"  {param_name:20s}: ❌ Exception: {str(e)[:30]}")
    
    print("\n💡 Incremental Update Strategy:")
    print("  If API doesn't support incremental updates:")
    print("  • Use ETag/Last-Modified headers for cache validation")
    print("  • Compare response hash to detect changes")
    print("  • Only update UI if data actually changed")

def main():
    print("="*80)
    print("COMPREHENSIVE REFRESH IMPACT ANALYSIS")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("="*80)
    
    # Test single device endpoints
    results = test_all_single_endpoints()
    
    if results:
        # Analyze detail view requirements
        analyze_detail_view_requirements(results)
    
    # Test refresh patterns
    test_refresh_patterns()
    
    # Test incremental updates
    test_incremental_updates()
    
    print("\n" + "="*80)
    print("KEY FINDINGS")
    print("="*80)
    
    print("\n✅ SINGLE DEVICE API:")
    if results:
        for device_type, result in results.items():
            if result.get('success'):
                print(f"  • {device_type}: {format_time(result['time_ms'])}, "
                      f"{format_size(result['size_bytes'])}, "
                      f"{result['field_count']} fields")
    
    print("\n⚠️ 5-MINUTE REFRESH RISKS:")
    print("  • 6x more API calls than 30-minute refresh")
    print("  • Potential UI flicker if not handled properly")
    print("  • Battery drain on mobile devices")
    print("  • Need careful state management to avoid disruption")
    
    print("\n✅ RECOMMENDED APPROACH:")
    print("  • 5-minute refresh ONLY when app is active AND on WiFi")
    print("  • 15-minute refresh on cellular")
    print("  • 30-minute refresh when backgrounded")
    print("  • Immediate refresh on detail view navigation")
    print("  • Pull-to-refresh on all screens")
    
    print("\n🔄 DETAIL VIEW REFRESH:")
    print("  • Trigger single-device API call on navigation")
    print("  • Show cached data immediately")
    print("  • Update UI smoothly when fresh data arrives")
    print("  • No loading spinner if cached data exists")

if __name__ == "__main__":
    main()