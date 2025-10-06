# API Contracts - RG Nets Field Deployment Kit

**Generated**: 2025-08-18
**Last Updated**: 2025-08-18 (Verified Implementation)
**Status**: ACTUAL IMPLEMENTATION
**API Base**: vgw1-01.dal-interurban.mdu.attwifi.com

## Authentication

### API Credentials Structure
**Trace**: lib/rxg_api/api_credentials.dart
```dart
class ApiCredentials {
  String fqdn;     // API host FQDN
  String login;    // Username (fetoolreadonly)
  String apiKey;   // API key for authentication
}
```

### Authentication Method
- **Type**: API Key in query parameter
- **Parameter**: `api_key`
- **Example**: `https://[fqdn]/api/endpoint.json?api_key=[key]`
- **SSL**: Self-signed certificates accepted (SECURITY RISK)

### Credential Validation Endpoint
**Endpoint**: GET /api/whoami.json
**Trace**: lib/services/credential_service.dart:31-44
**Verified**: 2025-08-17 via API exploration
```json
Response:
{
  "type": "admin",
  "id": 379,
  "login": "fetoolreadonly"
}
```

## ACTUAL API ENDPOINTS (Verified Implementation)

### Working Endpoints ✅
1. **GET /api/whoami.json** - Authentication check
2. **GET /api/access_points.json** - Access points (221 items, paginated)
3. **GET /api/media_converters.json** - ONT devices (151 items, paginated)
4. **GET /api/switch_devices.json** - Switch devices (1 item, paginated)
5. **GET /api/pms_rooms.json** - PMS rooms (141 items, paginated)

### Non-Existent Endpoints ❌ (Return 404)
1. **GET /api/wlan_controllers.json** - Does not exist
2. **GET /api/notifications.json** - No server-side notifications
3. **GET /api/rooms.json** - Use pms_rooms.json instead
4. **GET /api/devices.json** - Generic endpoint not used
5. **GET /api/alerts.json** - Does not exist
6. **GET /api/device_status.json** - Does not exist

## IMPORTANT: Pagination Structure

**ALL list endpoints return paginated responses**, not direct arrays:

```json
{
  "count": 221,           // Total items
  "page": 1,              // Current page (1-indexed)
  "page_size": 30,        // Items per page
  "total_pages": 8,       // Total pages  
  "next": "https://[host]/api/endpoint.json?page=2",
  "results": [...]        // Actual data array
}
```

**Critical**: Code must access data via `response['results']`, not directly as array.

## Device Management APIs (Actual Implementation)

### 1. Get Access Points
**Endpoint**: GET /api/access_points.json
**Status**: ✅ WORKING
**Count**: 221 total items
```json
Response: {
  "count": 221,
  "page": 1,
  "page_size": 30,
  "total_pages": 8,
  "next": "https://[host]/api/access_points.json?page=2",
  "results": [
  {
    "id": 379,
    "name": "AP1-8-0023-WF189-RM803",
    "device": "nokiapon",
    "host": "10.99.0.6",
    "username": "adminuser",
    "note": null,
    "created_at": "2025-03-18T13:54:36.778-05:00",
    "updated_at": "2025-08-09T09:45:06.180-05:00",
    "created_by": "jmb",
    "updated_by": "nokia_pon",
    "protocol": "ssh_coa",
    "scratch": "28:6f:b9:e7:c1:d9",
    "port": 22,
    "timeout": 30,
    "community_string": "public",
    "zone": null,
    "serial_number": "YP2444SH085",
    "model": "MF-2 (LS-MF-LMNT-B)",
    "version": "24.12",
    "snmp_port": 161,
    "api_port": null,
    "monitoring_enabled": true,
    "online": true,
    "cookie": null,
    "api_version": null,
    "loopback_ip": null,
    "system_name": null,
    "nickname": null,
    "last_config_sync_at": "2025-08-08T12:18:00.075-05:00",
    "last_config_sync_attempt_at": "2025-08-08T12:17:51.780-05:00",
    "license": "[base64 encoded license]",
    "subnet": null,
    "gateway_ip": null,
    "zone_filter": null,
    "domain_filter": null,
    "apikey": null,
    "x": null,
    "y": null,
    "type": "SwitchDevice",
    "create_location_events": true
  }]
}
```

### 2. Get Media Converters (ONTs)
**Endpoint**: GET /api/media_converters.json
**Status**: ✅ WORKING
**Count**: 151 total items
```json
Response: {
  "count": 151,
  "page": 1,
  "page_size": 30,
  "total_pages": 6,
  "next": "https://[host]/api/media_converters.json?page=2",
  "results": [
    // ONT device data
  ]
}
```

### 3. Get Switch Devices
**Endpoint**: GET /api/switch_devices.json
**Status**: ✅ WORKING
**Count**: 1 total item
```json
Response: {
  "count": 1,
  "page": 1,
  "page_size": 30,
  "total_pages": 1,
  "next": null,
  "results": [
    {
      "id": 70,
      "name": "MF2-01",
      "serial_number": "YP2444SH085",
      "online": true,
      // ... 150+ additional fields
    }
  ]
}
```

