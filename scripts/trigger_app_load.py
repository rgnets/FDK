#!/usr/bin/env python3
"""
Simple script to access the staging app and potentially trigger data loading.
"""

import requests
import time

def trigger_app_load():
    """Access the staging app to trigger data loading."""
    url = "http://localhost:8092"
    
    try:
        print(f"Accessing {url}...")
        response = requests.get(url, timeout=10)
        print(f"Response status: {response.status_code}")
        print(f"Response headers: {dict(response.headers)}")
        
        # Look for Flutter-specific content
        if "flutter" in response.text.lower():
            print("✅ Flutter app detected!")
        else:
            print("❌ No Flutter content found")
        
        # Try to access potential API endpoints
        api_endpoints = [
            "/api/devices",
            "/api/rooms", 
            "/api/pms_rooms.json",
            "/api/access_points.json",
            "/api/media_converters.json"
        ]
        
        for endpoint in api_endpoints:
            try:
                print(f"\nTrying to access {url}{endpoint}...")
                api_response = requests.get(f"{url}{endpoint}", timeout=5)
                print(f"  Status: {api_response.status_code}")
            except Exception as e:
                print(f"  Error: {e}")
        
    except requests.exceptions.RequestException as e:
        print(f"Error accessing app: {e}")

if __name__ == "__main__":
    print("=== STAGING APP TRIGGER ===")
    trigger_app_load()
    
    # Wait a bit and try again
    print("\nWaiting 3 seconds before retry...")
    time.sleep(3)
    trigger_app_load()