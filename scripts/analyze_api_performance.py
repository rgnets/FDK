#!/usr/bin/env python3
"""
API Performance Analysis Script
Measures exact timing for each part of the data loading pipeline
"""

import time
import json
import requests
from typing import Dict, List, Tuple, Optional
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
    return response.json()

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
    return response.json()

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
    return response.json()

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
    return response.json()

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
    return response.json()

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
    return response.json()

def extract_devices_from_rooms(rooms_data: Dict) -> Tuple[int, int]:
    """Extract device counts from rooms data"""
    total_devices = 0
    unique_devices = set()
    
    results = rooms_data.get('results', [])
    for room in results:
        # Count access points
        aps = room.get('access_points', [])
        for ap in aps:
            if ap.get('id'):
                unique_devices.add(f"ap_{ap['id']}")
                total_devices += 1
        
        # Count media converters
        mcs = room.get('media_converters', [])
        for mc in mcs:
            if mc.get('id'):
                unique_devices.add(f"mc_{mc['id']}")
                total_devices += 1
    
    return total_devices, len(unique_devices)

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
                print(f"  {name:20s}: {duration:8.2f} ms - {len(data.get('results', []))} items")
            except Exception as e:
                print(f"  {name:20s}: ERROR - {e}")
                results[name] = None
                individual_times[name] = 0
    
    end_total = time.perf_counter()
    total_parallel_time = (end_total - start_total) * 1000
    
    print(f"\n  Total Parallel Time: {total_parallel_time:.2f} ms")
    print(f"  Max Individual Time: {max(individual_times.values()):.2f} ms")
    print(f"  Parallelization Speedup: {sum(individual_times.values()) / total_parallel_time:.2f}x")
    
    return results, total_parallel_time

def sequential_fetch_all_endpoints():
    """Fetch all endpoints sequentially"""
    print("\n" + "="*80)
    print("SEQUENTIAL FETCH TEST")
    print("="*80)
    
    start_total = time.perf_counter()
    results = {}
    individual_times = {}
    
    # Fetch each endpoint one by one
    endpoints = [
        ('rooms', fetch_all_rooms_single_request),
        ('access_points', fetch_access_points),
        ('switches', fetch_switches),
        ('media_converters', fetch_media_converters),
        ('wlan_controllers', fetch_wlan_controllers)
    ]
    
    for name, fetch_func in endpoints:
        try:
            data, duration = fetch_func()
            results[name] = data
            individual_times[name] = duration
            print(f"  {name:20s}: {duration:8.2f} ms - {len(data.get('results', []))} items")
        except Exception as e:
            print(f"  {name:20s}: ERROR - {e}")
            results[name] = None
            individual_times[name] = 0
    
    end_total = time.perf_counter()
    total_sequential_time = (end_total - start_total) * 1000
    
    print(f"\n  Total Sequential Time: {total_sequential_time:.2f} ms")
    print(f"  Sum of Individual Times: {sum(individual_times.values()):.2f} ms")
    
    return results, total_sequential_time

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
        total_devices, unique_devices = extract_devices_from_rooms(rooms_data)
        
        rooms_with_devices = sum(1 for r in results if r.get('access_points') or r.get('media_converters'))
        
        print(f"  Rooms with devices: {rooms_with_devices}")
        print(f"  Total embedded devices: {total_devices}")
        print(f"  Unique embedded devices: {unique_devices}")
        
        # Check data completeness
        sample_room = next((r for r in results if r.get('access_points')), None)
        if sample_room and sample_room.get('access_points'):
            sample_ap = sample_room['access_points'][0]
            print(f"\n  Sample embedded AP fields: {list(sample_ap.keys())[:10]}")
            has_full_data = 'ip_address' in sample_ap and 'mac_address' in sample_ap
            print(f"  Has full device data: {has_full_data}")
        
        return rooms_data, duration
        
    except Exception as e:
        print(f"  ERROR: {e}")
        return None, 0

def test_pagination_performance():
    """Test different pagination strategies"""
    print("\n" + "="*80)
    print("PAGINATION PERFORMANCE TEST")
    print("="*80)
    
    test_cases = [
        (10, "Small pages (10 items)"),
        (50, "Medium pages (50 items)"),
        (100, "Large pages (100 items)"),
        (0, "All items (no pagination)")
    ]
    
    for page_size, description in test_cases:
        try:
            if page_size == 0:
                data, duration = fetch_all_rooms_single_request()
                print(f"  {description:30s}: {duration:8.2f} ms - {len(data.get('results', []))} items")
            else:
                # Fetch first page to get total count
                data, duration = fetch_rooms_paginated(1, page_size)
                total_items = data.get('total', 0)
                total_pages = (total_items + page_size - 1) // page_size
                print(f"  {description:30s}: {duration:8.2f} ms/page - {total_pages} pages needed")
                
        except Exception as e:
            print(f"  {description:30s}: ERROR - {e}")

