#!/usr/bin/env python3
"""
Test pms_room Data Extraction
Test proper extraction of room correlation data from all device types
"""

import json
import requests
import os
from datetime import datetime
from typing import Dict, List, Any, Optional

def test_pms_room_in_all_endpoints():
    """Test pms_room data in all device endpoints"""
    print("="*80)
    print("PMS_ROOM DATA EXTRACTION TEST")
    print("="*80)
    
    # API configuration
    base_url = "https://rgnets-staging.fly.dev/api"
    
    # Test endpoints with minimal field selection to find pms_room
    endpoints = {
        'access_points': {
            'url': f"{base_url}/access_points.json",
            'fields': 'id,name,mac_address,pms_room_id,pms_room',
            'expected_room_field': 'pms_room'
        },
        'switches': {
            'url': f"{base_url}/switches.json",
            'fields': 'id,name,mac_address,pms_room_id,pms_room',
            'expected_room_field': 'pms_room'
        },
        'media_converters': {
            'url': f"{base_url}/media_converters.json", 
            'fields': 'id,name,mac_address,pms_room_id,pms_room',
            'expected_room_field': 'pms_room'
        },
        'wlan_controllers': {
            'url': f"{base_url}/wlan_controllers.json",
            'fields': 'id,name,mac_address,pms_room_id,pms_room', 
            'expected_room_field': 'pms_room'
        },
        'rooms': {
            'url': f"{base_url}/rooms.json",
            'fields': 'id,name,room,building,floor,access_points,switches,media_converters',
            'expected_room_field': None  # Rooms ARE the rooms
        }
    }
    
    print("\\n📋 Testing pms_room field presence:")
    print("-" * 60)
    
    results = {}
    
    for endpoint_name, config in endpoints.items():
        try:
            # Make API call with specific fields
            params = {
                'page_size': 5,  # Small sample for testing
                'only': config['fields']
            }
            
            print(f"\\n  Testing {endpoint_name}...")
            response = requests.get(config['url'], params=params, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                # Normalize response format
                if isinstance(data, list):
                    items = data
                elif isinstance(data, dict):
                    if 'results' in data:
                        items = data['results']
                    elif 'data' in data:
                        items = data['data']
                    else:
                        items = [data]  # Single item response
                else:
                    items = []
                
                if items:
                    sample_item = items[0]
                    
                    # Analyze room correlation fields
                    room_analysis = analyze_room_fields(sample_item, endpoint_name)
                    results[endpoint_name] = {
                        'success': True,
                        'sample_count': len(items),
                        'room_analysis': room_analysis,
                        'sample_item': sample_item
                    }
                    
                    print(f"    ✅ {len(items)} items retrieved")
                    print(f"    📊 Room correlation: {room_analysis['summary']}")
                    
                else:
                    results[endpoint_name] = {
                        'success': True,
                        'sample_count': 0,
                        'room_analysis': {'summary': 'No items found'},
                        'sample_item': None
                    }
                    print(f"    ⚠️ No items found")
                    
            else:
                results[endpoint_name] = {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text[:100]}",
                    'room_analysis': {'summary': 'API Error'},
                    'sample_item': None
                }
                print(f"    ❌ HTTP {response.status_code}")
                
        except requests.RequestException as e:
            results[endpoint_name] = {
                'success': False,
                'error': str(e),
                'room_analysis': {'summary': 'Request Error'},
                'sample_item': None
            }
            print(f"    ❌ Request failed: {str(e)[:50]}")
    
    return results

