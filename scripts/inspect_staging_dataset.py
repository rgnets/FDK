#!/usr/bin/env python3
"""
Inspect staging API dataset before launching the application.
This helps understand the current state of data in the staging environment.
"""

import json
import requests
import sys
from datetime import datetime
from typing import Dict, List, Any
from collections import defaultdict

# Staging API configuration
API_BASE_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

# Headers for API requests
HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Accept": "application/json",
}

def print_separator(char="=", length=60):
    """Print a separator line."""
    print(char * length)

def fetch_endpoint(endpoint: str) -> Any:
    """Fetch data from an API endpoint with page_size=0."""
    try:
        url = f"{API_BASE_URL}{endpoint}"
        # Add page_size=0 to get all results without pagination
        separator = "&" if "?" in url else "?"
        url = f"{url}{separator}page_size=0"
        
        response = requests.get(url, headers=HEADERS, timeout=30, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"  ❌ Error fetching {endpoint}: {e}")
        return None

def analyze_rooms_data(data: List[Dict]) -> Dict[str, Any]:
    """Analyze rooms data and return statistics."""
    stats = {
        "total_rooms": len(data),
        "rooms_with_devices": 0,
        "total_access_points": 0,
        "total_media_converters": 0,
        "rooms_by_floor": defaultdict(int),
        "rooms_by_building": defaultdict(int),
        "sample_rooms": []
    }
    
    for room in data:
        # Count devices
        ap_count = len(room.get("access_points", []))
        mc_count = len(room.get("media_converters", []))
        
        if ap_count > 0 or mc_count > 0:
            stats["rooms_with_devices"] += 1
            stats["total_access_points"] += ap_count
            stats["total_media_converters"] += mc_count
        
        # Group by floor and building
        floor = room.get("floor", "Unknown")
        building = room.get("building", "Unknown")
        stats["rooms_by_floor"][floor or "None"] += 1
        stats["rooms_by_building"][building or "None"] += 1
        
        # Collect sample rooms with devices
        if len(stats["sample_rooms"]) < 5 and (ap_count > 0 or mc_count > 0):
            stats["sample_rooms"].append({
                "id": room.get("id"),
                "name": room.get("room", room.get("name", f"Room {room.get('id')}")),
                "access_points": ap_count,
                "media_converters": mc_count,
                "total_devices": ap_count + mc_count
            })
    
    return stats

def analyze_devices_data(ap_data: List[Dict], mc_data: List[Dict]) -> Dict[str, Any]:
    """Analyze device data and return statistics."""
    stats = {
        "total_access_points": len(ap_data) if ap_data else 0,
        "total_media_converters": len(mc_data) if mc_data else 0,
        "ap_by_status": defaultdict(int),
        "mc_by_status": defaultdict(int),
        "sample_devices": []
    }
    
    # Analyze access points
    if ap_data:
        for ap in ap_data[:5]:  # Sample first 5
            stats["sample_devices"].append({
                "type": "Access Point",
                "id": ap.get("id"),
                "name": ap.get("name", f"AP-{ap.get('id')}"),
                "status": ap.get("status", "unknown")
            })
        
        for ap in ap_data:
            status = ap.get("status", "unknown")
            stats["ap_by_status"][status] += 1
    
    # Analyze media converters
    if mc_data:
        for mc in mc_data[:5]:  # Sample first 5
            stats["sample_devices"].append({
                "type": "Media Converter",
                "id": mc.get("id"),
                "name": mc.get("name", f"MC-{mc.get('id')}"),
                "status": mc.get("status", "unknown")
            })
        
        for mc in mc_data:
            status = mc.get("status", "unknown")
            stats["mc_by_status"][status] += 1
    
    return stats

