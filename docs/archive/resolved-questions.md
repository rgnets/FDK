# Resolved Questions - ATT FE Tool

**Created**: 2025-08-17
**Purpose**: Document all questions that have been answered through investigation or user clarification

## Summary

Out of 48 total questions identified (35 original + 13 new), 45 have been resolved:
- 5 through API exploration and testing
- 40 through user clarification about new app requirements and business logic

**Latest resolutions (2025-08-17 - Session 2)**: 
- Room readiness logic (online status of devices)
- Platform strategy (proper web/desktop support)
- Version management (semantic versioning from 1.0.0)
- CI/CD pipeline requirements (full automation)

## Resolved Through API Exploration

### 1. Complete RXG API Specification
**Original Question**: What is the complete RXG API specification?
**Resolution Date**: 2025-08-17
**Answer**: Discovered through API testing (scripts/explore_rxg_api.dart)
**Key Findings**:
- All list endpoints use pagination: `{count, page, page_size, total_pages, next, results}`
- Confirmed endpoints:
  - `/api/whoami.json` - Authentication
  - `/api/devices.json` - Generic devices (1599 total)
  - `/api/switch_devices.json` - Switches (1 total)
  - `/api/access_points.json` - APs (221 total)
  - `/api/wlan_devices.json` - WLAN controllers (3 total)
  - `/api/pms_rooms.json` - PMS rooms (132 total)
- Missing endpoints: notifications, ONT-specific, direct room CRUD
**Documentation**: docs/rebuild/api-discovery-report.md

### 2. Database Schema (Partial)
**Original Question**: What is the complete data model for rooms and devices?
**Resolution Date**: 2025-08-17
**Answer**: Extracted from actual API responses
**Key Models**:
- Devices: id, name, mac, account, radius_server
- Access Points: Extended device with channels, online status, pms_room
- Switch Devices: 155+ fields including media_converters (ONTs)
- PMS Rooms: Managed through Property Management System
**Documentation**: docs/rebuild/data-models.md

### 3. MAC Database Updates
**Original Question**: How often should MAC databases be updated?
**Resolution Date**: 2025-08-17
**Answer**: Client-side only, not from API
- Weekly updates via GitHub Action (cron: '0 0 * * 0')
- Files: assets/mac_unified.csv, assets/oui.csv
- Process: scripts/unify_mac_databases.dart

### 4. Room Readiness Calculation (Partial)
**Original Question**: What determines if a room is "ready"?
**Resolution Date**: 2025-08-17
**Answer**: Likely based on PMS room device associations
- Access points have pms_room associations
- Readiness calculated client-side from device counts
- Business rules still unclear

### 5. API Endpoints List
**Original Question**: What are all the RXG API endpoints?
**Resolution Date**: 2025-08-17
**Answer**: Complete list discovered and documented
**Documentation**: docs/rebuild/api-contracts.md

## Resolved Through User Clarification

### 6. Build Flavors
**Original Question**: Are there supposed to be development/staging/production flavors?
**Resolution Date**: 2025-08-17
**Answer**: Yes, three flavors needed:
1. **Production**: QR code auth only, no hardcoded credentials
2. **Staging**: Test credentials + live API
3. **Development**: Fully mocked data

### 7. Authentication Flow
**Original Question**: Is the hardcoded API key intentional?
**Resolution Date**: 2025-08-17
**Answer**: Yes, for test environments only
- Production uses QR code scanning exclusively
- Test credentials (fetoolreadonly) are read-only
- Not a security vulnerability
**Related**: Build flavors separate auth methods

### 8. Offline Capabilities
**Original Question**: What features should work offline?
**Resolution Date**: 2025-08-17
**Answer**: Read-only caching intended but not implemented
- Design intent: Cache API data for viewing when offline
- Current reality: OfflineManager exists but disconnected
- Scanner cannot work offline currently
- Implementation needed in new app

### 9. Mixed Architecture Pattern
**Original Question**: Why do both views/ and features/ directories exist?
**Resolution Date**: 2025-08-17
**Answer**: Existing code is "dirty" with incomplete migrations
**New App Requirement**: Clean Architecture with feature-first organization

### 10. Navigation Strategy
**Original Question**: Is there a plan to migrate to declarative navigation?
**Resolution Date**: 2025-08-17
**Answer**: New app should be entirely declarative
**New App Requirement**: Use go_router, no imperative navigation

