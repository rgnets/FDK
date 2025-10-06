# Version Management Strategy - RG Nets FDK

**Created**: 2025-08-17
**Purpose**: Define version management approach for the new app

## Decision

Since this is an entirely new app, the version management strategy will follow modern standards.

## Version Numbering

### Semantic Versioning (SemVer)
```
MAJOR.MINOR.PATCH+BUILD
```

**Example**: `1.0.0+1`

- **MAJOR**: Breaking changes, major features
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, minor improvements
- **BUILD**: Build number (auto-incremented)

### Starting Version
- **New App**: `1.0.0` (fresh start, not continuing from 0.7.7)
- **Old App**: Remains at 0.7.x (maintenance only)

## Platform-Specific Versioning

### Version Synchronization
All platforms use same version number for consistency:
- iOS: CFBundleShortVersionString = `1.0.0`
- Android: versionName = `1.0.0`
- Web: package.json version = `1.0.0`
- Windows/macOS/Linux: Same version

### Build Numbers
Platform-specific build numbers:
- iOS: CFBundleVersion (integer)
- Android: versionCode (integer)
- Others: Build metadata in version string

## Version Configuration

### pubspec.yaml
```yaml
name: rg_nets_fdk
description: RG Nets Field Deployment Kit
version: 1.0.0+1  # version+buildNumber
```

### Version Update Script
```dart
// scripts/update_version.dart
import 'dart:io';
import 'package:yaml_edit/yaml_edit.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart scripts/update_version.dart <version>');
    exit(1);
  }
  
  final version = args[0];
  final buildNumber = args.length > 1 ? args[1] : '1';
  
  // Update pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  final pubspecContent = pubspecFile.readAsStringSync();
  final yamlEditor = YamlEditor(pubspecContent);
  
  yamlEditor.update(['version'], '$version+$buildNumber');
  pubspecFile.writeAsStringSync(yamlEditor.toString());
  
  print('Updated version to $version+$buildNumber');
}
```

## Git Tagging Strategy

### Release Tags
```bash
# Production releases
git tag -a v1.0.0 -m "Release version 1.0.0"

# Pre-releases
git tag -a v1.0.0-beta.1 -m "Beta release 1.0.0-beta.1"
git tag -a v1.0.0-rc.1 -m "Release candidate 1.0.0-rc.1"
```

### Tag Format
- Production: `v1.0.0`
- Beta: `v1.0.0-beta.1`
- Release Candidate: `v1.0.0-rc.1`
- Alpha/Dev: `v1.0.0-alpha.1`

## Changelog Management

### CHANGELOG.md Format
```markdown
# Changelog

## [1.0.0] - 2025-XX-XX
### Added
- Initial release of new RG Nets Field Deployment Kit
- QR code authentication for production
- Multi-platform support (iOS, Android, Web, Desktop)
- Offline data caching

### Changed
- Complete rebuild with modern Flutter architecture
- Migrated from Provider to Riverpod
- Declarative navigation with go_router

### Fixed
- Scanner accumulation window issues
- Room readiness calculation accuracy
```

### Changelog Generation
```bash
# Use conventional commits for automatic changelog
npm install -g conventional-changelog-cli
conventional-changelog -p angular -i CHANGELOG.md -s
```

## Version Display in App

### Version Info Screen
```dart
class VersionInfo {
  static String get appVersion => '1.0.0';
  static String get buildNumber => '1';
  static String get fullVersion => '$appVersion+$buildNumber';
  
  static String get environment {
    switch (flavor) {
      case 'production': return 'Production';
      case 'staging': return 'Staging';
      case 'development': return 'Development';
      default: return 'Unknown';
    }
  }
  
  static Widget versionWidget() {
    return Column(
      children: [
        Text('Version: $fullVersion'),
        Text('Environment: $environment'),
        Text('Build Date: ${DateTime.now()}'),
      ],
    );
  }
}
```

### About Dialog
```dart
showAboutDialog(
  context: context,
  applicationName: 'RG Nets Field Deployment Kit',
  applicationVersion: VersionInfo.fullVersion,
  applicationIcon: Image.asset('assets/icon.png'),
  applicationLegalese: '© 2025 RG Nets',
);
```

