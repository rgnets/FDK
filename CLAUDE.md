# Claude Code Instructions for RG Nets Field Deployment Kit

## Critical API Information

### Documentation References
- **Complete API field list**: `docs/api_fields_reference.md` - All available fields per endpoint
- **IP/MAC field mapping**: `docs/FIX_IP_MAC_FIELD_NAMES.md` - Critical field name differences per device type
- **Performance optimization**: `docs/performance_optimization_plan.md` - Detailed performance analysis
- **Field selection implementation**: `docs/FIELD_SELECTION_IMPLEMENTATION_EXACT_PLAN.md` - Implementation details

### Authentication
- **STAGING/PRODUCTION**: Use Bearer token authentication
  - Header: `Authorization: Bearer <API_KEY>`
  - Staging API Key: `xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r`
  - Username (if needed): `fetoolreadonly`

### Pagination
- **ALWAYS use `page_size=0`** to fetch all records without pagination
- This returns complete lists in a single request

### Field Selection (CRITICAL for Performance)
- **The API supports field selection using the `only` parameter**
- Format: `?only=field1,field2,field3`
- **Performance gains**: 97-99% size reduction across all device types

### API Field Reference
- **For complete API field documentation**: See `docs/api_fields_reference.md`
- **For IP/MAC field mapping**: See `docs/FIX_IP_MAC_FIELD_NAMES.md`

**Critical**: Different device types use different field names for IP and MAC addresses. Always check the documentation before adding new field requests.

### Example API Calls

#### List View (Minimal Fields)
```
GET /api/access_points?page_size=0&only=id,name,type,status,ip_address,mac_address,pms_room,location,last_seen,signal_strength,connected_clients
```

#### Detail View (All Fields)
```
GET /api/access_points/<id>
```

### Hierarchical Loading Strategy
1. **List Views**: Use minimal fields with `only` parameter
2. **Detail Views**: Fetch complete data for single device
3. **Cache**: Store minimal data with longer TTL, detail data with shorter TTL

## Architecture Patterns (STRICT REQUIREMENTS)

### MVVM Pattern
- ViewModels MUST be Riverpod Notifiers
- State MUST use AsyncValue
- NO business logic in UI widgets

### Clean Architecture
- **Domain Layer**: Pure entities, no dependencies
- **Data Layer**: Models, repositories, data sources
- **Presentation Layer**: UI only, uses providers

### Dependency Injection
- ALL dependencies via Riverpod providers
- NO direct instantiation except in providers

### State Management
- Use Riverpod exclusively
- AsyncValue for async state
- ref.watch() in build, ref.read() for actions

### Routing
- go_router for declarative routing
- NO imperative navigation

## Common Mistakes to Avoid

1. **NOT using field selection** - Always use `only` parameter for list views
2. **Using Basic Auth instead of Bearer** - Always use Bearer token
3. **Not using page_size=0** - Always use for complete lists
4. **Creating AsyncValue.loading() in background refresh** - Causes UI flicker
5. **Not checking state.hasValue before background updates**

## Testing Checklist

Before implementing any change:
1. Test with isolated program
2. Verify architectural compliance
3. Check for zero errors and warnings
4. Test three times before implementation

## File Locations

- **API Service**: `lib/core/services/api_service.dart`
- **Remote Data Source**: `lib/features/devices/data/datasources/device_remote_data_source.dart`
- **Providers**: `lib/features/devices/presentation/providers/`
- **Entities**: `lib/features/devices/domain/entities/`
- **Models**: `lib/features/devices/data/models/`