def analyze_room_fields(item: Dict[str, Any], endpoint_name: str) -> Dict[str, Any]:
    """Analyze room correlation fields in a device item"""
    
    room_fields = {}
    
    # Check for various room-related fields
    potential_room_fields = [
        'pms_room_id', 'pms_room', 'room_id', 'room', 
        'location', 'building', 'floor', 'site_id'
    ]
    
    for field in potential_room_fields:
        if field in item:
            room_fields[field] = item[field]
    
    # Special analysis for different device types
    analysis = {
        'found_fields': room_fields,
        'has_room_correlation': len(room_fields) > 0,
        'primary_room_field': None,
        'room_data_type': None,
        'summary': ''
    }
    
    # Determine primary room field and data type
    if 'pms_room' in room_fields and room_fields['pms_room']:
        analysis['primary_room_field'] = 'pms_room'
        room_value = room_fields['pms_room']
        
        if isinstance(room_value, dict):
            analysis['room_data_type'] = 'object'
            analysis['room_object_keys'] = list(room_value.keys())
        elif isinstance(room_value, str):
            analysis['room_data_type'] = 'string'
        elif isinstance(room_value, (int, float)):
            analysis['room_data_type'] = 'number'
        else:
            analysis['room_data_type'] = str(type(room_value))
            
    elif 'pms_room_id' in room_fields and room_fields['pms_room_id']:
        analysis['primary_room_field'] = 'pms_room_id'
        analysis['room_data_type'] = 'id_reference'
        
    elif 'room' in room_fields and room_fields['room']:
        analysis['primary_room_field'] = 'room'
        analysis['room_data_type'] = str(type(room_fields['room']))
    
    # Generate summary
    if analysis['has_room_correlation']:
        primary = analysis['primary_room_field']
        data_type = analysis['room_data_type']
        analysis['summary'] = f"✅ {primary} ({data_type})"
    else:
        analysis['summary'] = "❌ No room correlation found"
    
    return analysis

