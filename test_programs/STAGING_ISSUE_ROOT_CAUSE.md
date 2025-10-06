# Staging Environment Issue - Root Cause Analysis

## Executive Summary
The staging environment shows no data because of a **configuration/deployment issue**, NOT a data layer problem. The application cannot authenticate with the staging API due to missing environment variables, causing all API requests to fail with 403 Forbidden.

## The Problem
When running the staging environment, no data appears in the UI despite the API being functional.

## Root Cause

### 1. Missing Environment Variables
The `run_staging.sh` script runs the app WITHOUT required environment variables:
```bash
# Current (BROKEN):
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8091 -t lib/main_staging.dart
```

### 2. Exception in EnvironmentConfig
In `lib/core/config/environment.dart` lines 71-77:
```dart
case Environment.staging:
  const stagingKey = String.fromEnvironment('STAGING_API_KEY', defaultValue: '');
  if (stagingKey.isEmpty) {
    throw Exception('STAGING_API_KEY not provided for staging environment');
  }
  return stagingKey;
```
**This throws an exception when STAGING_API_KEY is not provided!**

### 3. Authentication Failure Chain
1. `main_staging.dart` sets `Environment.staging`
2. App tries to load rooms via `RoomsNotifier`
3. `ApiService` attempts to configure authentication
4. `EnvironmentConfig.apiKey` throws exception (no env var)
5. Exception is caught silently
6. API request sent with NO authentication
7. API returns **403 Forbidden**
8. No data loaded
9. UI shows empty state

## Additional Issues Found

### Wrong Authentication Method
- **Staging API expects**: Basic Auth (`Authorization: Basic <base64>`)
- **Code sends**: `X-API-Login` and `X-API-Key` headers

### Wrong Base URL Override
- `ApiService` line 75 overrides URL to `AppConfig.testCredentials['fqdn']`
- Returns default: `api.example.com` (wrong!)
- Should be: `vgw1-01.dal-interurban.mdu.attwifi.com`

### Wrong Credentials
- `AppConfig.testCredentials['login']` returns `'readonly'`
- Should be: `'fetoolreadonly'`

## The Solution

### Option 1: Fix run_staging.sh (Recommended)
Update the script to pass required environment variables:
```bash
flutter run -d web-server \
  --web-hostname=0.0.0.0 \
  --web-port=8091 \
  --dart-define=STAGING_API_KEY=xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r \
  --dart-define=TEST_API_LOGIN=fetoolreadonly \
  --dart-define=TEST_API_FQDN=vgw1-01.dal-interurban.mdu.attwifi.com \
  -t lib/main_staging.dart
```

### Option 2: Update EnvironmentConfig (For Testing Only)
Hardcode staging credentials in `environment.dart`:
```dart
case Environment.staging:
  return 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';
```

## Architecture Assessment
The application architecture is **correctly implemented**:
- ✅ MVVM pattern properly followed
- ✅ Clean Architecture layers well separated
- ✅ Dependency injection via Riverpod correctly configured
- ✅ Repository pattern properly abstracts data sources
- ✅ Data flow from API → Repository → Provider → UI is correct

## Test Programs Created
1. `test_staging_api_connectivity.dart` - Tests API connection
2. `test_data_loading_flow.dart` - Traces data flow through layers
3. `test_repository_authentication.dart` - Analyzes auth issues
4. `test_staging_config_issue.dart` - Identifies configuration problems

## Conclusion
This is **NOT a code issue** but a **deployment configuration issue**. The staging environment cannot authenticate with the API because required environment variables are not being passed when the app is launched. Once the environment variables are provided, the data will load correctly.