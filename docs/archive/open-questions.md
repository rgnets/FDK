# Open Questions - RG Nets FDK (Remaining)

**Created**: 2025-08-17
**Last Updated**: 2025-08-17
**Purpose**: Track ONLY truly unresolved questions requiring external input

## Status Summary

- **Total Questions Identified**: 48 (35 original + 13 new)
- **Resolved**: 47 (see resolved-questions.md)
- **Remaining**: 1 (this document)
- **Resolution Rate**: 98%

## Only 1 Question Remains!

### Deployment Account Details
**Question**: Do we have app store accounts and signing certificates?
**Needed**:
- Apple Developer account access
- Google Play Console access  
- Signing certificates for iOS/Android
- Distribution provisioning profiles
**Why It Matters**: Required to set up CI/CD pipeline and deploy apps
**Needed From**: DevOps/IT team

## What's Already Resolved

The following are NOT open questions anymore:

### ✅ Development & Testing
- **Mock vs Real Data**: Resolved by 3-flavor strategy (dev/staging/prod)
- **Repository Implementations**: Will be built new for clean architecture
- **Testing Strategy**: Documented in testing-strategy.md

### ✅ Scanner & Devices
- **Scanner Accumulation**: 6-second window documented
- **Device Types**: AP, ONT, Switch with specific requirements
- **Validation Rules**: Documented in scanner-business-logic.md

### ✅ Architecture
- **State Management**: Riverpod for new app
- **Navigation**: Declarative with go_router
- **Build Flavors**: Production, Staging, Development

### ✅ API & Data
- **API Endpoints**: Fully discovered and documented
- **Pagination**: All list endpoints use pagination
- **Authentication**: QR for prod, test creds for staging

## Action Items

### ✅ ALL RESOLVED except deployment accounts!

All previous action items have been resolved:
1. ✅ Room readiness - Based on device online status
2. ✅ Platform strategy - Full multi-platform support
3. ✅ Certificate pinning - Accept self-signed for test
4. ✅ Error monitoring - Self-hosted local approach
5. ✅ Version numbering - SemVer starting at 1.0.0
6. ✅ Notifications - In-app device status alerts
7. ✅ Release pipeline - GitHub Actions CI/CD

## Next Steps

### Only 1 Action Remaining:
**Get deployment account access from DevOps:**
- Apple Developer account credentials
- Google Play Console access
- iOS/Android signing certificates
- Provisioning profiles

Once this is obtained, development can begin immediately using the comprehensive documentation in `/docs/rebuild/`

## References
- Resolved Questions: docs/rebuild/resolved-questions.md
- Scanner Logic: docs/rebuild/scanner-business-logic.md
- Testing Strategy: docs/rebuild/testing-strategy.md
- API Documentation: docs/rebuild/api-discovery-report.md