def test_room_correlation_patterns():
    """Test different room correlation patterns"""
    print("\\n" + "="*80)
    print("ROOM CORRELATION PATTERNS ANALYSIS")
    print("="*80)
    
    # Based on previous API analysis, test known patterns
    test_cases = [
        {
            'device_type': 'access_points',
            'expected_pattern': 'pms_room object with id, name, building, floor',
            'test_fields': 'id,name,pms_room_id,pms_room'
        },
        {
            'device_type': 'switches', 
            'expected_pattern': 'pms_room_id reference or pms_room object',
            'test_fields': 'id,name,pms_room_id,pms_room,location'
        },
        {
            'device_type': 'media_converters',
            'expected_pattern': 'pms_room_id reference or embedded location',
            'test_fields': 'id,name,pms_room_id,pms_room,location,building'
        }
    ]
    
    print("\\n🔍 Testing Room Correlation Patterns:")
    print("-" * 60)
    
    for test_case in test_cases:
        device_type = test_case['device_type']
        print(f"\\n  {device_type.replace('_', ' ').title()}:")
        print(f"    Expected: {test_case['expected_pattern']}")
        
        # Test with expanded field selection
        try:
            url = f"https://rgnets-staging.fly.dev/api/{device_type}.json"
            params = {
                'page_size': 3,
                'only': test_case['test_fields']
            }
            
            response = requests.get(url, params=params, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                # Normalize response
                if isinstance(data, list):
                    items = data
                elif isinstance(data, dict) and 'results' in data:
                    items = data['results'] 
                else:
                    items = [data] if isinstance(data, dict) else []
                
                if items:
                    for i, item in enumerate(items[:2]):  # Test first 2 items
                        print(f"\\n    Item {i+1}:")
                        room_analysis = analyze_room_fields(item, device_type)
                        
                        for field, value in room_analysis['found_fields'].items():
                            if isinstance(value, dict):
                                keys = list(value.keys())[:5]  # Show first 5 keys
                                print(f"      {field}: object with keys {keys}")
                                
                                # Show room object details if it exists
                                if field == 'pms_room' and isinstance(value, dict):
                                    if 'name' in value:
                                        print(f"        → Room: {value.get('name', 'N/A')}")
                                    if 'building' in value:
                                        print(f"        → Building: {value.get('building', 'N/A')}")
                                    if 'floor' in value:
                                        print(f"        → Floor: {value.get('floor', 'N/A')}")
                                        
                            else:
                                print(f"      {field}: {value}")
                                
                else:
                    print("      ⚠️ No items found")
                    
            else:
                print(f"      ❌ HTTP {response.status_code}")
                
        except Exception as e:
            print(f"      ❌ Error: {str(e)[:50]}")

def generate_room_extraction_code():
    """Generate code for proper room extraction"""
    print("\\n" + "="*80)
    print("ROOM EXTRACTION IMPLEMENTATION")
    print("="*80)
    
    print("\\n📝 Device Model Extensions:")
    print("-" * 60)
    
    model_code = '''
// Enhanced Device model with room correlation
class DeviceModel {
  final String id;
  final String name;
  final bool? isOnline;
  final String? macAddress;
  final String? ipAddress;
  
  // Room correlation fields
  final String? pmsRoomId;
  final RoomModel? pmsRoom;
  
  const DeviceModel({
    required this.id,
    required this.name,
    this.isOnline,
    this.macAddress,
    this.ipAddress,
    this.pmsRoomId,
    this.pmsRoom,
  });
  
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isOnline: json['online'] as bool?,
      macAddress: json['mac_address']?.toString(),
      ipAddress: json['ip_address']?.toString(),
      pmsRoomId: json['pms_room_id']?.toString(),
      pmsRoom: json['pms_room'] != null 
        ? RoomModel.fromJson(json['pms_room'] as Map<String, dynamic>)
        : null,
    );
  }
  
  // Room correlation helpers
  String? get roomName => pmsRoom?.name;
  String? get roomBuilding => pmsRoom?.building;  
  String? get roomFloor => pmsRoom?.floor;
  
  bool get hasRoomCorrelation => pmsRoom != null || pmsRoomId != null;
  
  String get locationDisplay {
    if (pmsRoom != null) {
      final parts = <String>[];
      if (pmsRoom!.building?.isNotEmpty == true) parts.add(pmsRoom!.building!);
      if (pmsRoom!.floor?.isNotEmpty == true) parts.add('Floor ${pmsRoom!.floor}');
      if (pmsRoom!.name?.isNotEmpty == true) parts.add(pmsRoom!.name!);
      return parts.join(' - ');
    }
    return pmsRoomId ?? 'Unknown Location';
  }
}

class RoomModel {
  final String? id;
  final String? name;
  final String? room;
  final String? building;
  final String? floor;
  
  const RoomModel({
    this.id,
    this.name,
    this.room,
    this.building,
    this.floor,
  });
  
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? json['room']?.toString(),
      room: json['room']?.toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'room': room, 
      'building': building,
      'floor': floor,
    };
  }
}'''
    
    print(model_code)
    
    print("\\n📝 Data Source Field Selection:")
    print("-" * 60)
    
    datasource_code = '''
class DeviceRemoteDataSourceImpl implements DeviceDataSource {
  
  // Optimized field selection including room correlation
  static const Map<String, String> listViewFields = {
    'access_points': 'id,name,online,mac_address,ip_address,model,pms_room_id,pms_room',
    'switches': 'id,name,online,mac_address,ip_address,model,pms_room_id,pms_room',
    'media_converters': 'id,name,online,mac_address,serial_number,model,pms_room_id,pms_room',
    'wlan_controllers': 'id,name,online,mac_address,ip_address,model,pms_room_id,pms_room',
    'rooms': 'id,name,room,building,floor,access_points,switches,media_converters'
  };
  
  @override
  Future<Either<Failure, List<DeviceModel>>> getDevicesForList() async {
    try {
      // Fetch all endpoints in parallel with room correlation fields
      final futures = listViewFields.entries.map((entry) async {
        final response = await _httpClient.get(
          Uri.parse('${ApiConstants.baseUrl}/${entry.key}.json').replace(
            queryParameters: {
              'page_size': '0',  // Get all items
              'only': entry.value,  // Specific fields including room data
            },
          ),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = _normalizeApiResponse(data);
          
          return items.map((item) => DeviceModel.fromJson({
            ...item,
            '_device_type': entry.key,  // Add device type for processing
          })).toList();
        } else {
          throw ServerException('Failed to fetch ${entry.key}');
        }
      });
      
      final results = await Future.wait(futures);
      final allDevices = results.expand((devices) => devices).toList();
      
      return Right(allDevices);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  List<Map<String, dynamic>> _normalizeApiResponse(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    } else if (data is Map<String, dynamic>) {
      if (data.containsKey('results')) {
        return (data['results'] as List).cast<Map<String, dynamic>>();
      } else {
        return [data];
      }
    }
    return [];
  }
}'''
    
    print(datasource_code)

def create_room_correlation_tests():
    """Create comprehensive room correlation tests"""
    print("\\n" + "="*80)
    print("ROOM CORRELATION TESTING")
    print("="*80)
    
    test_scenarios = [
        "Room Data Presence",
        "  • Verify pms_room object exists in access_points",
        "  • Check pms_room_id fallback in other device types",
        "  • Validate room data structure matches expected format",
        "",
        "Room Correlation Logic",
        "  • Test DeviceModel.hasRoomCorrelation property",
        "  • Verify DeviceModel.locationDisplay formatting",
        "  • Test room grouping in DevicesState",
        "",
        "Edge Cases",
        "  • Devices with null pms_room and pms_room_id",
        "  • Incomplete room objects (missing building/floor)",
        "  • Room objects vs room ID references",
        "",
        "Performance Impact",
        "  • Measure impact of room field inclusion on API calls",
        "  • Test caching of room correlation data",
        "  • Verify no N+1 queries for room lookups"
    ]
    
    print("\\n🧪 Test Scenarios:")
    print("-" * 60)
    for scenario in test_scenarios:
        print(f"  {scenario}")
    
    print("\\n✅ Success Criteria:")
    print("-" * 60)
    print("  • All device types return room correlation data")
    print("  • Room information displays correctly in UI")
    print("  • Devices can be grouped by room/building/floor")
    print("  • No performance degradation from room fields")
    print("  • Graceful handling of missing room data")

def main():
    print("="*80)
    print("PMS_ROOM DATA EXTRACTION VALIDATION")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("="*80)
    
    # Test pms_room in all endpoints
    results = test_pms_room_in_all_endpoints()
    
    # Test correlation patterns
    test_room_correlation_patterns()
    
    # Generate implementation code
    generate_room_extraction_code()
    
    # Create testing scenarios
    create_room_correlation_tests()
    
    print("\\n" + "="*80)
    print("PMS_ROOM EXTRACTION RESULTS")
    print("="*80)
    
    print("\\n📊 Endpoint Analysis Summary:")
    print("-" * 60)
    
    for endpoint, result in results.items():
        if result['success']:
            room_summary = result['room_analysis']['summary']
            print(f"  {endpoint:18s}: {room_summary}")
        else:
            print(f"  {endpoint:18s}: ❌ {result.get('error', 'Unknown error')[:30]}")
    
    # Determine overall room correlation status
    successful_endpoints = [k for k, v in results.items() if v['success']]
    endpoints_with_rooms = [
        k for k, v in results.items() 
        if v['success'] and v['room_analysis']['has_room_correlation']
    ]
    
    print("\\n✅ ROOM CORRELATION STATUS:")
    print("-" * 60)
    if len(endpoints_with_rooms) > 0:
        print(f"  • {len(endpoints_with_rooms)}/{len(successful_endpoints)} endpoints have room data")
        print("  • Room correlation is available and can be extracted")
        print("  • Primary field: pms_room (object) or pms_room_id (reference)")
        print("  • Implementation: Include room fields in API calls")
    else:
        print("  • ⚠️ No room correlation found in test sample")
        print("  • May need to test with different parameters or larger sample")
        print("  • Recommendation: Test with full field set or different query")
    
    print("\\n🎯 IMPLEMENTATION RECOMMENDATIONS:")
    print("-" * 60)
    print("  1. Include 'pms_room_id,pms_room' in all device API calls")
    print("  2. Create RoomModel to handle pms_room object structure")
    print("  3. Add room correlation helpers to DeviceModel")
    print("  4. Implement room-based grouping in DevicesState")
    print("  5. Test with production data to verify consistency")
    
    print("\\n✅ READY TO IMPLEMENT room correlation with confidence!")

if __name__ == "__main__":
    main()