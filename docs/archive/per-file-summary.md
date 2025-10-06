# Per-File Documentation Summary - ATT FE Tool

**Generated**: 2025-08-17
**Pass**: 2
**Coverage**: All 89 lib/ files cataloged

## Documentation Structure

Full per-file documentation using the template has been created for:
- ✅ Scanner domain layer (10 files) - Complete documentation in docs/rebuild/per-file/

For efficiency, remaining files are summarized below with key information.

## Core Infrastructure Files (lib/core/)

### Async Management
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| async_operation_manager.dart | Manages cancelable async operations | CancelableOperation class | Memory leak risk if not disposed |

### Camera Management  
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| camera_lifecycle_manager.dart | Camera resource lifecycle | initialize(), dispose(), pause(), resume() | Complex state machine, resource intensive |

### Connection Management
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| connection_manager.dart | Network state monitoring | ConnectionStatus, checkConnection() | Singleton, connectivity_plus dependency |
| connection_state.dart | Connection state enum | ConnectionState enum | 5 states: checking, connected, disconnected, authenticated, unauthenticated |

### Dialog Management
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| dialog_manager.dart | Centralized dialog control | showDialog(), hideDialog() | Prevents dialog stacking |

### Error Handling
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| error_recovery.dart | Automatic error recovery | attemptRecovery(), ErrorSeverity enum | Zoned error handling integration |

### Initialization
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| app_initializer.dart | App startup sequence | initialize(), InitializationResult | 8-step init process, retry logic |
| initialization_step.dart | Single init step abstraction | InitializationStep class | Used by app_initializer |

### Navigation
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| smart_navigation_controller.dart | Camera-aware navigation | navigateTo(), NavigationEvent stream | Debouncing, prevents camera during transition |
| unified_navigation.dart | Unified navigation API | navigateToPage(), canPop() | Attempt to consolidate 3 nav systems |

### Network Resilience
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| network_resilience_manager.dart | Network retry logic | RetryPolicy, exponential backoff | Offline queue support |

### Offline Support
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| offline_manager.dart | Offline data management | queueOperation(), syncPending() | Uses path_provider for storage |

### State Management
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| app_state_manager.dart | Central app state | navigateToPage(), dialog state | Singleton, ChangeNotifier pattern |

### Caching
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| safe_cache.dart | Thread-safe caching | get(), put(), clear() | Mutex-based synchronization |
| simple_cache.dart | Basic in-memory cache | get(), set(), TTL support | No persistence |

### Telemetry
| File | Responsibility | Key APIs | Critical Notes |
|------|----------------|----------|----------------|
| telemetry_manager.dart | Analytics tracking | trackEvent(), trackScreen() | Sentry integration |

## Services Layer (lib/services/)

| File | Responsibility | Security Risk | Modernization Need |
|------|----------------|---------------|-------------------|
| credential_service.dart | API credential validation | HIGH - accepts self-signed certs | Certificate pinning |
| logger_service.dart | Centralized logging | MEDIUM - may log PII | Structured logging |
| navigation_service.dart | Legacy navigation | LOW | Remove - redundant |
| rxg_http_client.dart | HTTP client wrapper | HIGH - no cert validation | Dio interceptors |
| scanner_state_manager.dart | Scanner state | LOW | Merge with provider |
| scanner_validation_service.dart | Barcode validation | LOW | Move to domain layer |
| snackbar_service.dart | Snackbar display | LOW | Material 3 update |

## Views Layer (lib/views/)

| File | Route | State Dependencies | Navigation Type |
|------|-------|-------------------|-----------------|
| main_view.dart | /main | AppStateManager | PageView hub |
| home_view.dart | Index 0 | RxgApiClient | PageView page |
| connection_view.dart | Index 1 | ConnectionManager | PageView page |
| barcode_scanner.dart | Index 2 | ScannerProvider | PageView page |
| devices_view.dart | Index 3 | RxgApiClient | PageView page |
| notifications_view.dart | Index 4 | Local state | PageView page |
| room_readiness_view.dart | Index 5 | RxgApiClient | PageView page |
| onboarding_view.dart | /onboarding | CredentialService | Named route |
| room_detail_view.dart | /room-detail | RxgApiClient | Named route |
| device_detail_view.dart | /device-detail | RxgApiClient | Named route |

## RXG API Layer (lib/rxg_api/)

