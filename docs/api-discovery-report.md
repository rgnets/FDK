# RXG API Discovery Report - VERIFIED IMPLEMENTATION

**Generated**: 2025-08-18
**API Host**: vgw1-01.dal-interurban.mdu.attwifi.com
**Authentication**: API key-based (read-only access confirmed)
**Status**: ACTUAL TEST RESULTS from test_api.dart

## Executive Summary

Actual testing with test_api.dart confirms the real API structure. **Critical findings**:
1. All list endpoints use pagination (30 items/page)
2. Notifications API doesn't exist (404)
3. WLAN controllers endpoint doesn't exist (404)
4. Media converters endpoint = ONT devices
5. Room readiness is not implemented

## Verified Working Endpoints

### Authentication ✅
- `GET /api/whoami.json` - Status: **WORKING**
  ```json
  {
    "type": "admin",
    "id": 379,
    "login": "fetoolreadonly"
  }
  ```

### Device Management

#### 1. Access Points ✅
- `GET /api/access_points.json` - Status: **WORKING**
- **Count**: 221 items
- **Pagination**: Yes (30/page, 8 pages)
  ```json
  {
    "count": 1599,
    "page": 1,
    "page_size": 30,
    "total_pages": 54,
    "next": "https://[host]/api/devices.json?api_key=[key]&page=2",
    "results": [
      {
        "id": 1747,
        "name": "iPhone",
        "mac": "aa:29:9c:93:3a:d8",
        "note": null,
        "created_at": "2025-06-11T10:57:14.936-05:00",
        "updated_at": "2025-06-17T14:11:33.918-05:00",
        "created_by": "/space/rxg/rxgd/bin/freeradius_hook",
        "updated_by": "/space/rxg/rxgd/bin/freeradius_hook",
        "account": {
          "id": 120,
          "login": "user@example.com"
        },
        "radius_server": {
          "id": 1,
          "name": "Known-devices-Residential-wireless"
        }
      }
    ]
  }
  ```

#### 2. Media Converters (ONTs) ✅
- `GET /api/media_converters.json` - Status: **WORKING**
- **Count**: 151 items
- **Pagination**: Yes (30/page, 6 pages)
- **Note**: These are the ONT devices

#### 3. Switch Devices ✅
- `GET /api/switch_devices.json` - Status: **WORKING**
- **Count**: 1 item only
- **Pagination**: Yes (but only 1 page)
  ```json
  {
    "count": 221,
    "page": 1,
    "page_size": 30,
    "total_pages": 8,
    "results": [
      {
        "id": 379,
        "name": "AP1-8-0023-WF189-RM803",
        "mac": "d4:ba:ba:a3:9b:80",
        "serial_number": "1K9251400023",
        "model": "CIG WF189",
        "version": "TIP-rgnets-4.0.0-0.016-80b4adb0",
        "online": false,
        "ip": null,
        "connection_state": "socket (1033: Device is not currently connected.)",
        "channel_24": 1,
        "channel_5": 138,
        "channel_6": 79,
        "access_point_profile": {
          "id": 1,
          "name": "Default AP Profile SDK"
        },
        "pms_room": {
          "id": 128,
          "name": "(Interurban) 803"
        }
      }
    ]
  }
  ```

#### 4. PMS Rooms ✅
- `GET /api/pms_rooms.json` - Status: **WORKING**
- **Count**: 141 items  
- **Pagination**: Yes (30/page, 5 pages)
- **Note**: No device associations or readiness data

## Non-Existent Endpoints (404 Errors) ❌

1. **WLAN Controllers**
   - `GET /api/wlan_controllers.json` - **404 NOT FOUND**
   - Endpoint does not exist in API

2. **Notifications**
   - `GET /api/notifications.json` - **404 NOT FOUND**
   - No server-side notification system
   - Must generate notifications client-side

3. **Alerts/Status**
   - `GET /api/alerts.json` - **404 NOT FOUND**
   - `GET /api/device_status.json` - **404 NOT FOUND**

4. **Room Management**
   - `GET /api/rooms.json` - Use pms_rooms instead
  ```json
  {
    "count": 132,
    "page": 1,
    "page_size": 30,
    "total_pages": 5,
    "results": [
      {
        "id": 128,
        "name": "(Interurban) 803",
        // Additional PMS fields
      }
    ]
  }
  ```

## Critical Implementation Notes

