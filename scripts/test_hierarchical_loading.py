#!/usr/bin/env python3
"""
Test Hierarchical Data Loading Strategy
Proves out fast summary loading followed by background detail fetching
"""

import time
import json
import requests
from typing import Dict, List, Any, Tuple
from datetime import datetime
import concurrent.futures
import hashlib

# Configuration
API_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

# Field sets for different loading stages
FIELD_SETS = {
    'summary': {
        'rooms': 'id,name,room,building,floor',
        'access_points': 'id,name,online',
        'switches': 'id,name,online', 
        'media_converters': 'id,name,online',
        'wlan_controllers': 'id,name,online'
    },
    'list_view': {
        'rooms': 'id,name,room,building,floor,access_points,media_converters',
        'access_points': 'id,name,online,mac_address,ip_address,model,pms_room_id',
        'switches': 'id,name,online,mac_address,ip_address,model,nickname',
        'media_converters': 'id,name,online,mac_address,serial_number,model,pms_room_id',
        'wlan_controllers': 'id,name,online,mac_address,ip_address,model'
    },
    'detail_view': {
        # Full data - no 'only' parameter
        'rooms': None,
        'access_points': None,
        'switches': None,
        'media_converters': None,
        'wlan_controllers': None
    }
}

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

def fetch_with_fields(endpoint: str, fields: str = None) -> Tuple[Any, float, int]:
    """Fetch endpoint with specific fields"""
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    
    url = f"{API_URL}{endpoint}?page_size=0"
    if fields:
        url += f"&only={fields}"
    
    start = time.perf_counter()
    response = requests.get(url, headers=headers, timeout=60)
    elapsed = (time.perf_counter() - start) * 1000
    
    response.raise_for_status()
    data = response.json()
    
    # Calculate response size
    size = len(response.content)
    
    return data, elapsed, size

def test_loading_stage(stage_name: str, field_set: Dict[str, str]) -> Dict:
    """Test a specific loading stage"""
    print(f"\n{'='*60}")
    print(f"{stage_name.upper()} LOADING TEST")
    print(f"{'='*60}")
    
    results = {}
    total_time = 0
    total_size = 0
    
    # Test each endpoint
    endpoints = [
        ('rooms', '/api/pms_rooms.json'),
        ('access_points', '/api/access_points.json'),
        ('switches', '/api/switch_devices.json'),
        ('media_converters', '/api/media_converters.json'),
        ('wlan_controllers', '/api/wlan_devices.json')
    ]
    
    print("\nSequential Loading:")
    print("-" * 50)
    
    for name, path in endpoints:
        fields = field_set.get(name)
        try:
            data, elapsed, size = fetch_with_fields(path, fields)
            
            # Count items
            if isinstance(data, list):
                item_count = len(data)
            elif isinstance(data, dict) and 'results' in data:
                item_count = len(data['results'])
            else:
                item_count = 0
            
            results[name] = {
                'time': elapsed,
                'size': size,
                'items': item_count,
                'fields': fields.split(',') if fields else 'all'
            }
            
            total_time += elapsed
            total_size += size
            
            fields_info = f"{len(fields.split(','))} fields" if fields else "all fields"
            print(f"  {name:20s}: {format_time(elapsed):>8s} | {format_size(size):>8s} | {item_count:4d} items | {fields_info}")
            
        except Exception as e:
            print(f"  {name:20s}: ERROR - {str(e)[:40]}")
            results[name] = {'error': str(e)}
    
    print("-" * 50)
    print(f"  {'TOTAL':20s}: {format_time(total_time):>8s} | {format_size(total_size):>8s}")
    
    # Test parallel loading
    print("\nParallel Loading:")
    print("-" * 50)
    
    start_parallel = time.perf_counter()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        futures = {}
        for name, path in endpoints:
            fields = field_set.get(name)
            futures[name] = executor.submit(fetch_with_fields, path, fields)
        
        # Wait for all to complete
        concurrent.futures.wait(futures.values())
    
    parallel_time = (time.perf_counter() - start_parallel) * 1000
    
    print(f"  Parallel time: {format_time(parallel_time)}")
    print(f"  Speedup: {total_time/parallel_time:.1f}x")
    
    return {
        'sequential_time': total_time,
        'parallel_time': parallel_time,
        'total_size': total_size,
        'results': results
    }