### 11. State Management
**Original Question**: Is Provider the final choice?
**Resolution Date**: 2025-08-17
**Answer**: New app should use modern state management
**New App Requirement**: Riverpod (preferred) or Bloc, no legacy Provider

### 12. Code Generation
**Original Question**: Why is build_runner configured but no generated files?
**Resolution Date**: 2025-08-17
**Answer**: Incomplete migration in dirty codebase
**New App Requirement**: Proper code generation from start (freezed, json_serializable)

### 13. Internationalization
**Original Question**: Is this app English only?
**Resolution Date**: 2025-08-17
**Answer**: Build with i18n support regardless
**New App Requirement**: .arb files and flutter_localizations from start

### 14. Error Codes System
**Original Question**: Is there a standardized error code system?
**Resolution Date**: 2025-08-17
**Answer**: Not in current app, required in new app
**New App Requirement**: Structured error codes with sealed classes

### 15. Scanner Accumulation Window
**Original Question**: Why is the scanner accumulation window 6 seconds?
**Resolution Date**: 2025-08-17
**Answer**: Critical business logic for barcode scanning
**Explanation**:
- Barcode scanner outputs only 1 barcode at a time
- Device registration requires 2-3 barcodes minimum (serial number, MAC address, etc.)
- Physical devices have 8-10 different barcodes on them
- Accumulation window allows collecting multiple barcodes from same device
- 6 seconds provides balance between:
  - Enough time to scan required barcodes
  - Not too long that user can't move to different device
**Implementation**: Accumulator collects barcodes within window, validates when required fields are present
**File**: lib/features/scanner/domain/services/scan_accumulator.dart

## Testing Strategy Questions (Resolved as a Group)

### 16. Test Data Modes
**Original Question**: When should each test data mode be used?
**Resolution Date**: 2025-08-17
**Answer**: Simplified to 3-flavor strategy
**Solution**: 
- Production: Real API only
- Staging: Test credentials + test API
- Development: Synthetic factories only
**Note**: Complex modes (synthetic/real/recorded/mixed) were part of "dirty" codebase

### 17. TDD Scripts Purpose
**Original Question**: What do the TDD batch files do?
**Resolution Date**: 2025-08-17
**Answer**: Part of old testing infrastructure
**Solution**: Use standard Flutter testing with clear build flavors
**Note**: Not needed for new app

### 18. Fixture Recording System
**Original Question**: How does fixture recording/playback work?
**Resolution Date**: 2025-08-17
**Answer**: Replace with simple factory pattern
**Solution**: Factories generate test data based on recorded patterns
**Benefit**: Can generate larger datasets for stress testing

### 19. Testing Strategy Overview
**Documentation**: docs/rebuild/testing-strategy.md
**Key Decision**: Simple 3-flavor approach replaces complex test infrastructure
**Principle**: Each environment has ONE clear purpose, no mixing

## Implementation Strategy Questions

### 20. Mock vs Real Data Strategy
**Original Question**: When to use mocks vs real data?
**Resolution Date**: 2025-08-17
**Answer**: Clearly defined by 3-flavor strategy
- **Development**: Always mocked/factories
- **Staging**: Always real test API
- **Production**: Always real production API
**No mixing**: Each environment has one data source

### 21. Repository Implementations
**Original Question**: Where should real repository implementations connect?
**Resolution Date**: 2025-08-17
**Answer**: Build new repositories for clean architecture
- Mock repositories in old code are just reference
- New app needs proper repository pattern
- Implement with Riverpod providers
**Documentation**: Part of clean architecture approach

### 22. Device Type Specifications
**Original Question**: What are all supported device types?
**Resolution Date**: 2025-08-17
**Answer**: Three device types with specific requirements
- **Access Point (AP)**: Requires serial + MAC
- **ONT**: Requires serial + MAC  
- **Switch**: Requires serial only
**Documentation**: docs/rebuild/scanner-business-logic.md

## Recently Resolved Questions (User Session 2025-08-17)

### 23. Room Readiness Logic
**Original Question**: What determines room readiness beyond device counts?
**Resolution Date**: 2025-08-17
**Answer**: Room readiness is based on online status of ALL associated devices
**Details**:
- **Fully Ready**: All devices (APs, ONTs, Switches) are online
- **Partially Ready**: Some devices online but not all
- **Not Ready**: No devices online or no devices assigned
**Documentation**: docs/rebuild/room-readiness-logic.md

