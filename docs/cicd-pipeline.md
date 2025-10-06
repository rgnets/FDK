# CI/CD Pipeline Requirements - RG Nets FDK

**Created**: 2025-08-17
**Purpose**: Define automated CI/CD pipeline for the new app

## Overview

The CI/CD pipeline will automate the entire release process from code commit to app store deployment.

## Pipeline Architecture

### Git Flow Integration
```
Developer Push → CI Tests → Merge to Develop → Staging Build → Production Release
```

### Pipeline Stages
1. **Continuous Integration** (Every push)
2. **Continuous Deployment** (Staging - automatic)
3. **Continuous Delivery** (Production - manual approval)

## GitHub Actions Configuration

### Main Workflow
```yaml
# .github/workflows/main.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop, 'feature/**']
  pull_request:
    branches: [main, develop]
  release:
    types: [created]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build:
    needs: test
    strategy:
      matrix:
        platform: [ios, android, web, windows, macos, linux]
    runs-on: ${{ matrix.platform == 'ios' || matrix.platform == 'macos' ? 'macos-latest' : matrix.platform == 'windows' ? 'windows-latest' : 'ubuntu-latest' }}
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ${{ matrix.platform }} --release

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploy to production"
```

## Platform-Specific Pipelines

### iOS Pipeline
```yaml
# .github/workflows/ios.yml
name: iOS Build & Deploy

on:
  push:
    tags: ['v*']

jobs:
  ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install Apple Certificate
        uses: apple-actions/import-codesign-certs@v2
        with:
          p12-file-base64: ${{ secrets.IOS_CERT_BASE64 }}
          p12-password: ${{ secrets.IOS_CERT_PASSWORD }}
      
      - name: Install Provisioning Profile
        run: |
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "${{ secrets.IOS_PROFILE_BASE64 }}" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision
      
      - name: Build IPA
        run: |
          flutter build ios --release --no-codesign
          cd ios
          xcodebuild -workspace Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -archivePath build/Runner.xcarchive \
            archive
          xcodebuild -exportArchive \
            -archivePath build/Runner.xcarchive \
            -exportPath build \
            -exportOptionsPlist ExportOptions.plist
      
      - name: Upload to App Store Connect
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: ios/build/Runner.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}
```

### Android Pipeline
```yaml
# .github/workflows/android.yml
name: Android Build & Deploy

on:
  push:
    tags: ['v*']

jobs:
  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Decode Keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
          echo "storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" >> android/key.properties
          echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties
      
      - name: Build APK/AAB
        run: |
          flutter build appbundle --release
          flutter build apk --release
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.att.fe_tool
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
```

### Web Deployment
```yaml
# .github/workflows/web.yml
name: Web Build & Deploy

on:
  push:
    branches: [main]

jobs:
  web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Build Web
        run: |
          flutter build web --release --web-renderer canvaskit
          
      - name: Deploy to S3
        uses: jakejarvis/s3-sync-action@master
        with:
          args: --delete
        env:
          AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          SOURCE_DIR: 'build/web'
      
      - name: Invalidate CloudFront
        uses: chetan/invalidate-cloudfront-action@v2
        env:
          DISTRIBUTION: ${{ secrets.CLOUDFRONT_DISTRIBUTION }}
          PATHS: '/*'
          AWS_REGION: 'us-east-1'
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Testing Strategy

### Unit Tests
```yaml
- name: Run Unit Tests
  run: |
    flutter test --coverage
    flutter test --machine > test-results.json
```

### Integration Tests
```yaml
- name: Run Integration Tests
  run: |
    flutter test integration_test
```

### Golden Tests
```yaml
- name: Run Golden Tests
  run: |
    flutter test --update-goldens
```

## Code Quality Checks

### Static Analysis
```yaml
- name: Analyze Code
  run: |
    flutter analyze
    dart format --set-exit-if-changed .
```

### Linting
```yaml
- name: Lint Code
  run: |
    flutter pub run dart_code_metrics:metrics analyze lib
    flutter pub run dart_code_metrics:metrics check-unused-code lib
    flutter pub run dart_code_metrics:metrics check-unused-files lib
```

### Security Scanning
```yaml
- name: Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    scan-ref: '.'
```

## Environment Configuration

### Build Flavors
```bash
# Development
flutter build apk --flavor development --target lib/main_development.dart

# Staging
flutter build apk --flavor staging --target lib/main_staging.dart

# Production
flutter build apk --flavor production --target lib/main_production.dart
```

### Environment Variables
```yaml
env:
  FLUTTER_VERSION: '3.24.0'
  DART_VERSION: '3.5.4'
  BUILD_FLAVOR: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
