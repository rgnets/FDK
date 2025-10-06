# Root Directory Structure

## Clean Root Directory Organization

The root directory has been organized to follow Flutter best practices. Only essential configuration files remain at the root level.

### ✅ Files in Root Directory

#### Configuration Files
- `pubspec.yaml` - Flutter project configuration and dependencies
- `pubspec.lock` - Locked dependency versions
- `analysis_options.yaml` - Dart analyzer configuration
- `build.yaml` - Build configuration

#### Environment Files
- `.env.development` - Development environment variables
- `.env.example` - Example environment configuration

#### Build Files
- `Makefile` - Build automation commands
- `assets_manifest.yaml` - Asset configuration

#### IDE Files
- `rgnets_fdk.iml` - IntelliJ/Android Studio project file
- `.metadata` - Flutter project metadata

#### Git Files
- `.gitignore` - Git ignore rules
- `.gitattributes` - Git attributes
- `.gitmessage` - Git commit message template

#### Flutter Generated Files
- `.flutter-plugins-dependencies` - Plugin dependencies

#### Documentation
- `README.md` - Main project documentation (must stay in root)

### 📁 Directory Structure

```
rgnets-field-deployment-kit/
├── android/           # Android platform code
├── assets/           # Images, fonts, and other assets
├── build/            # Build output (gitignored)
├── docs/             # All project documentation
├── ios/              # iOS platform code
├── lib/              # Dart/Flutter source code
├── linux/            # Linux platform code
├── macos/            # macOS platform code
├── scripts/          # Test and utility scripts
├── test/             # Unit and widget tests
├── web/              # Web platform code
├── windows/          # Windows platform code
└── [config files]    # Root configuration files listed above
```

### 📝 What Was Moved

All documentation and test scripts have been properly organized:

#### To `docs/`:
- All markdown documentation files (except README.md)
- Architecture documentation
- API documentation
- Test reports
- Status reports

#### To `scripts/`:
- All Dart test scripts
- All shell scripts
- All Python scripts
- All JavaScript test files
- All HTML test files

### ✅ Benefits of Clean Root

1. **Clarity**: Easy to identify project structure
2. **Standards**: Follows Flutter/Dart conventions
3. **Maintenance**: Easier to maintain and navigate
4. **CI/CD**: Clean for automated builds
5. **Professional**: Industry-standard organization

### 🚀 Quick Commands

```bash
# Run the app
flutter run

# Run tests
flutter test

# Build for web
flutter build web

# Analyze code
flutter analyze

# See all documentation
ls docs/

# Run utility scripts
ls scripts/
```

---

*Last cleaned: 2025-08-20*