## Release Branches

### Git Flow
```
main (production)
├── develop (integration)
│   ├── feature/scanner-improvements
│   ├── feature/offline-mode
│   └── feature/web-support
├── release/1.0.0 (release preparation)
└── hotfix/1.0.1 (emergency fixes)
```

### Branch Protection Rules
- **main**: Requires PR, 2 approvals, passing tests
- **develop**: Requires PR, 1 approval, passing tests
- **release/***: Requires PR, 2 approvals
- **feature/***: No restrictions

## Version Bumping Process

### Manual Process
1. Update version in pubspec.yaml
2. Update CHANGELOG.md
3. Commit changes
4. Create git tag
5. Push tag to trigger release

### Automated Process (Recommended)
```yaml
# .github/workflows/version-bump.yml
name: Version Bump
on:
  workflow_dispatch:
    inputs:
      version_type:
        type: choice
        options: [patch, minor, major]
        
jobs:
  bump:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: dart scripts/update_version.dart
      - run: git commit -am "chore: bump version"
      - run: git tag -a v$VERSION -m "Release $VERSION"
      - run: git push --follow-tags
```

## Pre-release Versions

### Beta Testing
```yaml
version: 1.0.0-beta.1+100  # Pre-release version
```

### TestFlight/Internal Testing
- Use build numbers 1-999 for testing
- Use 1000+ for production releases

## Version Compatibility

### Minimum Supported Versions
```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.24.0"
```

### Breaking Changes Policy
- Document all breaking changes
- Provide migration guides
- Deprecate before removing
- Major version bump for breaking changes

## Version Tracking

### Analytics
```dart
// Track app version in analytics
analytics.setUserProperty(
  name: 'app_version',
  value: VersionInfo.fullVersion,
);
```

### Error Reporting
```dart
// Include version in error reports
Sentry.configureScope((scope) {
  scope.setTag('app_version', VersionInfo.fullVersion);
  scope.setTag('environment', VersionInfo.environment);
});
```

## Rollback Strategy

### Version Rollback
1. Revert to previous git tag
2. Cherry-pick critical fixes
3. Create new patch version
4. Fast-track release process

### Database Migrations
- Always support rollback
- Version database schema
- Test rollback scenarios

## Version Documentation

### Release Notes Template
```markdown
# Release Notes - v1.0.0

## What's New
- Feature 1
- Feature 2

## Improvements
- Performance enhancement
- UI polish

## Bug Fixes
- Fixed issue #123
- Fixed issue #456

## Known Issues
- Issue #789 (workaround available)

## Migration Guide
- Step 1
- Step 2
```

## Version API Compatibility

### API Version Headers
```dart
// Include app version in API requests
dio.options.headers['X-App-Version'] = VersionInfo.fullVersion;
dio.options.headers['X-Platform'] = PlatformInfo.platformName;
```

### Minimum API Version
```dart
// Check API compatibility
if (apiVersion < minimumApiVersion) {
  showUpdateRequiredDialog();
}
```

## Deprecation Policy

### Feature Deprecation
1. Mark as deprecated in version N
2. Show warning in version N+1
3. Remove in version N+2
4. Document in CHANGELOG

### API Deprecation
```dart
@Deprecated('Use newMethod instead. Will be removed in v2.0.0')
void oldMethod() {
  // Show deprecation warning
  print('Warning: oldMethod is deprecated');
  newMethod();
}
```

## Benefits of This Strategy

1. **Clear Communication**: Users know what changed
2. **Predictable Releases**: Semantic versioning
3. **Easy Rollback**: Tagged releases
4. **Multi-platform Sync**: Same version everywhere
5. **Automated Process**: Reduces human error

## Implementation Checklist

- [ ] Set up version update script
- [ ] Configure git tag format
- [ ] Create CHANGELOG.md
- [ ] Add version display in app
- [ ] Set up branch protection
- [ ] Configure CI/CD versioning
- [ ] Document release process
- [ ] Train team on versioning

## References
- Semantic Versioning: https://semver.org/
- Conventional Commits: https://www.conventionalcommits.org/
- Flutter Versioning: https://docs.flutter.dev/deployment/android#updating-the-app-version