### 4. Get PMS Rooms
**Endpoint**: GET /api/pms_rooms.json
**Status**: ✅ WORKING
**Count**: 141 total items
```json
Response: {
  "count": 141,
  "page": 1,
  "page_size": 30,
  "total_pages": 5,
  "next": "https://[host]/api/pms_rooms.json?page=2",
  "results": [
    {
      "id": 128,
      "name": "(Interurban) 803"
      // PMS-specific fields
    }
  ]
}
```

### 5. Authentication Check
**Endpoint**: GET /api/whoami.json
**Status**: ✅ WORKING
```json
Response: {
  "type": "admin",
  "id": 379,
  "login": "fetoolreadonly"
}
```

## Non-Existent Endpoints (404 Errors)

### WLAN Controllers
**Endpoint**: GET /api/wlan_controllers.json
**Status**: ❌ DOES NOT EXIST
- Returns 404
- No WLAN controller data available

### Notifications
**Endpoint**: GET /api/notifications.json
**Status**: ❌ DOES NOT EXIST
- Returns 404
- Notifications are generated client-side only
- No server-side notification system

## Client-Side Features (No API Required)

### Notification System
**Implementation**: Client-side only
**Source**: Generated from device status during refresh
```javascript
// Notifications generated locally based on:
- Device offline status → Urgent (red)
- Device notes field → Medium (orange)  
- Missing device images → Low (green)
```

### Room Readiness
**Status**: PLANNED FEATURE (Not Implemented)
- Would calculate readiness from device online status
- Would require correlation between rooms and devices
- Currently no implementation in codebase

## Device Type Mapping

### Internal Types vs API Endpoints
```
Internal Type    →    API Endpoint
'access_point'   →    /api/access_points.json
'ont'            →    /api/media_converters.json
'switch'         →    /api/switch_devices.json
'wlan_controller'→    /api/wlan_controllers.json (404)
```

## Error Response Format

All API errors follow this format:
```json
{
  "error": true,
  "message": "Error description",
  "code": "ERROR_CODE",
  "details": {
    // Additional error context
  }
}
```

### Common Error Codes
- `AUTH_FAILED`: Authentication failure
- `NOT_FOUND`: Resource not found
- `VALIDATION_ERROR`: Input validation failed
- `PERMISSION_DENIED`: Insufficient permissions
- `NETWORK_ERROR`: Network connectivity issue
- `TIMEOUT`: Request timeout

## Request Headers

### Standard Headers
```http
Content-Type: application/json
Accept: application/json
User-Agent: RG-Nets-FDK/0.7.7
```

### Optional Headers
```http
X-Request-ID: uuid-v4
X-Device-ID: device-identifier
X-App-Version: 0.7.7
```

## Rate Limiting

- **Not documented in code**
- **Assumption**: Standard rate limiting applies
- **Retry Strategy**: Exponential backoff implemented client-side

## Caching Strategy

### Client-Side Caching
- **SimpleCache**: In-memory TTL-based cache
- **SafeCache**: Thread-safe cache with mutex
- **Default TTL**: 5 minutes (not configurable)

### Cache Keys
```dart
"devices_list"
"device_{id}"
"rooms_list"
"room_{id}"
"notifications"
```

## Offline Support

### Queued Operations
Operations queued when offline:
- Device creation
- Device updates
- Room assignments
- Note updates

### Sync on Reconnect
- Automatic sync when connection restored
- Conflict resolution: Server wins

## Implementation Requirements

### Pagination Handling
All repository implementations must handle pagination:
```dart
// Repository must extract results array
final response = await api.get('/api/access_points.json');
final items = response['results'] as List;  // NOT response as List
final hasMore = response['next'] != null;
final totalCount = response['count'] as int;
```

### Error Handling for Missing Endpoints
```dart
// Handle 404 for non-existent endpoints
try {
  final response = await api.get('/api/notifications.json');
} catch (e) {
  if (e.statusCode == 404) {
    // Generate notifications client-side instead
    return generateLocalNotifications();
  }
}
```

## Webhooks

**Not implemented** - No webhook support found

## API Versioning

**Not implemented** - No version in URL or headers

## Current Implementation Issues

### API Integration
1. **Pagination Not Handled**: Code assumes direct arrays
2. **Missing Endpoints**: notifications.json returns 404
3. **WLAN Controllers**: Endpoint doesn't exist
4. **Room Readiness**: Feature not implemented

### Security Issues
1. **Hardcoded Credentials**: API key in test_api.dart
2. **Self-signed Certs**: Accepts any certificate
3. **URL Parameters**: API key visible in logs

### Recommendations
1. Move to header-based authentication
2. Implement certificate pinning
3. Use OAuth 2.0 or JWT tokens
4. Implement request signing
5. Add API versioning

## Actual API Behavior

1. **Pagination**: 30 items per page default
2. **Total Counts**: Available in response
3. **Next Page URL**: Provided when more data exists
4. **Read-Only**: POST/PUT/DELETE return 403

## Testing

### Mock Responses Available
- switch_devices.json
- switch_devices_70_detail.json
- wlan_devices.json
- Additional fixtures in test/fixtures/api_responses/

### Test Environment
- Uses mock repositories
- No staging API documented
- Test mode bypasses real API