### Pagination Structure (ALL endpoints)
```json
{
  "count": 221,           // Total items
  "page": 1,              // Current page (1-indexed)
  "page_size": 30,        // Items per page
  "total_pages": 8,       // Total pages
  "next": "https://[host]/api/endpoint.json?page=2",
  "results": [...]        // ⚠️ Data is in 'results', not root!
}
```

### Code Changes Required
```dart
// WRONG (current implementation):
final devices = response as List;

// CORRECT (must change to):
final data = response as Map<String, dynamic>;
final devices = data['results'] as List;
final hasMore = data['next'] != null;
```

## Implementation Impact

### 1. Notification System
- **Reality**: No server API, must generate client-side
- **Logic**: Based on device online/note/images status
- **Storage**: In-memory only, not persisted
- **Priority**: Urgent (offline), Medium (notes), Low (missing images)

### 2. Room Readiness Feature
- **Status**: NOT IMPLEMENTED
- **Issue**: No device-to-room associations in API
- **PMS Rooms**: Exist but lack device counts/status
- **Conclusion**: Would require backend changes

### 3. QR Scanner Implementation
- **Window**: 6-second accumulation period
- **AP Requirements**: 2 barcodes (serial + MAC)
- **ONT Requirements**: 2-3 barcodes
- **Switch Requirements**: 1 barcode (serial only)
- **UI**: Device type selection before scanning

### 4. Device Type Mapping
```
Internal         →  API Endpoint
'access_point'   →  /api/access_points.json     ✅
'ont'            →  /api/media_converters.json  ✅
'switch'         →  /api/switch_devices.json    ✅
'wlan_controller'→  /api/wlan_controllers.json  ❌ 404
```

## Summary of Actual Implementation

### What Works
1. **Authentication**: whoami.json endpoint
2. **Device Lists**: Paginated responses for APs (221), ONTs (151), Switches (1)
3. **PMS Rooms**: Basic room list (141 items, no readiness)
4. **Client-side Notifications**: Generated from device status

### What Doesn't Work
1. **Server Notifications**: API doesn't exist (404)
2. **WLAN Controllers**: Endpoint returns 404
3. **Room Readiness**: No implementation
4. **Device-Room Association**: No API support

### Critical Actions Needed
1. **Fix Pagination**: Update all repositories to handle `response['results']`
2. **Handle 404s**: Implement fallbacks for missing endpoints
3. **Client Notifications**: Add persistence layer
4. **Room Readiness**: Requires backend API changes

## Test Results Summary

### Endpoint Test Results
```
Access Points (/api/access_points.json):
  Status: 200 OK
  Response type: Object (PAGINATED)
  Count: 221, Pages: 8

Media Converters (/api/media_converters.json):
  Status: 200 OK
  Response type: Object (PAGINATED)
  Count: 151, Pages: 6

Switch Devices (/api/switch_devices.json):
  Status: 200 OK
  Response type: Object (PAGINATED)
  Count: 1, Pages: 1

WLAN Controllers (/api/wlan_controllers.json):
  Status: 404 NOT FOUND
  ENDPOINT DOES NOT EXIST

PMS Rooms (/api/pms_rooms.json):
  Status: 200 OK
  Response type: Object (PAGINATED)
  Count: 141, Pages: 5

Notifications (/api/notifications.json):
  Status: 404 NOT FOUND
  ENDPOINT DOES NOT EXIST
```

## Security Observations

1. **API Key in URL**: Visible in logs and history
2. **No rate limiting**: Could exhaust server
3. **Large response sizes**: Some devices have 155+ fields
4. **Read-only enforcement**: Works correctly (403 on POST)

## Recommendations

1. **Implement pagination support** in all list operations
2. **Cache aggressively** due to large response sizes
3. **Use PMS rooms** as the room entity
4. **Calculate room readiness** client-side
5. **Remove expectations** of ONT-specific endpoints
6. **Add field filtering** if API supports it to reduce payload

## Files Generated

All API responses saved to: `scripts/api_discovery/`
- `_api_response.json` - API root documentation (HTML)
- `_api_whoami_response.json` - Authentication
- `_api_devices_response.json` - Generic devices
- `_api_switch_devices_response.json` - Switches
- `_api_switch_devices_70_response.json` - Switch detail
- `_api_access_points_response.json` - Access points
- `_api_wlan_devices_response.json` - WLAN devices
- `_api_pms_rooms_response.json` - PMS rooms