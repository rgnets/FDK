# RG Nets FDK - Application Entry Points

## Overview

The RG Nets Field Deployment Kit uses different entry points for various environments. Each entry point configures the application for a specific environment with appropriate data sources and API endpoints.

## Entry Point Files

### 1. `lib/main.dart` - Dynamic Environment (Default: Development)
- **Purpose**: Main entry point that reads environment from build configuration
- **Default**: Development environment if no configuration provided
- **Configuration**: Uses `--dart-define=ENVIRONMENT=<env>` to set environment
- **Supported Values**: `development`, `staging`, `production`
- **Usage**:
  ```bash
  # Development (default)
  flutter run
  
  # Staging
  flutter run --dart-define=ENVIRONMENT=staging
  
  # Production
  flutter run --dart-define=ENVIRONMENT=production
  ```

### 2. `lib/main_development.dart` - Development Environment
- **Purpose**: Dedicated development entry point
- **Environment**: Always sets `Environment.development`
- **Data Source**: Uses mock data from `MockDataService`
- **Authentication**: No authentication required
- **Title**: "RG Nets FDK (Development)"
- **Usage**:
  ```bash
  flutter run -t lib/main_development.dart
  ```

### 3. `lib/main_staging.dart` - Staging Environment
- **Purpose**: Staging/test environment entry point
- **Environment**: Always sets `Environment.staging`
- **Data Source**: Interurban test API with auto-authentication
- **Authentication**: Uses staging API key
- **Title**: "RG Nets FDK (Staging)"
- **Debug Banner**: Disabled
- **Usage**:
  ```bash
  flutter run -t lib/main_staging.dart
  ```

### 4. `lib/main_production.dart` - Production Environment
- **Purpose**: Production environment entry point
- **Environment**: Always sets `Environment.production`
- **Data Source**: Production API
- **Authentication**: Requires production API key
- **Title**: "RG Nets FDK"
- **Debug Banner**: Always disabled
- **Usage**:
  ```bash
  flutter run -t lib/main_production.dart
  ```

### 5. `lib/main_staging_debug.dart` - Staging Debug Mode
- **Purpose**: Direct access to debug screen with staging API
- **Environment**: Sets `Environment.staging`
- **Special Feature**: Routes directly to `/debug` screen
- **Logger**: Enhanced logging with emojis for visibility
- **Title**: "RG Nets FDK Debug (Staging)"
- **Usage**:
  ```bash
  flutter run -t lib/main_staging_debug.dart
  ```

## Environment Characteristics

### Development Environment
- **Mock Data**: Uses synthetic data with production-format device names
- **Device Naming**: `[Type][Building]-[Floor]-[Serial]-[Model]-[Room]`
  - Example: `AP1-2-0030-AP520-RM205`
- **No Authentication**: Bypasses API authentication
- **Instant Data**: No network delays

### Staging Environment
- **Test API**: Connected to Interurban test server
- **Auto-Authentication**: Uses predefined staging API key
- **Real Network**: Actual API calls with network latency
- **Test Data**: Server-provided test dataset

### Production Environment
- **Live API**: Connected to production servers
- **Full Authentication**: Requires valid production credentials
- **Real Data**: Actual device data from the field
- **Performance**: Optimized with field selection and caching

## Quick Reference

| Entry Point | Environment | Data Source | Authentication | When to Use |
|------------|-------------|-------------|----------------|-------------|
| `main.dart` | Dynamic | Varies | Varies | Flexible development/testing |
| `main_development.dart` | Development | Mock | None | Local development with synthetic data |
| `main_staging.dart` | Staging | Test API | Auto | Testing with server integration |
| `main_production.dart` | Production | Live API | Required | Production deployment |
| `main_staging_debug.dart` | Staging | Test API | Auto | Debug/diagnostic testing |

## Best Practices

1. **Development**: Use `main_development.dart` for feature development and UI testing
2. **Integration Testing**: Use `main_staging.dart` to test API integration
3. **Production Build**: Always use `main_production.dart` for release builds
4. **Debugging Issues**: Use `main_staging_debug.dart` for troubleshooting API issues

## Building for Release

```bash
# iOS Production Build
flutter build ios -t lib/main_production.dart --release

# Android Production Build  
flutter build apk -t lib/main_production.dart --release

# Development Build (for testing)
flutter build apk -t lib/main_development.dart --debug
```

## VS Code Launch Configurations

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_development.dart"
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart"
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_production.dart"
    },
    {
      "name": "Debug (Staging)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging_debug.dart"
    }
  ]
}
```

## Troubleshooting

### App Shows Wrong Data
1. Verify you're using the correct entry point
2. Check `flutter run` command includes correct `-t` flag
3. For development mock data: use `main_development.dart`
4. For staging API data: use `main_staging.dart`

### Mock Data Not Showing Production Format
- Ensure using `main_development.dart` (not `main.dart` without configuration)
- Verify `MockDataService` has latest production format implementation
- Check device names follow pattern: `[Type][Building]-[Floor]-[Serial]-[Model]-[Room]`

### Authentication Issues
- Development: No authentication needed with `main_development.dart`
- Staging: Auto-authenticated with `main_staging.dart`
- Production: Ensure valid API key in `main_production.dart`