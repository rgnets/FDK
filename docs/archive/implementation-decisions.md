# Implementation Decisions - RG Nets FDK

**Created**: 2025-08-17
**Purpose**: Final decisions on implementation questions

## Data Loading & Pagination

### Decision: Background Async Loading
- **Approach**: Optimize for offline use with background loading
- **First Load**: Show loading indicator while fetching initial data
- **Subsequent Loads**: Background async with periodic refresh
- **Refresh Interval**: Automatic refresh in background
- **User Experience**: Seamless with cached data available

```dart
class DataLoadingStrategy {
  // First load - blocking with loading indicator
  Future<void> initialLoad() async {
    showLoadingIndicator();
    await fetchAllPages();
    hideLoadingIndicator();
  }
  
  // Background refresh - non-blocking
  void startBackgroundRefresh() {
    Timer.periodic(Duration(minutes: 30), (_) async {
      await fetchAllPagesInBackground();
    });
  }
}
```

## API Behavior

### No Rate Limiting
- **Confirmed**: No API throttling required
- **Implementation**: Make requests as needed without queuing

### PMS Rooms are Read-Only
- **Confirmed**: Cannot edit PMS rooms
- **Reason**: App is for technicians, not property management
- **Implementation**: Remove any edit/create room features

## Offline Cache Configuration

### Cache Duration: 12 Hours
- **TTL**: 12 hours for all cached data
- **Refresh**: Automatic background refresh when online
- **Expiry Handling**: Show stale indicator after 12 hours

### Cache Scope: Everything
- **Strategy**: Cache all viewed data
- **Offline Access**: All previously loaded data viewable offline
- **Storage**: SQLite for structured data, files for images

```dart
class CacheConfig {
  static const Duration cacheValidDuration = Duration(hours: 12);
  static const bool cacheAllData = true;
  
  bool isCacheValid(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) < cacheValidDuration;
  }
}
```

## Scanner Features

### No Manual Entry Fallback
- **Decision**: Scanner only, no manual serial/MAC entry
- **Reason**: Ensures data accuracy
- **Implementation**: Must scan barcodes

### No Batch Scanning
- **Decision**: Single device scanning only
- **Current Flow**: 6-second accumulation window per device
- **Implementation**: Process one device at a time

## UI/UX Decisions

### Dark Mode Support
- **Decision**: Yes, implement dark mode
- **Implementation**: System-aware with manual override
- **Themes**: Light and dark variants

```dart
class ThemeConfig {
  static ThemeData lightTheme = ThemeData.light();
  static ThemeData darkTheme = ThemeData.dark();
  
  static ThemeMode getThemeMode(UserPreference pref) {
    return switch(pref) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
```

### Tablet Support
- **Decision**: Yes, full tablet optimization
- **Implementation**: Responsive layouts
- **Breakpoints**: Phone (<600px), Tablet (600-900px), Desktop (>900px)

## Data Synchronization

### Conflict Resolution
- **Decision**: Server-side conflict resolution
- **App Behavior**: Always accept server's version
- **Implementation**: No client-side conflict UI needed

### Background Polling
- **Decision**: Yes, poll in background
- **Interval**: Every 30 seconds when app is active
- **Background**: Reduced frequency when backgrounded

```dart
class PollingService {
  Timer? _activeTimer;
  Timer? _backgroundTimer;
  
  void startActivePolling() {
    _activeTimer = Timer.periodic(Duration(seconds: 30), (_) {
      pollForUpdates();
    });
  }
  
  void switchToBackground() {
    _activeTimer?.cancel();
    _backgroundTimer = Timer.periodic(Duration(minutes: 5), (_) {
      pollForUpdates();
    });
  }
}
```

## Technical Choices

### Image Handling
- **Decision**: Use modern best practices
- **Caching**: CachedNetworkImage package
- **Format**: WebP where supported, fallback to JPEG
- **Optimization**: Multiple resolution variants

### Local Database
- **Decision**: Best modern choice for Flutter
- **Recommendation**: Isar (fast, Flutter-native)
- **Alternative**: SQLite with drift package
- **NoSQL Option**: Hive for simple key-value

```dart
// Isar - Modern, fast, Flutter-native
@collection
class CachedDevice {
  Id id = Isar.autoIncrement;
  late String deviceId;
  late String name;
  late DateTime cachedAt;
  late String jsonData;
}
```

## Compliance & Standards

### No PII/GDPR Requirements
- **Confirmed**: No personal data handling needed
- **Implementation**: No need for consent flows or data anonymization

### No WCAG Requirements
- **Confirmed**: WCAG compliance not required
- **Focus**: Good UX and responsive design instead

## Summary of Decisions

| Category | Decision | Impact |
|----------|----------|---------|
| **Pagination** | Background async loading | Better offline experience |
| **API Throttling** | None needed | Simpler implementation |
| **PMS Rooms** | Read-only | No edit UI needed |
| **Cache Duration** | 12 hours | Balance freshness/offline |
| **Cache Scope** | Everything | Full offline access |
| **Manual Entry** | Not supported | Ensures accuracy |
| **Batch Scanning** | Not supported | Simpler UX |
| **Dark Mode** | Supported | Modern UX |
| **Tablets** | Fully supported | Wider device support |
| **Conflicts** | Server-side | No conflict UI |
| **Background Poll** | Yes | Real-time updates |
| **Images** | Modern caching | Better performance |
| **Database** | Isar recommended | Fast, Flutter-native |
| **PII/GDPR** | Not required | Simpler compliance |
| **WCAG** | Not required | Focus on responsive |

## Implementation Priority

### High Priority
1. Background data loading with offline cache
2. 12-hour cache with SQLite/Isar
3. Responsive tablet layouts
4. Dark mode support

### Medium Priority
1. Background polling
2. Image caching optimization
3. Server conflict handling

### Low Priority
1. Cache expiry indicators
2. Offline mode badges
3. Polling frequency optimization

## Next Steps

With these decisions made, we can:
1. Finalize the technical architecture
2. Begin implementation with clear requirements
3. Avoid scope creep from undefined features