#!/usr/bin/env python3
"""
API Performance Analysis Script V2
Handles both list and object API responses
"""

import time
import json
import requests
from typing import Dict, List, Tuple, Optional, Any, Union
import statistics
from datetime import datetime
import concurrent.futures
import threading

# Configuration
API_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

# Thread-safe timing storage
timing_lock = threading.Lock()
timings = {}

def normalize_api_response(data: Union[List, Dict]) -> Dict:
    """Normalize API response to always have a results key"""
    if isinstance(data, list):
        return {'results': data, 'total': len(data)}
    elif isinstance(data, dict):
        if 'results' not in data and isinstance(data, dict):
            # Might be a single object response
            return {'results': [data], 'total': 1}
        return data
    return {'results': [], 'total': 0}

def measure_time(func):
    """Decorator to measure function execution time"""
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        duration = (end - start) * 1000  # Convert to milliseconds
        
        func_name = func.__name__
        with timing_lock:
            if func_name not in timings:
                timings[func_name] = []
            timings[func_name].append(duration)
        
        return result, duration
    return wrapper

@measure_time
def fetch_rooms_paginated(page: int = 1, page_size: int = 100) -> Dict:
    """Fetch rooms with pagination"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    url = f"{API_URL}/api/pms_rooms.json?page={page}&page_size={page_size}"
    response = requests.get(url, headers=headers, timeout=30)
    response.raise_for_status()
    return normalize_api_response(response.json())

@measure_time
def fetch_all_rooms_single_request() -> Dict:
    """Fetch all rooms in a single request (page_size=0)"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    url = f"{API_URL}/api/pms_rooms.json?page_size=0"
    response = requests.get(url, headers=headers, timeout=60)
    response.raise_for_status()
    return normalize_api_response(response.json())

@measure_time
def fetch_access_points(page_size: int = 0) -> Dict:
    """Fetch all access points"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    url = f"{API_URL}/api/access_points.json?page_size={page_size}"
    response = requests.get(url, headers=headers, timeout=60)
    response.raise_for_status()
    return normalize_api_response(response.json())

@measure_time
def fetch_switches(page_size: int = 0) -> Dict:
    """Fetch all switches"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    url = f"{API_URL}/api/switch_devices.json?page_size={page_size}"
    response = requests.get(url, headers=headers, timeout=60)
    response.raise_for_status()
    return normalize_api_response(response.json())

@measure_time
def fetch_media_converters(page_size: int = 0) -> Dict:
    """Fetch all media converters/ONTs"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    url = f"{API_URL}/api/media_converters.json?page_size={page_size}"
    response = requests.get(url, headers=headers, timeout=60)
    response.raise_for_status()
    return normalize_api_response(response.json())

@measure_time
def fetch_wlan_controllers(page_size: int = 0) -> Dict:
    """Fetch all WLAN controllers"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    url = f"{API_URL}/api/wlan_devices.json?page_size={page_size}"
    response = requests.get(url, headers=headers, timeout=60)
    response.raise_for_status()
    return normalize_api_response(response.json())

def extract_devices_from_rooms(rooms_data: Dict) -> Tuple[int, int, Dict]:
    """Extract device counts and details from rooms data"""
    total_devices = 0
    unique_devices = set()
    device_details = {
        'access_points': [],
        'media_converters': []
    }
    
    results = rooms_data.get('results', [])
    for room in results:
        # Count access points
        aps = room.get('access_points', []) if isinstance(room, dict) else []
        for ap in aps:
            if isinstance(ap, dict) and ap.get('id'):
                unique_devices.add(f"ap_{ap['id']}")
                device_details['access_points'].append(ap)
                total_devices += 1
        
        # Count media converters
        mcs = room.get('media_converters', []) if isinstance(room, dict) else []
        for mc in mcs:
            if isinstance(mc, dict) and mc.get('id'):
                unique_devices.add(f"mc_{mc['id']}")
                device_details['media_converters'].append(mc)
                total_devices += 1
    
    return total_devices, len(unique_devices), device_details

