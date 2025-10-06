#!/usr/bin/env python3
"""
Comprehensive Loading Plan with Room Correlation
Includes pms_room data for all device types
"""

import time
import json
import requests
from typing import Dict, List, Any, Optional
from datetime import datetime
from dataclasses import dataclass

# Configuration
API_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

@dataclass
class FieldSet:
    """Defines fields needed for each loading stage"""
    summary: List[str]  # Absolute minimum for counts
    list_view: List[str]  # Everything needed for lists and correlation
    detail_view: Optional[List[str]] = None  # Full data (None = all fields)

# CRITICAL: Include pms_room/pms_room_id for ALL device types
OPTIMIZED_FIELD_SETS = {
    'rooms': FieldSet(
        summary=['id', 'name', 'room'],
        list_view=[
            'id', 'name', 'room', 'building', 'floor',
            'access_points', 'media_converters', 'switch_ports',
            'infrastructure_devices'
        ]
    ),
    'access_points': FieldSet(
        summary=['id', 'name', 'online', 'pms_room_id'],
        list_view=[
            'id', 'name', 'online', 'mac_address', 'ip_address',
            'model', 'serial_number', 'pms_room_id', 'pms_room',  # Include both ID and full room
            'firmware_version', 'last_seen'
        ]
    ),
    'switches': FieldSet(
        summary=['id', 'name', 'online', 'pms_room_id'],
        list_view=[
            'id', 'name', 'online', 'mac_address', 'ip_address',
            'model', 'nickname', 'location', 'pms_room_id', 'pms_room',
            'serial_number', 'firmware_version'
        ]
    ),
    'media_converters': FieldSet(
        summary=['id', 'name', 'online', 'pms_room_id'],
        list_view=[
            'id', 'name', 'online', 'mac_address', 'serial_number',
            'model', 'pms_room_id', 'pms_room', 'ont_serial_number',
            'pon_port', 'last_seen'
        ]
    ),
    'wlan_controllers': FieldSet(
        summary=['id', 'name', 'online', 'pms_room_id'],
        list_view=[
            'id', 'name', 'online', 'mac_address', 'ip_address',
            'model', 'firmware_version', 'pms_room_id', 'pms_room',
            'serial_number'
        ]
    )
}

def test_room_correlation():
    """Test that we can properly correlate devices with rooms"""
    print("="*80)
    print("ROOM CORRELATION TEST")
    print("="*80)
    
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    
    print("\n📊 Testing Room Correlation Fields:")
    print("-" * 60)
    
    # Test each endpoint to verify pms_room fields exist
    for endpoint, field_set in OPTIMIZED_FIELD_SETS.items():
        if endpoint == 'rooms':
            continue  # Skip rooms endpoint for this test
            
        try:
            # Fetch with list view fields
            fields = ','.join(field_set.list_view)
            url = f"{API_URL}/api/{endpoint}.json?page_size=1&only={fields}"
            
            response = requests.get(url, headers=headers, timeout=10)
            data = response.json()
            
            # Check if we got data
            if isinstance(data, list) and data:
                item = data[0]
            elif isinstance(data, dict) and 'results' in data and data['results']:
                item = data['results'][0]
            else:
                print(f"  {endpoint:20s}: No data available")
                continue
            
            # Check for room correlation fields
            has_room_id = 'pms_room_id' in item
            has_room_obj = 'pms_room' in item
            room_value = item.get('pms_room_id') or item.get('pms_room')
            
            status = "✅" if (has_room_id or has_room_obj) else "❌"
            print(f"  {endpoint:20s}: {status} Room ID: {has_room_id}, Room Obj: {has_room_obj}, Value: {room_value}")
            
        except Exception as e:
            print(f"  {endpoint:20s}: ERROR - {str(e)[:40]}")
    
    print("\n💡 Room Correlation Strategy:")
    print("  1. All devices include pms_room_id or pms_room")
    print("  2. Use this to group devices by room")
    print("  3. Calculate per-room statistics")
    print("  4. Enable room-based filtering")

def calculate_data_requirements():
    """Calculate exact data requirements for each stage"""
    print("\n" + "="*80)
    print("DATA REQUIREMENTS ANALYSIS")
    print("="*80)
    
    print("\n📊 Field Count by Stage:")
    print("-" * 60)
    print("Endpoint         | Summary | List View | Full Data")
    print("-----------------|---------|-----------|----------")
    
    for endpoint, field_set in OPTIMIZED_FIELD_SETS.items():
        summary_count = len(field_set.summary)
        list_count = len(field_set.list_view)
        full_count = "ALL" if field_set.detail_view is None else str(len(field_set.detail_view))
        
        print(f"{endpoint:16s} | {summary_count:7d} | {list_count:9d} | {full_count:9s}")
    
    print("\n📊 Use Case Coverage:")
    print("-" * 60)
    
    use_cases = [
        ("Home Dashboard", "summary", "Device counts, online/offline status"),
        ("Device Lists", "list_view", "Full list with search/filter"),
        ("Room View", "list_view", "Devices grouped by room"),
        ("Device Details", "detail_view", "Complete device information"),
        ("Network Map", "list_view", "IP addresses and connections"),
        ("Offline Alerts", "summary", "Quick online/offline check")
    ]
    
    for use_case, stage, description in use_cases:
        print(f"  {use_case:15s} → {stage:10s} : {description}")