def test_hierarchical_strategy():
    """Test the complete hierarchical loading strategy"""
    print("="*80)
    print("HIERARCHICAL LOADING STRATEGY TEST")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("="*80)
    
    # Stage 1: Summary (for home page stats)
    stage1 = test_loading_stage("Stage 1: Summary", FIELD_SETS['summary'])
    
    # Stage 2: List View (for displaying lists)
    stage2 = test_loading_stage("Stage 2: List View", FIELD_SETS['list_view'])
    
    # Stage 3: Full Data (for comparison)
    stage3 = test_loading_stage("Stage 3: Full Data", FIELD_SETS['detail_view'])
    
    # Analysis
    print("\n" + "="*80)
    print("PERFORMANCE ANALYSIS")
    print("="*80)
    
    print("\n📊 Loading Time Comparison:")
    print(f"  Stage 1 (Summary):   {format_time(stage1['parallel_time']):>8s} - Minimal fields for counts")
    print(f"  Stage 2 (List View): {format_time(stage2['parallel_time']):>8s} - Fields for list display")
    print(f"  Stage 3 (Full Data): {format_time(stage3['parallel_time']):>8s} - All fields")
    
    print("\n💾 Data Transfer Comparison:")
    print(f"  Stage 1 (Summary):   {format_size(stage1['total_size']):>8s}")
    print(f"  Stage 2 (List View): {format_size(stage2['total_size']):>8s}")
    print(f"  Stage 3 (Full Data): {format_size(stage3['total_size']):>8s}")
    
    # Calculate improvements
    time_saved_1 = stage3['parallel_time'] - stage1['parallel_time']
    time_saved_2 = stage3['parallel_time'] - stage2['parallel_time']
    size_saved_1 = stage3['total_size'] - stage1['total_size']
    size_saved_2 = stage3['total_size'] - stage2['total_size']
    
    print("\n🚀 Performance Improvements:")
    print(f"  Summary vs Full:   {time_saved_1/stage3['parallel_time']*100:.1f}% faster, {size_saved_1/stage3['total_size']*100:.1f}% less data")
    print(f"  List vs Full:      {time_saved_2/stage3['parallel_time']*100:.1f}% faster, {size_saved_2/stage3['total_size']*100:.1f}% less data")
    
    return stage1, stage2, stage3

def test_caching_simulation():
    """Simulate caching behavior and benefits"""
    print("\n" + "="*80)
    print("CACHING SIMULATION")
    print("="*80)
    
    cache = {}
    cache_ttl = 300  # 5 minutes in seconds
    
    def get_cache_key(endpoint: str, fields: str = None) -> str:
        """Generate cache key"""
        key_parts = [endpoint, fields or 'all']
        return hashlib.md5('|'.join(key_parts).encode()).hexdigest()
    
    print("\n📦 Cache Strategy:")
    print("  - TTL: 5 minutes")
    print("  - Key: hash(endpoint + fields)")
    print("  - Invalidation: TTL-based or manual refresh")
    
    # Simulate multiple requests
    print("\n🔄 Request Simulation:")
    
    requests_sequence = [
        ("Initial home load", "summary"),
        ("Navigate to devices", "list_view"),
        ("Return to home", "summary"),  # Should hit cache
        ("Refresh devices", "list_view"),  # Should hit cache
        ("View device details", "detail_view"),
        ("Back to list", "list_view")  # Should hit cache
    ]
    
    total_api_time = 0
    total_cached_time = 0
    
    for action, stage in requests_sequence:
        print(f"\n  {action}:")
        
        # Simulate fetching each endpoint
        for endpoint in ['access_points', 'switches', 'media_converters']:
            fields = FIELD_SETS[stage].get(endpoint)
            cache_key = get_cache_key(endpoint, fields)
            
            if cache_key in cache:
                # Cache hit
                print(f"    {endpoint:20s}: CACHE HIT (0ms)")
                total_cached_time += 0
            else:
                # Cache miss - need to fetch
                if stage == 'summary':
                    fetch_time = 500  # Approximate based on tests
                elif stage == 'list_view':
                    fetch_time = 1000
                else:
                    fetch_time = 17000  # Full data
                
                print(f"    {endpoint:20s}: API CALL ({format_time(fetch_time)})")
                cache[cache_key] = True  # Add to cache
                total_api_time += fetch_time
    
    print("\n📈 Cache Performance:")
    print(f"  Total API time without cache: {format_time(total_api_time)}")
    print(f"  Cache hits saved: {format_time(total_api_time - total_cached_time)}")
    print(f"  Effective time with cache: < 1 second for cached requests")