```

## Secrets Management

### Required Secrets
```yaml
# iOS
IOS_CERT_BASE64           # iOS signing certificate
IOS_CERT_PASSWORD         # Certificate password
IOS_PROFILE_BASE64        # Provisioning profile
APPSTORE_ISSUER_ID        # App Store Connect API
APPSTORE_KEY_ID           # App Store Connect API
APPSTORE_PRIVATE_KEY      # App Store Connect API

# Android
ANDROID_KEYSTORE_BASE64   # Android keystore file
ANDROID_KEYSTORE_PASSWORD # Keystore password
ANDROID_KEY_PASSWORD      # Key password
ANDROID_KEY_ALIAS         # Key alias
GOOGLE_PLAY_SERVICE_ACCOUNT # Play Store service account

# Web/Cloud
AWS_ACCESS_KEY_ID         # AWS credentials
AWS_SECRET_ACCESS_KEY     # AWS credentials
AWS_S3_BUCKET            # S3 bucket name
CLOUDFRONT_DISTRIBUTION   # CloudFront ID

# General
SENTRY_DSN               # Error tracking
SLACK_WEBHOOK            # Notifications
```

## Release Process

### Automated Release
```yaml
# .github/workflows/release.yml
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to release'
        required: true
      
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Update Version
        run: |
          dart scripts/update_version.dart ${{ github.event.inputs.version }}
          
      - name: Create Release
        uses: actions/create-release@v1
        with:
          tag_name: v${{ github.event.inputs.version }}
          release_name: Release ${{ github.event.inputs.version }}
          body: |
            See CHANGELOG.md for details
          draft: false
          prerelease: false
```

## Monitoring & Notifications

### Slack Integration
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build ${{ github.run_number }} ${{ job.status }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

### Build Status Badge
```markdown
![Build Status](https://github.com/att/fe-tool/workflows/CI/badge.svg)
```

## Rollback Strategy

### Automatic Rollback
```yaml
- name: Check Health
  run: |
    response=$(curl -s -o /dev/null -w "%{http_code}" https://api.example.com/health)
    if [ $response != "200" ]; then
      echo "Health check failed, rolling back"
      exit 1
    fi
```

## Performance Monitoring

### Build Time Tracking
```yaml
- name: Track Build Time
  run: |
    echo "Build started at: $(date)"
    # ... build steps ...
    echo "Build completed at: $(date)"
```

### Bundle Size Analysis
```yaml
- name: Analyze Bundle Size
  run: |
    flutter build apk --analyze-size
    flutter build ios --analyze-size
```

## Manual Steps Required

### Initial Setup (One-time)

1. **App Store Connect**
   - Create app in App Store Connect
   - Generate API keys for automation
   - Set up TestFlight

2. **Google Play Console**
   - Create app in Play Console
   - Generate service account for API access
   - Set up internal testing track

3. **Code Signing**
   - Generate iOS certificates and profiles
   - Create Android keystore
   - Store securely in GitHub Secrets

4. **Cloud Infrastructure**
   - Set up S3 bucket for web hosting
   - Configure CloudFront CDN
   - Create IAM user for deployments

### Per-Release Steps

1. **Release Notes**
   - Write release notes
   - Update CHANGELOG.md
   - Create GitHub release

2. **App Store Submission**
   - Add release notes in App Store Connect
   - Submit for review
   - Monitor review status

3. **Play Store Submission**
   - Add release notes in Play Console
   - Complete store listing
   - Submit for review

## Documentation

### Build Documentation
```yaml
- name: Generate Docs
  run: |
    dart doc
    flutter pub run dartdoc
```

### API Documentation
```yaml
- name: Generate API Docs
  run: |
    dart run build_runner build
    swagger-codegen generate -i api.yaml -l dart
```

## Troubleshooting Guide

### Common Issues

1. **iOS Build Failures**
   - Check certificate expiry
   - Verify provisioning profile
   - Update Xcode version

2. **Android Build Failures**
   - Check keystore validity
   - Verify gradle versions
   - Check Play Store API access

3. **Web Deployment Issues**
   - Verify S3 permissions
   - Check CloudFront settings
   - Test CORS configuration

## Benefits

1. **Automation**: Reduces manual effort
2. **Consistency**: Same process every time
3. **Speed**: Faster releases
4. **Quality**: Automated testing
5. **Visibility**: Clear pipeline status

## Next Steps

1. Set up GitHub repository secrets
2. Create app store accounts
3. Generate signing certificates
4. Configure cloud infrastructure
5. Test pipeline end-to-end
6. Document team procedures
7. Train team on pipeline usage

## References
- GitHub Actions: https://docs.github.com/actions
- Flutter CI/CD: https://docs.flutter.dev/deployment/cd
- Fastlane (alternative): https://fastlane.tools/