### 24. Platform Strategy
**Original Question**: Should web/desktop be properly supported?
**Resolution Date**: 2025-08-17
**Answer**: Yes, properly support web and desktop platforms
**Rationale**:
- Originally for testing but proved useful
- Enables office work, reporting, training
- Modern Flutter makes multi-platform feasible
**Documentation**: docs/rebuild/platform-strategy.md

### 25. Version Management
**Original Question**: How should the new app handle versioning?
**Resolution Date**: 2025-08-17
**Answer**: Follow modern semantic versioning standards
**Details**:
- Start fresh at 1.0.0 (not continuing from 0.7.7)
- Use SemVer: MAJOR.MINOR.PATCH+BUILD
- Automated version bumping in CI/CD
**Documentation**: docs/rebuild/version-management.md

### 26. CI/CD Pipeline
**Original Question**: What should the deployment pipeline look like?
**Resolution Date**: 2025-08-17
**Answer**: Fully automated CI/CD with GitHub Actions
**Components**:
- Automated testing on every push
- Platform-specific build pipelines
- Automated deployment to staging
- Manual approval for production
**Documentation**: docs/rebuild/cicd-pipeline.md

## Implementation Questions Resolved (2025-08-17 - Final Session)

### 27. Pagination Strategy
**Resolution**: Background async loading optimized for offline use
**Details**: First load shows loading indicator, then background refresh
**Documentation**: docs/rebuild/implementation-decisions.md

### 28. Offline Cache Duration  
**Resolution**: 12 hours cache validity
**Details**: All data cached and viewable offline for 12 hours

### 29. Manual Entry Fallback
**Resolution**: No manual entry - scanner only
**Reason**: Ensures data accuracy

### 30. Batch Scanning
**Resolution**: Not supported - single device at a time
**Current**: 6-second accumulation window per device

### 31. Dark Mode
**Resolution**: Yes, implement dark mode
**Implementation**: System-aware with manual override

### 32. Tablet Support
**Resolution**: Full tablet optimization with responsive layouts
**Breakpoints**: <600px phone, 600-900px tablet, >900px desktop

### 33. Conflict Resolution
**Resolution**: Server-side handling, app accepts server version

### 34. Background Polling
**Resolution**: Yes, poll every 30 seconds when active

### 35. Image Caching
**Resolution**: Use modern best practices (CachedNetworkImage)

### 36. Local Database
**Resolution**: Isar recommended (fast, Flutter-native)
**Alternative**: SQLite with drift

### 37. PII/GDPR
**Resolution**: Not required at this time

### 38. WCAG Compliance
**Resolution**: Not required, focus on responsive design

### 39. API Rate Limiting
**Resolution**: No rate limits exist

### 40. PMS Room Editing
**Resolution**: Read-only, cannot edit PMS rooms

### 41. Notification System
**Resolution**: In-app device status alerts only

### 42. Certificate Handling
**Resolution**: Accept self-signed for test environments

### 43. Error Monitoring
**Resolution**: Self-hosted local-first approach

### 44. Analytics
**Resolution**: Local SQLite with export capability

### 45. Offline Data Scope
**Resolution**: Cache everything user has viewed

## Critical Insight

**The existing codebase is "dirty" with incomplete migrations.**
We are documenting requirements for a **completely new, modern Flutter app**, not fixing the old one.

## New App Requirements Summary

Based on resolved questions, the new app requires:

### Technical Stack
- **State Management**: Riverpod or Bloc
- **Navigation**: go_router (declarative)
- **Code Generation**: freezed, json_serializable, riverpod_generator
- **Architecture**: Clean Architecture, feature-first

### Features
- **Authentication**: QR code for production, test credentials for dev/staging
- **Offline**: Read-only caching of API data
- **i18n**: Multi-language support structure
- **Error Handling**: Structured error code system

### Build Configuration
- Three flavors: production, staging, development
- Proper separation of concerns
- Environment-specific configurations

## References
- API Discovery Report: docs/rebuild/api-discovery-report.md
- API Contracts: docs/rebuild/api-contracts.md
- Data Models: docs/rebuild/data-models.md
- Architecture: docs/rebuild/architecture.md