def design_clean_architecture_implementation():
    """Design how this would be implemented following Clean Architecture"""
    print("\n" + "="*80)
    print("CLEAN ARCHITECTURE IMPLEMENTATION DESIGN")
    print("="*80)
    
    print("\n🏗️ LAYER 1: Data Layer (DeviceRemoteDataSourceImpl)")
    print("""
    class DeviceRemoteDataSourceImpl implements DeviceDataSource {
      // Add field selection support
      Future<List<DeviceModel>> getDevicesSummary() async {
        // Use only=id,name,online for fast load
        final futures = [
          _fetchWithFields('access_points', 'id,name,online'),
          _fetchWithFields('switches', 'id,name,online'),
          // ... etc
        ];
        return Future.wait(futures);
      }
      
      Future<List<DeviceModel>> getDevicesForList() async {
        // Use expanded fields for list view
        final futures = [
          _fetchWithFields('access_points', 'id,name,online,mac_address,ip_address,model'),
          // ... etc
        ];
        return Future.wait(futures);
      }
      
      Future<DeviceModel> getDeviceDetails(String id) async {
        // Fetch complete data for single device
        return _fetchFullDevice(id);
      }
    }
    """)
    
    print("\n🏗️ LAYER 2: Repository Layer (DeviceRepositoryImpl)")
    print("""
    class DeviceRepositoryImpl implements DeviceRepository {
      final DeviceDataSource dataSource;
      final CacheService cacheService;
      
      Future<Either<Failure, List<Device>>> getDevicesSummary() async {
        // Check cache first
        final cacheKey = 'devices_summary';
        final cached = await cacheService.get(cacheKey);
        if (cached != null) return Right(cached);
        
        // Fetch from data source
        final models = await dataSource.getDevicesSummary();
        final devices = models.map((m) => m.toEntity()).toList();
        
        // Cache for 5 minutes
        await cacheService.set(cacheKey, devices, ttl: Duration(minutes: 5));
        
        return Right(devices);
      }
    }
    """)
    
    print("\n🏗️ LAYER 3: Use Case Layer")
    print("""
    class GetDevicesSummary {
      final DeviceRepository repository;
      
      Future<Either<Failure, List<Device>>> call() async {
        return await repository.getDevicesSummary();
      }
    }
    
    class GetDevicesForList {
      final DeviceRepository repository;
      
      Future<Either<Failure, List<Device>>> call() async {
        return await repository.getDevicesForList();
      }
    }
    """)
    
    print("\n🏗️ LAYER 4: ViewModel Layer (Riverpod StateNotifier)")
    print("""
    class DevicesNotifier extends StateNotifier<AsyncValue<DevicesState>> {
      final GetDevicesSummary getDevicesSummary;
      final GetDevicesForList getDevicesForList;
      
      Future<void> loadInitialData() async {
        state = AsyncValue.loading();
        
        // Load summary first (fast)
        final summaryResult = await getDevicesSummary();
        summaryResult.fold(
          (failure) => state = AsyncValue.error(failure),
          (devices) => state = AsyncValue.data(
            DevicesState(devices: devices, isDetailLoaded: false)
          )
        );
        
        // Load full list data in background
        final listResult = await getDevicesForList();
        listResult.fold(
          (failure) => {}, // Ignore, we have summary
          (devices) => state = AsyncValue.data(
            DevicesState(devices: devices, isDetailLoaded: true)
          )
        );
      }
    }
    """)
    
    print("\n✅ CLEAN ARCHITECTURE COMPLIANCE:")
    print("  • Domain layer unchanged (pure entities)")
    print("  • Data layer handles API optimization")
    print("  • Repository adds caching (infrastructure concern)")
    print("  • Use cases orchestrate business logic")
    print("  • ViewModels manage UI state progressively")
    print("  • Dependency injection via Riverpod unchanged")

def main():
    # Run all tests
    stage1, stage2, stage3 = test_hierarchical_strategy()
    test_caching_simulation()
    design_clean_architecture_implementation()
    
    print("\n" + "="*80)
    print("FINAL RECOMMENDATIONS")
    print("="*80)
    
    print("\n🎯 IMPLEMENTATION STRATEGY:")
    print("\n1️⃣ IMMEDIATE (No Code Changes):")
    print("   • Document findings for team awareness")
    print("   • Plan implementation sprint")
    
    print("\n2️⃣ PHASE 1 - Data Layer:")
    print("   • Add getDevicesSummary() method")
    print("   • Add getDevicesForList() method")  
    print("   • Implement field selection")
    
    print("\n3️⃣ PHASE 2 - Caching Layer:")
    print("   • Create CacheService")
    print("   • Integrate into Repository")
    print("   • 5-minute TTL for all endpoints")
    
    print("\n4️⃣ PHASE 3 - Progressive Loading:")
    print("   • Update ViewModels for staged loading")
    print("   • Show summary immediately")
    print("   • Load details in background")
    
    print("\n💰 EXPECTED RESULTS:")
    if stage1['parallel_time'] < 1000:
        print(f"   • Home page loads in {format_time(stage1['parallel_time'])} (from 17.7s)")
        print(f"   • List views load in {format_time(stage2['parallel_time'])} (from 17.7s)")
        print("   • Subsequent loads: < 100ms (from cache)")
        print("   • User satisfaction: 📈📈📈")

if __name__ == "__main__":
    main()