def analyze_data_transfer_size():
    """Analyze the size of data being transferred"""
    print("\n" + "="*80)
    print("DATA TRANSFER SIZE ANALYSIS")
    print("="*80)
    
    endpoints = [
        ('rooms', fetch_all_rooms_single_request),
        ('access_points', fetch_access_points),
        ('switches', fetch_switches),
        ('media_converters', fetch_media_converters),
        ('wlan_controllers', fetch_wlan_controllers)
    ]
    
    total_size = 0
    for name, fetch_func in endpoints:
        try:
            data, duration = fetch_func()
            json_str = json.dumps(data)
            size_bytes = len(json_str.encode('utf-8'))
            size_kb = size_bytes / 1024
            size_mb = size_kb / 1024
            
            items = len(data.get('results', []))
            avg_size = size_kb / items if items > 0 else 0
            
            print(f"  {name:20s}: {size_kb:8.2f} KB ({size_mb:5.2f} MB) - {items:4d} items - {avg_size:6.2f} KB/item")
            total_size += size_kb
            
        except Exception as e:
            print(f"  {name:20s}: ERROR - {e}")
    
    print(f"\n  Total data size: {total_size:.2f} KB ({total_size/1024:.2f} MB)")

def test_summary_endpoint_concept():
    """Test if we can get summary data more efficiently"""
    print("\n" + "="*80)
    print("SUMMARY DATA CONCEPT TEST")
    print("="*80)
    
    print("\n  Testing lightweight overview approach:")
    
    # Test fetching just first page of each endpoint for overview
    start = time.perf_counter()
    
    overview = {}
    endpoints = [
        ('rooms', f"{API_URL}/api/pms_rooms.json?page=1&page_size=1"),
        ('access_points', f"{API_URL}/api/access_points.json?page=1&page_size=1"),
        ('switches', f"{API_URL}/api/switch_devices.json?page=1&page_size=1"),
        ('media_converters', f"{API_URL}/api/media_converters.json?page=1&page_size=1"),
        ('wlan_controllers', f"{API_URL}/api/wlan_devices.json?page=1&page_size=1")
    ]
    
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    
    for name, url in endpoints:
        try:
            response = requests.get(url, headers=headers, timeout=10)
            data = response.json()
            overview[name] = {
                'total': data.get('total', 0),
                'page_count': data.get('page_count', 0)
            }
            print(f"    {name:20s}: {overview[name]['total']:5d} total items")
        except Exception as e:
            print(f"    {name:20s}: ERROR - {e}")
    
    end = time.perf_counter()
    overview_time = (end - start) * 1000
    
    print(f"\n  Overview fetch time: {overview_time:.2f} ms")
    print("  This provides counts without full data transfer")

def main():
    print("="*80)
    print("API PERFORMANCE ANALYSIS")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print(f"API URL: {API_URL}")
    print("="*80)
    
    # 1. Test rooms endpoint with embedded devices
    rooms_data, rooms_time = test_rooms_with_embedded_devices()
    
    # 2. Test parallel fetching (current app approach)
    parallel_results, parallel_time = parallel_fetch_all_endpoints()
    
    # 3. Test sequential fetching for comparison
    sequential_results, sequential_time = sequential_fetch_all_endpoints()
    
    # 4. Test pagination strategies
    test_pagination_performance()
    
    # 5. Analyze data transfer sizes
    analyze_data_transfer_size()
    
    # 6. Test summary/overview concept
    test_summary_endpoint_concept()
    
    # Performance Summary
    print("\n" + "="*80)
    print("PERFORMANCE SUMMARY")
    print("="*80)
    
    print(f"\n  Sequential Total: {sequential_time:.2f} ms")
    print(f"  Parallel Total: {parallel_time:.2f} ms")
    print(f"  Speedup from parallelization: {sequential_time/parallel_time:.2f}x")
    
    if rooms_data:
        total_devices, unique_devices = extract_devices_from_rooms(rooms_data)
        if unique_devices > 0:
            print(f"\n  Rooms endpoint includes {unique_devices} devices")
            print("  ⚡ OPTIMIZATION: Rooms already contain device data!")
            print("  Could skip separate device endpoints if rooms data is sufficient")
    
    print("\n" + "="*80)
    print("RECOMMENDATIONS")
    print("="*80)
    
    print("\n  1. IMMEDIATE: Use rooms endpoint for device data (already embedded)")
    print("  2. LAZY LOADING: Fetch device details only when needed")
    print("  3. CACHING: Implement aggressive caching with TTL")
    print("  4. PAGINATION: Use page_size=0 for initial load (faster than pagination)")
    print("  5. PROGRESSIVE: Load overview first, details on demand")

if __name__ == "__main__":
    main()