| File | Responsibility | Endpoints | Security Notes |
|------|----------------|-----------|----------------|
| rxg_api.dart | Main API client | /api/*, device/room CRUD | Singleton pattern |
| rxg_api_adapter.dart | API adaptation layer | Wraps rxg_api | Adds retry logic |
| rxg_api_resilient.dart | Resilient API wrapper | Fallback strategies | Offline support |
| api_credentials.dart | Credential storage | N/A | Unencrypted storage |

## Utils Layer (lib/utils/)

| File | Purpose | Risk Level | Refactor Priority |
|------|---------|------------|-------------------|
| environment_config.dart | Environment variables | HIGH - hardcoded API key | Use secure storage |
| shared_prefs.dart | SharedPreferences wrapper | MEDIUM - unencrypted | Add encryption |
| shared_prefs_wrapper.dart | Additional wrapper | LOW | Consolidate with above |
| mac_database.dart | MAC address lookup | LOW | Consider SQLite |
| mac_normalizer.dart | MAC format normalization | LOW | Add to value object |
| colors.dart | Theme colors | LOW | Use Material 3 tokens |
| enums.dart | App enumerations | LOW | Generate with freezed |
| globals.dart | Global variables | HIGH | Remove anti-pattern |
| globals_unified.dart | More globals | HIGH | Remove anti-pattern |
| tdd_debug.dart | TDD utilities | LOW | Move to test/ |

## Scanner Presentation Layer (lib/features/scanner/presentation/)

| File | Layer | Dependencies | State Management |
|------|-------|--------------|------------------|
| camera_adapter.dart | Camera integration | mobile_scanner | Stream-based |
| scanner_provider.dart | State management | Provider | ChangeNotifier |
| scanner_screen.dart | Main scanner UI | scanner_provider | Provider consumer |
| registration_screen.dart | Device registration | Forms, validation | Local state |
| device_selector_sheet.dart | Device selection UI | Bottom sheet | Callback-based |
| scan_progress_card.dart | Progress indicator | Animation | Stateful widget |
| scanner_feature_flag.dart | Feature toggling | SharedPreferences | Static methods |
| scanner_integration.dart | Integration point | Navigator | Route generation |

## Scanner Data Layer (lib/features/scanner/data/)

| File | Implementation | Status | Production Ready |
|------|----------------|--------|------------------|
| mock_device_repository.dart | In-memory mock | Complete | No - testing only |
| mock_room_repository.dart | In-memory mock | Complete | No - testing only |
| simple_device_repository.dart | Basic in-memory | Partial | No - missing persistence |

## Widget Layer (lib/widgets/)

| File | Component Type | Reusability | Material Version |
|------|---------------|-------------|------------------|
| test_mode_banner.dart | Debug banner | High | Material 2 |

## Mock Layer (lib/mocks/)

| File | Mock Type | Usage | Should Remove |
|------|-----------|-------|---------------|
| mock_barcode_scanner.dart | Scanner mock | Testing | Keep for tests |

## Critical Refactoring Priorities

### High Priority (Security/Stability)
1. **Remove hardcoded API credentials** (environment_config.dart:108)
2. **Implement certificate pinning** (credential_service.dart:17)
3. **Encrypt SharedPreferences** (shared_prefs.dart)
4. **Remove global variables** (globals.dart, globals_unified.dart)

### Medium Priority (Architecture)
1. **Complete repository implementations** (only mocks exist)
2. **Consolidate navigation systems** (3 competing systems)
3. **Remove singleton anti-patterns** (multiple services)
4. **Implement proper DI throughout** (only scanner uses GetIt)

### Low Priority (Modernization)
1. **Migrate to Material 3** (currently Material 2)
2. **Add code generation** (freezed, json_serializable)
3. **Implement go_router** (currently imperative navigation)
4. **Add proper offline support** (partial implementation)

## Test Coverage Mapping

### Well Tested
- Scanner domain layer (comprehensive unit tests)
- Core initialization (multiple test files)
- Navigation flows (integration tests)

### Needs Testing
- API layer (only mock tests exist)
- Views (limited widget tests)
- Error recovery (no specific tests found)

### Missing Tests
- Platform-specific code
- Background operations
- Offline synchronization

## Performance Hotspots

1. **Camera lifecycle** - Complex state management
2. **Navigation debouncing** - Multiple timers
3. **SharedPreferences** - Synchronous calls on main thread
4. **MAC database** - Large CSV loaded in memory
5. **Multiple state listeners** - Potential excessive rebuilds

## Security Vulnerabilities

1. **API Key Exposure** - Hardcoded in source
2. **Certificate Bypass** - Accepts any certificate
3. **Unencrypted Storage** - Credentials in plain text
4. **No Input Validation** - Direct API parameter passing
5. **Logging PII** - Debug logs may contain sensitive data

## Modernization Path

### Phase 1: Security & Stability
- Secure credential storage
- Certificate pinning
- Input validation
- Remove globals

### Phase 2: Architecture
- Complete clean architecture migration
- Implement real repositories
- Consolidate navigation
- Proper dependency injection

### Phase 3: Modernization
- Material 3 migration
- Code generation setup
- Navigator 2.0 / go_router
- Comprehensive offline support

### Phase 4: Optimization
- Performance profiling
- Memory optimization
- Network optimization
- Battery usage optimization