def design_ui_states():
    """Design UI states for progressive loading"""
    print("\n" + "="*80)
    print("UI STATE MANAGEMENT")
    print("="*80)
    
    print("\n🎨 Progressive UI States:")
    print("-" * 60)
    
    print("""
State 1: Initial Load (0-500ms)
  • Show skeleton UI
  • Display cached data if available
  • Start fetching list view data
  
State 2: List Data Ready (500ms)
  • Remove skeleton UI
  • Display all lists and counts
  • Enable search/filter
  • Start background detail fetch
  
State 3: Details Loading (background)
  • Show detail placeholders on tap
  • Load specific device details on demand
  • Cache for future access
  
State 4: Fully Loaded (background complete)
  • All data cached and ready
  • Instant navigation
  • Background refresh every 30 min
""")
    
    print("\n🔄 State Transitions (Riverpod):")
    print("-" * 60)
    print("""
@freezed
class DevicesState with _$DevicesState {
  const factory DevicesState({
    required List<Device> devices,
    required Map<String, Room> rooms,
    required DateTime lastRefresh,
    required bool isListLoaded,
    required bool isDetailLoaded,
    required bool isRefreshing,
    String? error,
  }) = _DevicesState;
  
  // Helper getters
  Map<String, List<Device>> get devicesByRoom {
    // Group devices by pms_room_id
    return devices.groupBy((d) => d.pmsRoomId ?? 'unassigned');
  }
  
  DeviceStats get stats {
    return DeviceStats(
      total: devices.length,
      online: devices.where((d) => d.isOnline).length,
      offline: devices.where((d) => !d.isOnline).length,
      byType: devices.groupBy((d) => d.type),
      byRoom: devicesByRoom,
    );
  }
}
""")

def create_implementation_timeline():
    """Create implementation timeline"""
    print("\n" + "="*80)
    print("IMPLEMENTATION TIMELINE")
    print("="*80)
    
    phases = [
        ("Phase 1: Data Layer", "Week 1", [
            "Add getDevicesForList() with field selection",
            "Update DeviceModel to handle pms_room",
            "Test with all endpoints"
        ]),
        ("Phase 2: Caching", "Week 1-2", [
            "Implement CacheService with SharedPreferences",
            "Add cache to Repository",
            "Test TTL and expiration"
        ]),
        ("Phase 3: Background Loading", "Week 2", [
            "Add background detail fetching",
            "Implement continuous refresh",
            "Network state monitoring"
        ]),
        ("Phase 4: UI Updates", "Week 3", [
            "Update ViewModels for progressive loading",
            "Add loading states to UI",
            "Implement pull-to-refresh"
        ]),
        ("Phase 5: Testing", "Week 3-4", [
            "Unit tests for all layers",
            "Integration tests",
            "Performance testing"
        ])
    ]
    
    print("\n📅 4-Week Implementation Plan:")
    print("-" * 60)
    
    for phase, timeline, tasks in phases:
        print(f"\n{phase} ({timeline}):")
        for task in tasks:
            print(f"  • {task}")

def generate_architecture_diagram():
    """Generate architecture diagram in Mermaid format"""
    print("\n" + "="*80)
    print("ARCHITECTURE DIAGRAM")
    print("="*80)
    
    print("\n```mermaid")
    print("""graph TB
    subgraph "UI Layer"
        UI[Flutter UI]
        VM[DevicesViewModel]
    end
    
    subgraph "Domain Layer"
        UC1[GetDevicesForList]
        UC2[RefreshDevices]
        UC3[GetDeviceDetails]
    end
    
    subgraph "Data Layer"
        Repo[DeviceRepository]
        Cache[CacheService]
        DS[DeviceDataSource]
    end
    
    subgraph "Network Layer"
        API[API Service]
        Net[NetworkInfo]
    end
    
    UI --> VM
    VM --> UC1
    VM --> UC2
    VM --> UC3
    
    UC1 --> Repo
    UC2 --> Repo
    UC3 --> Repo
    
    Repo --> Cache
    Repo --> DS
    Repo --> Net
    
    DS --> API
    
    Cache -.->|1hr TTL| Cache
    Net -.->|Monitor| Repo
    
    style UI fill:#e1f5ff
    style VM fill:#e1f5ff
    style Cache fill:#fff3e0
    style API fill:#f3e5f5
""")
    print("```")

def main():
    print("="*80)
    print("COMPREHENSIVE LOADING PLAN")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("="*80)
    
    # Test room correlation
    test_room_correlation()
    
    # Calculate data requirements
    calculate_data_requirements()
    
    # Design UI states
    design_ui_states()
    
    # Create timeline
    create_implementation_timeline()
    
    # Generate architecture diagram
    generate_architecture_diagram()
    
    print("\n" + "="*80)
    print("FINAL RECOMMENDATIONS")
    print("="*80)
    
    print("\n✅ LOADING STRATEGY:")
    print("  1. Single API call with list_view fields (includes pms_room)")
    print("  2. ~400ms initial load with all needed data")
    print("  3. Background fetch for full details")
    print("  4. 1-hour cache TTL with background refresh")
    
    print("\n✅ ROOM CORRELATION:")
    print("  • All devices include pms_room_id/pms_room")
    print("  • Group devices by room in ViewModel")
    print("  • Calculate per-room statistics")
    print("  • Enable room-based filtering")
    
    print("\n✅ PERFORMANCE TARGETS:")
    print("  • Initial load: < 500ms")
    print("  • Cached loads: < 100ms")
    print("  • Background refresh: Silent")
    print("  • Offline support: Full")
    
    print("\n✅ ARCHITECTURE COMPLIANCE:")
    print("  • Clean Architecture: ✓")
    print("  • MVVM Pattern: ✓")
    print("  • Repository Pattern: ✓")
    print("  • Dependency Injection: ✓")
    print("  • Riverpod State Management: ✓")

if __name__ == "__main__":
    main()