def parallel_fetch_all_endpoints():
    """Fetch all endpoints in parallel"""
    print("\n" + "="*80)
    print("PARALLEL FETCH TEST (Current App Implementation)")
    print("="*80)
    
    start_total = time.perf_counter()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        # Submit all requests simultaneously
        futures = {
            'rooms': executor.submit(fetch_all_rooms_single_request),
            'access_points': executor.submit(fetch_access_points),
            'switches': executor.submit(fetch_switches),
            'media_converters': executor.submit(fetch_media_converters),
            'wlan_controllers': executor.submit(fetch_wlan_controllers)
        }
        
        results = {}
        individual_times = {}
        
        # Collect results as they complete
        for name, future in futures.items():
            try:
                data, duration = future.result()
                results[name] = data
                individual_times[name] = duration
                item_count = len(data.get('results', []))
                print(f"  {name:20s}: {duration:8.2f} ms - {item_count:4d} items")
            except Exception as e:
                print(f"  {name:20s}: ERROR - {str(e)[:50]}")
                results[name] = None
                individual_times[name] = 0
    
    end_total = time.perf_counter()
    total_parallel_time = (end_total - start_total) * 1000
    
    # Calculate total items
    total_items = sum(len(r.get('results', [])) for r in results.values() if r)
    
    print(f"\n  Total Parallel Time: {total_parallel_time:.2f} ms")
    print(f"  Total Items Fetched: {total_items}")
    if individual_times:
        max_time = max(individual_times.values())
        if max_time > 0:
            print(f"  Max Individual Time: {max_time:.2f} ms")
            if total_parallel_time > 0:
                speedup = sum(individual_times.values()) / total_parallel_time
                print(f"  Parallelization Speedup: {speedup:.2f}x")
    
    return results, total_parallel_time

def test_rooms_with_embedded_devices():
    """Test if rooms endpoint already includes device data"""
    print("\n" + "="*80)
    print("ROOMS ENDPOINT DEVICE ANALYSIS")
    print("="*80)
    
    try:
        rooms_data, duration = fetch_all_rooms_single_request()
        results = rooms_data.get('results', [])
        
        print(f"  Fetch time: {duration:.2f} ms")
        print(f"  Total rooms: {len(results)}")
        
        # Analyze embedded device data
        total_devices, unique_devices, device_details = extract_devices_from_rooms(rooms_data)
        
        rooms_with_devices = 0
        for r in results:
            if isinstance(r, dict):
                if r.get('access_points') or r.get('media_converters'):
                    rooms_with_devices += 1
        
        print(f"  Rooms with devices: {rooms_with_devices}")
        print(f"  Total embedded devices: {total_devices}")
        print(f"  Unique embedded devices: {unique_devices}")
        
        # Check data completeness
        if device_details['access_points']:
            sample_ap = device_details['access_points'][0]
            important_fields = ['id', 'name', 'ip_address', 'mac_address', 'online', 'model']
            present_fields = [f for f in important_fields if f in sample_ap]
            print(f"\n  Embedded AP has fields: {present_fields}")
            print(f"  Data completeness: {len(present_fields)}/{len(important_fields)} critical fields")
        
        return rooms_data, duration
        
    except Exception as e:
        print(f"  ERROR: {e}")
        import traceback
        traceback.print_exc()
        return None, 0

def measure_data_processing_time():
    """Measure how long it takes to process the data after fetching"""
    print("\n" + "="*80)
    print("DATA PROCESSING TIME ANALYSIS")
    print("="*80)
    
    try:
        # Fetch the data
        print("  Fetching rooms data...")
        start_fetch = time.perf_counter()
        headers = {
            'Authorization': f'Bearer {API_KEY}',
            'Accept': 'application/json'
        }
        response = requests.get(f"{API_URL}/api/pms_rooms.json?page_size=0", 
                               headers=headers, timeout=60)
        end_fetch = time.perf_counter()
        fetch_time = (end_fetch - start_fetch) * 1000
        
        # Parse JSON
        print("  Parsing JSON...")
        start_parse = time.perf_counter()
        data = response.json()
        normalized = normalize_api_response(data)
        end_parse = time.perf_counter()
        parse_time = (end_parse - start_parse) * 1000
        
        # Extract devices (simulate app processing)
        print("  Extracting devices...")
        start_extract = time.perf_counter()
        results = normalized.get('results', [])
        devices = []
        for room in results:
            if isinstance(room, dict):
                # Simulate DeviceModel creation
                room_id = room.get('id')
                room_name = room.get('name') or room.get('room')
                
                # Process access points
                for ap in room.get('access_points', []):
                    if isinstance(ap, dict):
                        device = {
                            'id': f"ap_{ap.get('id')}",
                            'name': ap.get('name', f"AP-{ap.get('id')}"),
                            'type': 'access_point',
                            'status': 'online' if ap.get('online') else 'offline',
                            'location': room_name
                        }
                        devices.append(device)
                
                # Process media converters
                for mc in room.get('media_converters', []):
                    if isinstance(mc, dict):
                        device = {
                            'id': f"mc_{mc.get('id')}",
                            'name': mc.get('name', f"ONT-{mc.get('id')}"),
                            'type': 'media_converter',
                            'status': 'online' if mc.get('online') else 'offline',
                            'location': room_name
                        }
                        devices.append(device)
        
        end_extract = time.perf_counter()
        extract_time = (end_extract - start_extract) * 1000
        
        print(f"\n  Network Fetch: {fetch_time:.2f} ms")
        print(f"  JSON Parsing: {parse_time:.2f} ms")
        print(f"  Device Extraction: {extract_time:.2f} ms")
        print(f"  Total Time: {fetch_time + parse_time + extract_time:.2f} ms")
        print(f"\n  Rooms processed: {len(results)}")
        print(f"  Devices extracted: {len(devices)}")
        
        # Show time breakdown
        total = fetch_time + parse_time + extract_time
        print(f"\n  Time Breakdown:")
        print(f"    Network: {fetch_time/total*100:.1f}%")
        print(f"    Parsing: {parse_time/total*100:.1f}%")
        print(f"    Processing: {extract_time/total*100:.1f}%")
        
    except Exception as e:
        print(f"  ERROR: {e}")
        import traceback
        traceback.print_exc()

