# Testing Strategy - NEW RG Nets Field Deployment Kit

**Created**: 2025-08-17
**Purpose**: Define testing strategy for the new, modern Flutter app

## Build Flavors (Simple & Clean)

### 1. Production Build
- **Authentication**: QR code scanning ONLY
- **Data**: Live production API
- **Credentials**: None hardcoded
- **Target**: App Store / Play Store release
- **Users**: Field engineers in production

### 2. Staging Build  
- **Authentication**: Hardcoded test credentials (fetoolreadonly)
- **Data**: Live test/staging API
- **Credentials**: Test account hardcoded
- **Target**: TestFlight / Internal testing
- **Users**: QA team, UAT testing

### 3. Development Build
- **Authentication**: Mocked/synthetic
- **Data**: Factory-generated from recorded patterns
- **Credentials**: Not needed
- **Target**: Local development
- **Users**: Developers

## Data Generation Strategy

### Development Build Data
- Use **factories** that generate realistic data
- Base patterns on recorded real API responses
- Generate larger datasets than production for stress testing
- Deterministic for consistent testing
- Example: If API has 200 devices, generate 2000 for testing

### Factory Pattern Example
```dart
class DeviceFactory {
  // Based on real API response structure
  static Device generate({int? seed}) {
    return Device(
      id: seed ?? Random().nextInt(10000),
      name: 'AP-${seed ?? Random().nextInt(999)}',
      mac: generateMac(seed),
      serialNumber: 'SN${(seed ?? 0).toString().padLeft(8, '0')}',
      online: Random().nextBool(),
      pmsRoom: RoomFactory.generate(),
    );
  }
  
  static List<Device> generateBatch(int count) {
    return List.generate(count, (i) => generate(seed: i));
  }
}
```

## Testing Levels

### Unit Tests
- **Data**: Synthetic/factories
- **Scope**: Individual functions/classes
- **Speed**: Milliseconds
- **Frequency**: On every commit

### Integration Tests
- **Data**: Staging environment
- **Scope**: Feature workflows
- **Speed**: Seconds
- **Frequency**: Before merge

### E2E Tests
- **Data**: Dedicated test backend (maybe)
- **Scope**: Complete user journeys
- **Speed**: Minutes
- **Frequency**: Before release

## Development Workflow

### Feature Development Flow
1. **Start**: Development build with synthetic data
2. **Test**: Staging build against test API
3. **Deploy**: Production build to stores

### No Test Code in Production
- Production build has ZERO test hooks
- No debug panels
- No mock data options
- No credential overrides

## Key Principles

### Simplicity First
- Three builds, clear purposes
- No complex test modes
- No mixing of environments

### Data Isolation
- Production: Real data only
- Staging: Test API only
- Development: Synthetic only

### Clear Boundaries
```dart
// build_config.dart
enum BuildFlavor {
  production,  // QR auth, prod API
  staging,     // Test creds, test API
  development, // All synthetic
}

class BuildConfig {
  static BuildFlavor get current => _current;
  
  static bool get isProduction => _current == BuildFlavor.production;
  static bool get isStaging => _current == BuildFlavor.staging;
  static bool get isDevelopment => _current == BuildFlavor.development;
}
```

## What We DON'T Need

From the old "dirty" codebase, we're NOT carrying forward:
- Complex DataMode enum (synthetic/real/recorded/mixed)
- Runtime switching between modes
- Fixture recording/playback system
- Test helpers in production code
- Mixed authentication strategies

## Implementation

### Flavor Configuration
```yaml
# flutter build commands
flutter build apk --flavor production --dart-define=FLAVOR=production
flutter build apk --flavor staging --dart-define=FLAVOR=staging  
flutter build apk --flavor development --dart-define=FLAVOR=development
```

### Dependency Injection
```dart
// Use Riverpod to provide appropriate implementations
final apiProvider = Provider<ApiService>((ref) {
  switch (BuildConfig.current) {
    case BuildFlavor.production:
      return RealApiService();
    case BuildFlavor.staging:
      return RealApiService(baseUrl: stagingUrl);
    case BuildFlavor.development:
      return MockApiService();
  }
});
```

## Benefits

### For Developers
- Clear, simple mental model
- Fast local development
- No API dependencies for dev work

### For QA
- Consistent test environment
- Real API behavior testing
- No production data access

### For Users
- Clean production build
- No test code overhead
- Optimal performance

## Summary

The new app uses a **simple three-flavor strategy**:
1. **Production**: Real everything
2. **Staging**: Test credentials + test API
3. **Development**: All synthetic

This replaces the complex, "dirty" testing infrastructure of the old app with something clean and maintainable.