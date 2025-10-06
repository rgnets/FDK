# Platform Strategy - RG Nets FDK

**Created**: 2025-08-17
**Purpose**: Define multi-platform support strategy for the new app

## Platform Support Decision

The new app will **properly support** web and desktop platforms in addition to mobile.

### Rationale
- Originally added for testing, but proved useful
- Enables broader use cases (office work, reporting, training)
- Modern Flutter makes multi-platform feasible
- Single codebase for all platforms

## Supported Platforms

### 1. Mobile (Primary)
- **iOS**: iPhone and iPad
- **Android**: Phones and tablets
- **Priority**: Highest - field engineers' primary platform
- **Features**: Full functionality including camera scanning

### 2. Web (Secondary)
- **Browsers**: Chrome, Edge, Safari, Firefox
- **Use Cases**: 
  - Office-based staff reviewing data
  - Training and demonstrations
  - Reporting and analytics
  - Backup when mobile unavailable
- **Limitations**: 
  - Camera scanning limited by browser capabilities
  - Use QR scanner library that works in browser or provide manual entry

### 3. Desktop (Secondary)
- **Windows**: Windows 10/11
- **macOS**: macOS 11+
- **Linux**: Ubuntu 20.04+ (optional)
- **Use Cases**:
  - Supervisors monitoring progress
  - Data analysis and reporting
  - Bulk operations
  - Training environments

## Responsive Design Strategy

### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;      // < 600px: phone
  static const double tablet = 900;      // 600-900px: tablet/small laptop
  static const double desktop = 1200;    // 900-1200px: laptop
  static const double wide = 1800;       // > 1200px: desktop/wide
}
```

### Layout Adaptations
```dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mobile) {
          return mobile;
        }
        if (constraints.maxWidth < Breakpoints.tablet) {
          return tablet ?? mobile;
        }
        return desktop ?? tablet ?? mobile;
      },
    );
  }
}
```

## Platform-Specific Features

### Camera/Scanner
```dart
class ScannerService {
  Future<String?> scan() async {
    if (kIsWeb) {
      // Web: Use browser-compatible QR scanner
      return _webQrScanner();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Desktop: Show file picker for QR image
      return _desktopQrFromImage();
    } else {
      // Mobile: Native camera scanner
      return _mobileCameraScanner();
    }
  }
  
  // Fallback: Manual entry dialog
  Future<String?> manualEntry() async {
    return _showManualEntryDialog();
  }
}
```

### Navigation
- **Mobile**: Bottom navigation bar, gestures
- **Tablet**: Side rail navigation
- **Desktop/Web**: Side panel navigation with collapsible menu

### Data Display
- **Mobile**: Single column lists, cards
- **Tablet**: 2-column layouts where appropriate
- **Desktop**: Multi-column, data tables, split views

## Web-Specific Considerations

### Deployment
```yaml
# Web deployment configuration
flutter build web --release --web-renderer canvaskit
```

### Hosting Options
1. **Static hosting**: AWS S3, Azure Blob, Google Cloud Storage
2. **CDN**: CloudFlare, AWS CloudFront
3. **Container**: Docker with nginx

### URL Strategy
```dart
// Use path URLs instead of hash
void main() {
  usePathUrlStrategy();
  runApp(MyApp());
}
```

### PWA Support
```json
// web/manifest.json
{
  "name": "RG Nets FDK",
  "short_name": "RG Nets",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#0175C2",
  "description": "Field Engineer Tool",
  "orientation": "portrait-primary"
}
```

## Desktop-Specific Considerations

### Window Management
```dart
// Desktop window configuration
void main() async {
  if (isDesktop) {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(800, 600),
      center: true,
      title: 'RG Nets Field Deployment Kit',
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  runApp(MyApp());
}
```

### Menu Bar (macOS/Linux)
```dart
// Platform-specific menu bar
if (Platform.isMacOS || Platform.isLinux) {
  setApplicationMenu([
    MenuItem(label: 'File', submenu: [
      MenuItem(label: 'Sync', onClicked: () => sync()),
      MenuItem(label: 'Settings', onClicked: () => openSettings()),
      MenuItem(type: 'separator'),
      MenuItem(label: 'Quit', onClicked: () => quit()),
    ]),
  ]);
}
```

### File System Access
```dart
// Desktop can access local file system
if (isDesktop) {
  // Export reports to local files
  final file = await FilePicker.platform.saveFile(
    dialogTitle: 'Export Report',
    fileName: 'room_readiness_report.csv',
  );
}
```

## Platform Detection

### Runtime Detection
```dart
class PlatformInfo {
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isWeb => kIsWeb;
  
  static bool get canUseCamera => isMobile || (isWeb && hasWebcam);
  static bool get canAccessFiles => isDesktop;
  static bool get supportsPushNotifications => isMobile;
  
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
```

## Testing Strategy by Platform

### Mobile Testing
- Physical devices for camera testing
- iOS Simulator and Android Emulator
- Different screen sizes (phone and tablet)

### Web Testing
- Multiple browsers (Chrome, Safari, Firefox, Edge)
- Different viewport sizes
- PWA installation testing
- Camera permissions testing

### Desktop Testing
- Windows 10 and 11
- macOS on Intel and Apple Silicon
- Linux (Ubuntu) if supported
- Window resizing and multi-monitor

## Performance Considerations

### Web Optimizations
- Lazy loading of routes
- Code splitting with deferred loading
- Service worker for offline support
- Compressed assets

### Desktop Optimizations
- Native performance generally good
- Consider memory usage for large datasets
- Efficient window rendering

## Accessibility

### All Platforms
- Keyboard navigation support
- Screen reader compatibility
- High contrast mode support
- Focus indicators

### Platform-Specific
- **Mobile**: VoiceOver (iOS), TalkBack (Android)
- **Web**: ARIA labels, semantic HTML
- **Desktop**: Native accessibility APIs

## Development Workflow

### Simultaneous Development
```bash
# Run on multiple platforms simultaneously
flutter run -d chrome  # Web
flutter run -d macos   # Desktop
flutter run -d iphone  # iOS
```

### Platform-Specific Code
```dart
// Use conditional imports for platform-specific implementations
import 'scanner_mobile.dart' if (dart.library.html) 'scanner_web.dart';
```

## Deployment Strategy

### Release Channels
1. **Mobile**: App Store, Google Play
2. **Web**: Hosted web app with auto-updates
3. **Desktop**: 
   - Windows: Microsoft Store or direct download
   - macOS: Mac App Store or direct download
   - Linux: Snap Store or AppImage

### Version Synchronization
- Keep all platforms on same version number
- Coordinate releases across platforms
- Feature parity where possible

## Benefits of Multi-Platform

1. **Flexibility**: Use best tool for the task
2. **Accessibility**: Reach users on their preferred platform
3. **Efficiency**: Single codebase to maintain
4. **Modern**: Leverages Flutter's multi-platform capabilities
5. **Cost-effective**: One team, multiple platforms

## Implementation Priority

### Phase 1 (MVP)
- Mobile (iOS and Android) - full features
- Web - view-only capabilities

### Phase 2
- Web - add manual data entry
- Desktop (Windows and macOS) - basic features

### Phase 3
- Full feature parity across platforms
- Platform-specific optimizations
- Linux support (if needed)