def test_incremental_loading():
    """Test incremental loading strategy"""
    print("\n" + "="*80)
    print("INCREMENTAL LOADING STRATEGY TEST")
    print("="*80)
    
    try:
        # Phase 1: Get counts only (minimal data)
        print("\n  Phase 1: Quick Overview (counts only)")
        start = time.perf_counter()
        
        headers = {
            'Authorization': f'Bearer {API_KEY}',
            'Accept': 'application/json'
        }
        
        # Get just the first item to get total count
        response = requests.get(f"{API_URL}/api/pms_rooms.json?page=1&page_size=1", 
                               headers=headers, timeout=10)
        data = response.json()
        normalized = normalize_api_response(data)
        
        end = time.perf_counter()
        overview_time = (end - start) * 1000
        
        total_rooms = normalized.get('total', len(normalized.get('results', [])))
        print(f"    Time: {overview_time:.2f} ms")
        print(f"    Total rooms available: {total_rooms}")
        
        # Phase 2: Get first batch for immediate display
        print("\n  Phase 2: Initial Display (first 20 rooms)")
        start = time.perf_counter()
        
        response = requests.get(f"{API_URL}/api/pms_rooms.json?page=1&page_size=20", 
                               headers=headers, timeout=10)
        initial_data = normalize_api_response(response.json())
        
        end = time.perf_counter()
        initial_time = (end - start) * 1000
        
        print(f"    Time: {initial_time:.2f} ms")
        print(f"    Rooms loaded: {len(initial_data.get('results', []))}")
        
        # Phase 3: Background load remaining
        print("\n  Phase 3: Background Load (remaining rooms)")
        print(f"    Would load {total_rooms - 20} more rooms in background")
        print(f"    User can interact immediately after {overview_time + initial_time:.2f} ms")
        
    except Exception as e:
        print(f"  ERROR: {e}")

def main():
    print("="*80)
    print("API PERFORMANCE ANALYSIS V2")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print(f"API URL: {API_URL}")
    print("="*80)
    
    # 1. Test rooms endpoint with embedded devices
    rooms_data, rooms_time = test_rooms_with_embedded_devices()
    
    # 2. Measure data processing time
    measure_data_processing_time()
    
    # 3. Test parallel fetching (current app approach)
    parallel_results, parallel_time = parallel_fetch_all_endpoints()
    
    # 4. Test incremental loading strategy
    test_incremental_loading()
    
    # Performance Summary
    print("\n" + "="*80)
    print("KEY FINDINGS")
    print("="*80)
    
    if rooms_data:
        total_devices, unique_devices, _ = extract_devices_from_rooms(rooms_data)
        if unique_devices > 0:
            print(f"\n  🔍 DISCOVERY: Rooms endpoint already includes {unique_devices} devices!")
            print("     No need to fetch devices separately if room data is sufficient")
    
    print("\n  ⏱️ PERFORMANCE BOTTLENECKS:")
    print("     1. Network latency (largest component)")
    print("     2. Fetching unnecessary endpoints")
    print("     3. No incremental loading")
    
    print("\n" + "="*80)
    print("OPTIMIZATION RECOMMENDATIONS")
    print("="*80)
    
    print("\n  🚀 IMMEDIATE WINS (No architecture changes):")
    print("     1. Use rooms endpoint only (skip device endpoints)")
    print("     2. Implement incremental loading (show first 20 immediately)")
    print("     3. Cache aggressively with 5-minute TTL")
    
    print("\n  📊 PROGRESSIVE LOADING STRATEGY:")
    print("     1. Fetch room counts (< 500ms)")
    print("     2. Load first 20 rooms for immediate display")
    print("     3. Background load remaining rooms")
    print("     4. User sees data in < 1 second")
    
    print("\n  🏗️ ARCHITECTURE IMPROVEMENTS (Clean Architecture compliant):")
    print("     1. Add caching layer in Repository (follows Repository pattern)")
    print("     2. Implement pagination in UseCase (business logic)")
    print("     3. Add loading states in ViewModel (MVVM pattern)")
    print("     4. Progressive UI updates via Riverpod AsyncValue")

if __name__ == "__main__":
    main()