def main():
    """Main inspection routine."""
    print_separator()
    print("STAGING API DATASET INSPECTION")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print(f"API URL: {API_BASE_URL}")
    print_separator()
    
    # Fetch rooms data
    print("\n📋 FETCHING ROOMS DATA...")
    rooms_data = fetch_endpoint("/api/pms_rooms.json")
    
    if rooms_data:
        # Handle both List and Map response formats
        if isinstance(rooms_data, list):
            rooms_list = rooms_data
        elif isinstance(rooms_data, dict) and "results" in rooms_data:
            rooms_list = rooms_data["results"]
        else:
            print("  ❌ Unexpected rooms data format")
            rooms_list = []
        
        rooms_stats = analyze_rooms_data(rooms_list)
        
        print(f"\n✅ ROOMS SUMMARY:")
        print(f"  • Total rooms: {rooms_stats['total_rooms']}")
        print(f"  • Rooms with devices: {rooms_stats['rooms_with_devices']}")
        print(f"  • Total access points in rooms: {rooms_stats['total_access_points']}")
        print(f"  • Total media converters in rooms: {rooms_stats['total_media_converters']}")
        
        if rooms_stats['sample_rooms']:
            print(f"\n  Sample rooms with devices:")
            for room in rooms_stats['sample_rooms']:
                print(f"    - Room {room['name']} (ID: {room['id']}): "
                      f"{room['access_points']} APs, {room['media_converters']} MCs")
    
    # Fetch access points data
    print("\n📡 FETCHING ACCESS POINTS DATA...")
    ap_data = fetch_endpoint("/api/access_points.json")
    
    # Fetch media converters data
    print("\n🔌 FETCHING MEDIA CONVERTERS DATA...")
    mc_data = fetch_endpoint("/api/media_converters.json")
    
    if ap_data or mc_data:
        # Handle response formats
        ap_list = ap_data if isinstance(ap_data, list) else ap_data.get("results", []) if ap_data else []
        mc_list = mc_data if isinstance(mc_data, list) else mc_data.get("results", []) if mc_data else []
        
        device_stats = analyze_devices_data(ap_list, mc_list)
        
        print(f"\n✅ DEVICES SUMMARY:")
        print(f"  • Total access points: {device_stats['total_access_points']}")
        print(f"  • Total media converters: {device_stats['total_media_converters']}")
        print(f"  • Total devices: {device_stats['total_access_points'] + device_stats['total_media_converters']}")
        
        if device_stats['ap_by_status']:
            print(f"\n  Access Points by status:")
            for status, count in device_stats['ap_by_status'].items():
                print(f"    - {status}: {count}")
        
        if device_stats['mc_by_status']:
            print(f"\n  Media Converters by status:")
            for status, count in device_stats['mc_by_status'].items():
                print(f"    - {status}: {count}")
    
    # Data consistency check
    print("\n🔍 DATA CONSISTENCY CHECK:")
    if rooms_data and (ap_data or mc_data):
        rooms_list = rooms_data if isinstance(rooms_data, list) else rooms_data.get("results", [])
        rooms_stats = analyze_rooms_data(rooms_list)
        
        ap_list = ap_data if isinstance(ap_data, list) else ap_data.get("results", []) if ap_data else []
        mc_list = mc_data if isinstance(mc_data, list) else mc_data.get("results", []) if mc_data else []
        
        print(f"  • Devices in rooms: {rooms_stats['total_access_points'] + rooms_stats['total_media_converters']}")
        print(f"  • Devices from endpoints: {len(ap_list) + len(mc_list)}")
        
        # Check for discrepancies
        room_device_total = rooms_stats['total_access_points'] + rooms_stats['total_media_converters']
        endpoint_device_total = len(ap_list) + len(mc_list)
        
        if room_device_total != endpoint_device_total:
            print(f"  ⚠️  Discrepancy detected: {abs(room_device_total - endpoint_device_total)} devices difference")
        else:
            print(f"  ✅ Data is consistent across endpoints")
    
    # Final summary
    print_separator()
    print("INSPECTION COMPLETE")
    print_separator()
    
    if rooms_data:
        rooms_list = rooms_data if isinstance(rooms_data, list) else rooms_data.get("results", [])
        print(f"\n🎯 EXPECTED APP BEHAVIOR:")
        print(f"  The app should display:")
        print(f"  • {len(rooms_list)} rooms in the rooms list")
        print(f"  • Devices shown for {rooms_stats['rooms_with_devices']} rooms")
        print(f"  • Total of {rooms_stats['total_access_points'] + rooms_stats['total_media_converters']} devices across all rooms")
    else:
        print("\n⚠️ WARNING: Could not fetch rooms data")
        print("  The app may not display any data")
        sys.exit(1)
    
    print("\n✅ Dataset inspection successful. Proceeding with app launch...")
    print()

if __name__ == "__main__":
    # Suppress SSL warnings for staging environment
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️ Inspection interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Inspection failed: {e}")
        sys.exit(1)