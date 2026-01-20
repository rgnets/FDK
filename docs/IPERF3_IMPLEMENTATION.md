# iPerf3 Speed Test Implementation

## Overview

This document describes the iPerf3 speed test implementation in the FDK (Field Development Kit) application. The system provides network performance measurement using native iPerf3 binaries on iOS and Android platforms.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Flutter (Dart)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────┐     ┌─────────────────────┐                       │
│  │   SpeedTestService  │────▶│    Iperf3Service    │                       │
│  │   (Orchestrator)    │     │   (Native Bridge)   │                       │
│  │                     │     │                     │                       │
│  │  • Test lifecycle   │     │  • MethodChannel    │                       │
│  │  • Server fallback  │     │  • EventChannel     │                       │
│  │  • Progress streams │     │  • JSON parsing     │                       │
│  └─────────────────────┘     └──────────┬──────────┘                       │
│                                         │                                   │
│  ┌─────────────────────┐                │                                   │
│  │ NetworkGatewayService│               │                                   │
│  │                     │                │                                   │
│  │  • Gateway detection│                │                                   │
│  │  • WiFi info        │                │                                   │
│  └─────────────────────┘                │                                   │
│                                         │                                   │
└─────────────────────────────────────────┼───────────────────────────────────┘
                                          │
                    MethodChannel: com.rgnets.fdk/iperf3
                    EventChannel:  com.rgnets.fdk/iperf3_progress
                                          │
┌─────────────────────────────────────────┼───────────────────────────────────┐
│                              Native Platform                                 │
├─────────────────────────────────────────┼───────────────────────────────────┤
│                                         │                                   │
│  ┌──────────────────────────────────────┴──────────────────────────────┐   │
│  │                        Platform Channel Handler                      │   │
│  │                                                                      │   │
│  │  iOS: Iperf3Plugin.swift                                            │   │
│  │  Android: Iperf3Plugin.kt                                           │   │
│  └──────────────────────────────────────┬──────────────────────────────┘   │
│                                         │                                   │
│  ┌──────────────────────────────────────┴──────────────────────────────┐   │
│  │                         iPerf3 Native Binary                         │   │
│  │                                                                      │   │
│  │  iOS: libiperf.a (static library)                                   │   │
│  │  Android: libiperf3.so (shared library per ABI)                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
lib/features/speed_test/
├── data/
│   ├── datasources/
│   │   ├── speed_test_data_source.dart           # Abstract interface
│   │   └── speed_test_websocket_data_source.dart # WebSocket implementation
│   ├── repositories/
│   │   └── speed_test_repository_impl.dart       # Repository implementation
│   └── services/
│       ├── iperf3_service.dart                   # Native bridge service
│       ├── speed_test_service.dart               # Main orchestrator
│       └── network_gateway_service.dart          # Network utilities
├── domain/
│   ├── entities/
│   │   ├── speed_test_config.dart                # Test configuration (Freezed)
│   │   ├── speed_test_result.dart                # Test result (Freezed)
│   │   ├── speed_test_with_results.dart          # Joined entity
│   │   └── speed_test_status.dart                # Status enum
│   └── repositories/
│       └── speed_test_repository.dart            # Repository interface
└── presentation/
    ├── providers/
    │   └── speed_test_providers.dart             # Riverpod providers
    └── widgets/
        ├── speed_test_card.dart                  # UI card widget
        └── speed_test_popup.dart                 # Test popup dialog
```

---

## Core Components

### 1. Iperf3Service (Native Bridge)

**File:** `lib/features/speed_test/data/services/iperf3_service.dart`

This service acts as a bridge between Flutter and the native iPerf3 implementation.

#### Platform Channels

```dart
static const MethodChannel _channel = MethodChannel('com.rgnets.fdk/iperf3');
static const EventChannel _progressChannel = EventChannel('com.rgnets.fdk/iperf3_progress');
```

#### Available Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `runClient()` | Execute speed test | host, port, duration, streams, reverse, useUdp, bandwidth |
| `startServer()` | Start iPerf3 server mode | port, useUdp |
| `stopServer()` | Stop running server | - |
| `cancelClient()` | Cancel running test | - |
| `getVersion()` | Get iPerf3 version | - |
| `getDefaultGateway()` | Get device gateway IP | - |
| `getGatewayForDestination()` | Get gateway for hostname | hostname |

#### runClient() Parameters

```dart
Future<Map<String, dynamic>> runClient({
  required String serverHost,    // Target server IP/hostname
  int port = 5201,               // iPerf3 port (default 5201)
  int durationSeconds = 10,      // Test duration per phase
  int parallelStreams = 1,       // Concurrent streams
  bool reverse = false,          // true=download, false=upload
  bool useUdp = true,            // UDP or TCP protocol
  int? bandwidthMbps,            // Bandwidth limit (UDP only)
})
```

#### Return Value Structure

```dart
{
  'success': bool,              // Test completed successfully
  'error': String?,             // Error message if failed

  // Speed measurements
  'sendMbps': double,           // Upload speed in Mbps
  'receiveMbps': double,        // Download speed in Mbps
  'sentBytes': int,             // Total bytes sent
  'receivedBytes': int,         // Total bytes received

  // Latency (protocol-dependent)
  'rtt': double,                // TCP: Round-trip time (ms)
  'jitter': double,             // UDP: Jitter (ms)

  // UDP-specific
  'lostPackets': int,           // Packets lost
  'totalPackets': int,          // Total packets
  'lostPercent': double,        // Packet loss percentage

  'jsonOutput': String,         // Raw iPerf3 JSON output
}
```

---

### 2. SpeedTestService (Orchestrator) - In Depth

**File:** `lib/features/speed_test/data/services/speed_test_service.dart`

The SpeedTestService is the main orchestrator that manages the complete speed test lifecycle. It coordinates between the native iPerf3 bridge, network gateway detection, and provides reactive streams for UI updates.

---

#### Singleton Pattern

The service uses a singleton pattern to ensure only one instance exists throughout the app lifecycle:

```dart
class SpeedTestService {
  // Private singleton instance
  static final SpeedTestService _instance = SpeedTestService._internal();

  // Factory constructor returns the singleton
  factory SpeedTestService() => _instance;

  // Private internal constructor
  SpeedTestService._internal();

  // Dependencies
  final Iperf3Service _iperf3Service = Iperf3Service();
  final NetworkGatewayService _gatewayService = NetworkGatewayService();
}
```

**Why Singleton?**
- Ensures consistent state across the app
- Prevents multiple simultaneous tests
- Maintains single connection to native layer
- Preserves configuration and last result

---

#### Internal State Management

The service maintains several pieces of internal state:

```dart
// ═══════════════════════════════════════════════════════════════════
// CONFIGURATION STATE (persisted to SharedPreferences)
// ═══════════════════════════════════════════════════════════════════
String _serverHost = '';           // Current/last tested server
String _serverLabel = '';          // Human-readable server name
int _serverPort = 5201;            // iPerf3 port
int _testDuration = 10;            // Seconds per phase
bool _useUdp = true;               // Protocol selection
int _bandwidthMbps = 81;           // UDP bandwidth limit
int _parallelStreams = 16;         // Concurrent streams

// ═══════════════════════════════════════════════════════════════════
// RUNTIME STATE (not persisted)
// ═══════════════════════════════════════════════════════════════════
SpeedTestStatus _status = SpeedTestStatus.idle;  // Current status
SpeedTestResult? _lastResult;                     // Most recent result
double _progress = 0.0;                           // 0-100%

// Phase tracking for live updates
bool _isDownloadPhase = true;                     // Which phase active
bool _isRetryingFallback = false;                 // Suppress errors during retry

// Speed preservation across phases
double _completedDownloadSpeed = 0.0;             // After download completes
double _completedUploadSpeed = 0.0;               // After upload completes
```

---

#### Default Configuration

| Parameter | Default | Description | Why This Value |
|-----------|---------|-------------|----------------|
| `serverPort` | 5201 | Standard iPerf3 port | Industry standard |
| `testDuration` | 10 sec | Duration per test phase | Balance of accuracy vs time |
| `useUdp` | true | UDP protocol | More accurate for WiFi |
| `bandwidthMbps` | 81 | Target bandwidth | Prevents network saturation |
| `parallelStreams` | 16 | Concurrent streams | Maximizes throughput measurement |

---

#### Reactive Streams Architecture

The service exposes four broadcast streams for UI reactivity:

```dart
// ═══════════════════════════════════════════════════════════════════
// STREAM CONTROLLERS (broadcast = multiple listeners allowed)
// ═══════════════════════════════════════════════════════════════════

final StreamController<SpeedTestStatus> _statusController =
    StreamController<SpeedTestStatus>.broadcast();

final StreamController<SpeedTestResult> _resultController =
    StreamController<SpeedTestResult>.broadcast();

final StreamController<double> _progressController =
    StreamController<double>.broadcast();

final StreamController<String> _statusMessageController =
    StreamController<String>.broadcast();

// ═══════════════════════════════════════════════════════════════════
// PUBLIC STREAM GETTERS
// ═══════════════════════════════════════════════════════════════════

// Status: idle → running → completed/error
Stream<SpeedTestStatus> get statusStream => _statusController.stream;

// Results: emits live updates DURING test + final result
Stream<SpeedTestResult> get resultStream => _resultController.stream;

// Progress: 0.0 to 100.0 percentage
Stream<double> get progressStream => _progressController.stream;

// Messages: "Testing download speed...", "Connected to gateway", etc.
Stream<String> get statusMessageStream => _statusMessageController.stream;
```

**Stream Data Flow:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Native iPerf3 Progress                          │
│                                                                     │
│  EventChannel: com.rgnets.fdk/iperf3_progress                      │
│  Emits: { status, interval, mbps, details }                        │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   _progressSubscription.listen()                    │
│                                                                     │
│  Receives native events and routes to appropriate handler          │
└─────────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                ▼                               ▼
┌───────────────────────────┐   ┌───────────────────────────┐
│   _handleStatusUpdate()   │   │  _handleProgressUpdate()  │
│                           │   │                           │
│  • Updates _status        │   │  • Calculates progress %  │
│  • Emits status stream    │   │  • Emits progress stream  │
│  • Emits message stream   │   │  • Creates live result    │
│  • Handles errors         │   │  • Emits result stream    │
└───────────────────────────┘   └───────────────────────────┘
                │                               │
                ▼                               ▼
        ┌───────────┐                   ┌───────────┐
        │    UI     │                   │    UI     │
        │  Widgets  │                   │  Widgets  │
        └───────────┘                   └───────────┘
```

---

#### Initialization Process

```dart
Future<void> initialize() async {
  // 1. Get SharedPreferences instance
  _prefs = await SharedPreferences.getInstance();

  // 2. Load saved configuration
  await _loadConfiguration();

  // 3. Override with optimal defaults (UDP, 16 streams, 81 Mbps)
  _useUdp = true;
  _parallelStreams = 16;
  _bandwidthMbps = 81;

  // 4. Save the configuration
  await _saveConfiguration();

  // 5. Load last result (for UI display on app start)
  await _loadLastResult();

  // 6. Subscribe to native progress stream
  _progressSubscription = _iperf3Service.getProgressStream().listen((progress) {
    final status = progress['status'];
    if (status != null && status is String) {
      _handleStatusUpdate(status, progress['details']);
    } else {
      _handleProgressUpdate(progress);
    }
  });
}
```

---

#### Test Execution Flow (Detailed)

```
┌─────────────────────────────────────────────────────────────────────┐
│                   runSpeedTestWithFallback()                        │
│                                                                     │
│  Entry point for running a speed test with automatic retry         │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 1: Guard Against Concurrent Tests                             │
│                                                                     │
│  if (_status == SpeedTestStatus.running) {                         │
│    LoggerService.warning('Speed test already running');            │
│    return;  // Don't start another test                            │
│  }                                                                  │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 2: Initialize Test State                                      │
│                                                                     │
│  _updateStatus(SpeedTestStatus.running);  // Notify UI             │
│  _progress = 0.0;                                                   │
│  _progressController.add(_progress);                                │
│  _isRetryingFallback = true;              // Suppress errors       │
│  _completedDownloadSpeed = 0.0;           // Reset from last test  │
│  _completedUploadSpeed = 0.0;                                       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 3: Get Local IP Address                                       │
│                                                                     │
│  final localIp = await _getLocalIpAddress();                       │
��                                                                     │
│  // Iterates through network interfaces                             │
│  // Returns first non-loopback IPv4 address                        │
│  // Used to identify device in results                              │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 4: Build Fallback Server List                                 │
│                                                                     │
│  final fallbackServers = await _buildFallbackList(configTarget);   │
│                                                                     │
│  Priority Order:                                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 1. Default Gateway (e.g., 192.168.1.1)                      │   │
│  │    - Detected via NetworkGatewayService                     │   │
│  │    - Fastest, tests local network                           │   │
│  │    - Requires iPerf3 server running on gateway              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │ 2. Config Target (from SpeedTestConfig.target)              │   │
│  │    - Only added if different from gateway                   │   │
│  │    - May be external server hostname/IP                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 5: Server Iteration Loop                                      │
│                                                                     │
│  for (int i = 0; i < fallbackServers.length; i++) {                │
│    final serverHost = fallbackServers[i]['host'];                  │
│    final serverLabel = fallbackServers[i]['label'];                │
│                                                                     │
│    // Show progress to user                                         │
│    _statusMessageController.add(                                    │
│      'Attempt ${i+1}/${fallbackServers.length}: $serverLabel'      │
│    );                                                               │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 6: Run Test With Server (_runTestWithServer)                  │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  PHASE 1: DOWNLOAD TEST                                       │ │
│  │                                                               │ │
│  │  _isDownloadPhase = true;                                     │ │
│  │                                                               │ │
│  │  downloadResult = await _iperf3Service.runClient(             │ │
│  │    serverHost: serverHost,                                    │ │
│  │    port: 5201,                                                │ │
│  │    durationSeconds: 10,                                       │ │
│  │    parallelStreams: 16,                                       │ │
│  │    reverse: true,        // Server → Client = DOWNLOAD        │ │
│  │    useUdp: true,                                              │ │
│  │    bandwidthMbps: 81,                                         │ │
│  │  );                                                           │ │
│  │                                                               │ │
│  │  if (!success) return null;  // Try next server               │ │
│  │                                                               │ │
│  │  _completedDownloadSpeed = downloadResult['receiveMbps'];     │ │
│  │  latency = downloadResult['jitter'];  // or 'rtt' for TCP     │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                              │                                      │
│                              ▼                                      │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  PHASE 2: UPLOAD TEST                                         │ │
│  │                                                               │ │
│  │  _isDownloadPhase = false;                                    │ │
│  │                                                               │ │
│  │  uploadResult = await _iperf3Service.runClient(               │ │
│  │    serverHost: serverHost,                                    │ │
│  │    port: 5201,                                                │ │
│  │    durationSeconds: 10,                                       │ │
│  │    parallelStreams: 16,                                       │ │
│  │    reverse: false,       // Client → Server = UPLOAD          │ │
│  │    useUdp: true,                                              │ │
│  │    bandwidthMbps: 81,                                         │ │
│  │  );                                                           │ │
│  │                                                               │ │
│  │  if (!success) return null;  // Try next server               │ │
│  │                                                               │ │
│  │  uploadSpeed = uploadResult['sendMbps'];                      │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                              │                                      │
│                              ▼                                      │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  CREATE RESULT                                                │ │
│  │                                                               │ │
│  │  return SpeedTestResult(                                      │ │
│  │    downloadMbps: downloadSpeed,                               │ │
│  │    uploadMbps: uploadSpeed,                                   │ │
│  │    rtt: latency,                                              │ │
│  │    completedAt: DateTime.now(),                               │ │
│  │    localIpAddress: localIp,                                   │ │
│  │    serverHost: serverHost,                                    │ │
│  │  );                                                           │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
            ┌───────────┐           ┌───────────────┐
            │  Success  │           │    Failed     │
            │           │           │               │
            │  result   │           │  result ==    │
            │  != null  │           │  null         │
            └─────┬─────┘           └───────┬───────┘
                  │                         │
                  ▼                         ▼
┌─────────────────────────────┐   ┌─────────────────────────────┐
│  STEP 7A: Success Path      │   │  STEP 7B: Failure Path      │
│                             │   │                             │
│  _isRetryingFallback=false; │   │  if (more servers left) {   │
│  _lastResult = result;      │   │    // 1 second pause        │
│  _resultController.add();   │   │    await Future.delayed();  │
│  _updateStatus(completed);  │   │    continue;  // Try next   │
│  _saveLastResult(result);   │   │  } else {                   │
│  return;  // Exit loop      │   │    _setErrorResult(         │
│                             │   │      'Unable to connect'    │
│                             │   │    );                       │
│                             │   │  }                          │
└─────────────────────────────┘   └─────────────────────────────┘
```

---

#### Live Progress Updates

During test execution, the native layer sends progress events that are processed to provide real-time UI updates:

```dart
void _handleProgressUpdate(Map<String, dynamic> progress) {
  final interval = progress['interval'] as int?;   // Current second
  final speedMbps = progress['mbps'] as double?;   // Current speed

  if (interval != null && _testDuration > 0) {
    // Calculate percentage (0-100)
    _progress = (interval / _testDuration * 100).clamp(0.0, 100.0);
    _progressController.add(_progress);

    // Emit live result for UI updates
    if (speedMbps != null && speedMbps > 0) {
      final liveResult = SpeedTestResult(
        // During download: show live download, no upload yet
        // During upload: preserve completed download, show live upload
        downloadMbps: _isDownloadPhase ? speedMbps : _completedDownloadSpeed,
        uploadMbps: !_isDownloadPhase ? speedMbps : _completedUploadSpeed,
        rtt: 0.0,
        completedAt: DateTime.now(),
      );

      _resultController.add(liveResult);
    }
  }
}
```

**Visual Timeline:**

```
Download Phase (10 seconds)                Upload Phase (10 seconds)
├──────────────────────────────────────────┼──────────────────────────────────────────┤
│  sec 1: emit(down: 45.2, up: 0)          │  sec 1: emit(down: 95.5, up: 12.3)       │
│  sec 2: emit(down: 67.8, up: 0)          │  sec 2: emit(down: 95.5, up: 28.7)       │
│  sec 3: emit(down: 82.1, up: 0)          │  sec 3: emit(down: 95.5, up: 35.4)       │
│  ...                                     │  ...                                     │
│  sec 10: _completedDownloadSpeed = 95.5  │  sec 10: FINAL RESULT                    │
│          switch to upload phase          │          down: 95.5, up: 42.3            │
└──────────────────────────────────────────┴──────────────────────────────────────────┘
```

---

#### Status Message Generation

Human-readable messages are generated based on the current state:

```dart
void _handleStatusUpdate(String status, dynamic details) {
  String getMessage() {
    final serverInfo = _serverHost.isNotEmpty ? ' to $_serverHost' : '';

    switch (status) {
      case 'starting':
        return 'Starting speed test...';

      case 'running':
        if (_isDownloadPhase) {
          return 'Testing download speed$serverInfo...';
        } else {
          return 'Testing upload speed$serverInfo...';
        }

      case 'completed':
        return 'Test completed!';

      case 'cancelled':
        return 'Test cancelled';

      case 'error':
        final message = (details is Map && details['message'] != null)
            ? details['message'].toString()
            : 'Speed test failed';
        return 'Error: $message';

      case 'idle':
        return 'Ready';

      default:
        return 'Performing speed test$serverInfo...';
    }
  }

  _statusMessageController.add(getMessage());
}
```

---

#### Persistence (SharedPreferences)

Configuration and last result are persisted for app restarts:

```dart
// ═══════════════════════════════════════════════════════════════════
// KEYS USED IN SHARED PREFERENCES
// ═══════════════════════════════════════════════════════════════════
// 'speed_test_server_host'      → String
// 'speed_test_server_port'      → int
// 'speed_test_duration'         → int
// 'speed_test_use_udp'          → bool
// 'speed_test_bandwidth_mbps'   → int
// 'speed_test_parallel_streams' → int
// 'speed_test_last_result'      → String (JSON)

Future<void> _saveLastResult(SpeedTestResult result) async {
  // Use compute() for JSON encoding on isolate (prevents UI jank)
  final json = await compute(_encodeJson, result.toJson());
  await _prefs?.setString('speed_test_last_result', json);
}

Future<void> _loadLastResult() async {
  final resultJson = _prefs?.getString('speed_test_last_result');
  if (resultJson != null) {
    // Parse on isolate
    final map = Map<String, dynamic>.from(
      await compute(_parseJson, resultJson),
    );
    _lastResult = SpeedTestResult.fromJson(map);
  }
}
```

---

#### Error Handling Strategy

```dart
// During fallback retry, errors are suppressed to avoid confusing the user
if (!_isRetryingFallback) {
  _updateStatus(SpeedTestStatus.error);
  _statusMessageController.add('Error: $message');
  _setErrorResult(message);
}

// Error result factory
void _setErrorResult(String message) {
  final result = SpeedTestResult.error(message);  // hasError=true, passed=false
  _lastResult = result;
  _resultController.add(result);
  _updateStatus(SpeedTestStatus.error);
}
```

**User Experience:**
- During fallback: User sees "Trying gateway...", "Trying test configuration..."
- Only after ALL servers fail: User sees "Unable to connect to server"
- No confusing intermediate error messages

---

#### Cleanup

```dart
void dispose() {
  _progressSubscription?.cancel();  // Stop listening to native events
  _statusController.close();        // Close all stream controllers
  _resultController.close();
  _progressController.close();
  _statusMessageController.close();
}
```

---

## Submitting Results & Fetching Configurations

This section explains how speed test results are submitted to the server and how configurations are retrieved.

### Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         1. FETCH CONFIGURATIONS                              │
│                                                                             │
│   UI Widget                                                                 │
│      │                                                                      │
│      │ ref.watch(speedTestConfigsNotifierProvider)                         │
│      ▼                                                                      │
│   SpeedTestConfigsNotifier                                                  │
│      │                                                                      │
│      │ repository.getSpeedTestConfigs()                                    │
│      ▼                                                                      │
│   SpeedTestRepositoryImpl                                                   │
│      │                                                                      │
│      │ dataSource.getSpeedTestConfigs()                                    │
│      ▼                                                                      │
│   SpeedTestWebSocketDataSource                                              │
│      │                                                                      │
│      │ webSocketService.requestActionCable(                                │
│      │   action: 'index',                                                  │
│      │   resourceType: 'speed_tests'                                       │
│      │ )                                                                    │
│      ▼                                                                      │
│   Rails Server                                                              │
│      │                                                                      │
│      │ Returns: { data: [ {id: 1, name: "Office", target: "192.168.1.1",   │
│      │                     min_download_mbps: 50, ...}, ... ] }            │
│      ▼                                                                      │
│   List<SpeedTestConfig>                                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         2. RUN SPEED TEST                                    │
│                                                                             │
│   User taps "Run Test" button                                               │
│      │                                                                      │
│      │ speedTestService.runSpeedTestWithFallback(                          │
│      │   configTarget: config.target  // e.g., "192.168.1.1"               │
│      │ )                                                                    │
│      ▼                                                                      │
│   SpeedTestService runs iPerf3 test                                         │
│      │                                                                      │
│      │ Download test (reverse=true) → Upload test (reverse=false)          │
│      ▼                                                                      │
│   SpeedTestResult created locally                                           │
│   (downloadMbps: 95.5, uploadMbps: 42.3, rtt: 12.5, ...)                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         3. SUBMIT RESULT TO SERVER                           │
│                                                                             │
│   UI receives result from speedTestService.resultStream                     │
│      │                                                                      │
│      │ // Add the speed_test_id to link result to config                   │
│      │ final resultToSave = result.copyWith(speedTestId: config.id);       │
│      │                                                                      │
│      │ ref.read(speedTestResultsNotifierProvider.notifier)                 │
│      │   .createResult(resultToSave);                                      │
│      ▼                                                                      │
│   SpeedTestResultsNotifier                                                  │
│      │                                                                      │
│      │ repository.createSpeedTestResult(result)                            │
│      ▼                                                                      │
│   SpeedTestRepositoryImpl                                                   │
│      │                                                                      │
│      │ dataSource.createSpeedTestResult(result)                            │
│      ▼                                                                      │
│   SpeedTestWebSocketDataSource                                              │
│      │                                                                      │
│      │ webSocketService.requestActionCable(                                │
│      │   action: 'create',                                                 │
│      │   resourceType: 'speed_test_results',                               │
│      │   additionalData: result.toJson()                                   │
│      │ )                                                                    │
│      ▼                                                                      │
│   Rails Server                                                              │
│      │                                                                      │
│      │ Creates record in speed_test_results table                          │
│      │ Returns: { data: { id: 456, speed_test_id: 123, ... } }            │
│      ▼                                                                      │
│   SpeedTestResult (with server-assigned id)                                 │
└─────────���───────────────────────────────────────────────────────────────────┘
```

---

### Fetching Speed Test Configurations

Configurations define HOW a speed test should be run and what thresholds determine pass/fail.

#### Provider Usage

```dart
// In your widget
class SpeedTestScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all configurations
    final configsAsync = ref.watch(speedTestConfigsNotifierProvider);

    return configsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (configs) {
        return ListView.builder(
          itemCount: configs.length,
          itemBuilder: (context, index) {
            final config = configs[index];
            return ListTile(
              title: Text(config.name ?? 'Unnamed Test'),
              subtitle: Text('Target: ${config.target}'),
              trailing: Text(config.passing ? '✓ Pass' : '✗ Fail'),
              onTap: () => _runTest(ref, config),
            );
          },
        );
      },
    );
  }
}
```

#### Data Source Implementation

```dart
// In SpeedTestWebSocketDataSource

@override
Future<List<SpeedTestConfig>> getSpeedTestConfigs() async {
  if (!_webSocketService.isConnected) {
    return [];
  }

  final response = await _webSocketService.requestActionCable(
    action: 'index',
    resourceType: 'speed_tests',  // Maps to SpeedTest model in Rails
  );

  final data = response.payload['data'];
  if (data is List) {
    return data
        .map((json) => SpeedTestConfig.fromJson(
              Map<String, dynamic>.from(json as Map),
            ))
        .toList();
  }

  return [];
}
```

#### SpeedTestConfig Entity

```dart
@freezed
class SpeedTestConfig with _$SpeedTestConfig {
  const factory SpeedTestConfig({
    int? id,
    String? name,                              // "Office WiFi Test"
    @JsonKey(name: 'test_type') String? testType,  // "iperf3"
    String? target,                            // "192.168.1.1" - server to test against
    int? port,                                 // 5201
    @JsonKey(name: 'iperf_protocol') String? iperfProtocol,  // "udp" or "tcp"
    @JsonKey(name: 'min_download_mbps') double? minDownloadMbps,  // 50.0
    @JsonKey(name: 'min_upload_mbps') double? minUploadMbps,      // 25.0
    int? period,                               // 60 (run every 60...)
    @JsonKey(name: 'period_unit') String? periodUnit,  // "minutes"
    @JsonKey(name: 'starts_at') DateTime? startsAt,
    @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
    @Default(false) bool passing,              // Current pass/fail status
    // ... more fields
  }) = _SpeedTestConfig;
}
```

---

### Submitting Speed Test Results

After running a test, the result must be submitted to the server with the correct `speed_test_id`.

#### Step-by-Step Process

```dart
// 1. User selects a config and runs test
Future<void> _runTest(WidgetRef ref, SpeedTestConfig config) async {
  final speedTestService = SpeedTestService();

  // 2. Run the test with the config's target server
  await speedTestService.runSpeedTestWithFallback(
    configTarget: config.target,  // Use config's target as fallback server
  );
}

// 3. Listen to results and submit
void _setupResultListener(WidgetRef ref, SpeedTestConfig config) {
  final speedTestService = SpeedTestService();

  speedTestService.resultStream.listen((result) {
    // Only submit final results (not live updates)
    if (result.hasError) {
      // Handle error - don't submit
      return;
    }

    // 4. Add the speed_test_id to link this result to the config
    final resultToSubmit = SpeedTestResult(
      speedTestId: config.id,           // CRITICAL: Links result to config
      downloadMbps: result.downloadMbps,
      uploadMbps: result.uploadMbps,
      rtt: result.rtt,
      jitter: result.jitter,
      passed: _checkIfPassed(result, config),  // Determine pass/fail
      completedAt: DateTime.now(),
      localIpAddress: result.localIpAddress,
      serverHost: result.serverHost,
    );

    // 5. Submit to server via provider
    ref.read(speedTestResultsNotifierProvider.notifier)
        .createResult(resultToSubmit);
  });
}

// Helper to determine pass/fail based on config thresholds
bool _checkIfPassed(SpeedTestResult result, SpeedTestConfig config) {
  final downloadOk = config.minDownloadMbps == null ||
      (result.downloadMbps ?? 0) >= config.minDownloadMbps!;

  final uploadOk = config.minUploadMbps == null ||
      (result.uploadMbps ?? 0) >= config.minUploadMbps!;

  return downloadOk && uploadOk;
}
```

#### Data Source Create Implementation

```dart
// In SpeedTestWebSocketDataSource

@override
Future<SpeedTestResult> createSpeedTestResult(SpeedTestResult result) async {
  if (!_webSocketService.isConnected) {
    throw StateError('WebSocket not connected');
  }

  final response = await _webSocketService.requestActionCable(
    action: 'create',
    resourceType: 'speed_test_results',
    additionalData: result.toJson(),  // Includes speed_test_id
  );

  final data = response.payload['data'];
  if (data != null) {
    // Use validation to fix any swapped speeds in response
    return SpeedTestResult.fromJsonWithValidation(
      Map<String, dynamic>.from(data as Map),
    );
  }

  throw Exception(
    response.payload['error']?.toString() ?? 'Failed to create result',
  );
}
```

#### JSON Payload Sent to Server

```json
{
  "command": "message",
  "identifier": "{\"channel\":\"ResourceChannel\"}",
  "data": "{
    \"action\": \"create\",
    \"resource_type\": \"speed_test_results\",
    \"speed_test_id\": 123,
    \"download_mbps\": 95.5,
    \"upload_mbps\": 42.3,
    \"rtt\": 12.5,
    \"jitter\": 2.1,
    \"passed\": true,
    \"completed_at\": \"2024-01-15T10:30:00.000Z\",
    \"local_ip_address\": \"192.168.1.100\",
    \"server_host\": \"192.168.1.1\"
  }"
}
```

---

### Getting Configs with Their Results (Joined)

To display a config along with its test history, use the joined entity:

```dart
// Get a single config with all its results
final configWithResults = ref.watch(
  speedTestWithResultsNotifierProvider(configId),
);

configWithResults.when(
  data: (joined) {
    print('Config: ${joined.config.name}');
    print('Total Results: ${joined.resultCount}');
    print('Pass Rate: ${joined.passRate}%');
    print('Latest Speed: ${joined.latestResult?.downloadMbps} Mbps');
    print('Currently Passing: ${joined.isCurrentlyPassing}');
    print('Meets Download Req: ${joined.meetsDownloadRequirement}');
  },
  loading: () => ...,
  error: (e, _) => ...,
);

// Or get ALL configs with their results
final allTests = ref.watch(allSpeedTestsWithResultsNotifierProvider);

allTests.when(
  data: (tests) {
    for (final test in tests) {
      print('${test.config.name}: ${test.passRate}% pass rate');
    }
  },
  // ...
);
```

#### Repository Implementation

```dart
// In SpeedTestRepositoryImpl

@override
Future<Either<Failure, SpeedTestWithResults>> getSpeedTestWithResults(
  int configId,
) async {
  try {
    // 1. Fetch the config
    final config = await _dataSource.getSpeedTestConfig(configId);

    // 2. Fetch results WHERE speed_test_id = configId
    final results = await _dataSource.getSpeedTestResults(
      speedTestId: configId,
    );

    // 3. Join them into a single entity
    return Right(SpeedTestWithResults(
      config: config,
      results: results,
    ));
  } catch (e) {
    return Left(ServerFailure('Failed to load speed test: $e'));
  }
}

@override
Future<Either<Failure, List<SpeedTestWithResults>>> getAllSpeedTestsWithResults() async {
  try {
    // 1. Fetch all configs
    final configs = await _dataSource.getSpeedTestConfigs();

    // 2. Fetch ALL results
    final allResults = await _dataSource.getSpeedTestResults();

    // 3. Group results by speed_test_id
    final resultsByConfigId = <int, List<SpeedTestResult>>{};
    for (final result in allResults) {
      if (result.speedTestId != null) {
        resultsByConfigId
            .putIfAbsent(result.speedTestId!, () => [])
            .add(result);
      }
    }

    // 4. Join each config with its results
    final joined = configs.map((config) {
      return SpeedTestWithResults(
        config: config,
        results: resultsByConfigId[config.id] ?? [],
      );
    }).toList();

    return Right(joined);
  } catch (e) {
    return Left(ServerFailure('Failed to load speed tests: $e'));
  }
}
```

---

### Complete Usage Example

```dart
class SpeedTestWidget extends ConsumerStatefulWidget {
  final SpeedTestConfig config;

  @override
  ConsumerState<SpeedTestWidget> createState() => _SpeedTestWidgetState();
}

class _SpeedTestWidgetState extends ConsumerState<SpeedTestWidget> {
  final _speedTestService = SpeedTestService();
  StreamSubscription? _resultSubscription;

  @override
  void initState() {
    super.initState();
    _setupResultListener();
  }

  void _setupResultListener() {
    _resultSubscription = _speedTestService.resultStream.listen((result) {
      // Check if this is a final result (not live update)
      if (!result.hasError && _speedTestService.status == SpeedTestStatus.completed) {
        _submitResult(result);
      }
    });
  }

  Future<void> _submitResult(SpeedTestResult result) async {
    // Create result with speed_test_id linking to config
    final resultToSubmit = result.copyWith(
      speedTestId: widget.config.id,
      passed: _checkPassed(result),
    );

    // Submit via Riverpod
    final saved = await ref
        .read(speedTestResultsNotifierProvider.notifier)
        .createResult(resultToSubmit);

    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Result saved! ID: ${saved.id}')),
      );

      // Refresh the joined data
      ref.invalidate(speedTestWithResultsNotifierProvider(widget.config.id!));
    }
  }

  bool _checkPassed(SpeedTestResult result) {
    final minDown = widget.config.minDownloadMbps ?? 0;
    final minUp = widget.config.minUploadMbps ?? 0;

    return (result.downloadMbps ?? 0) >= minDown &&
           (result.uploadMbps ?? 0) >= minUp;
  }

  Future<void> _runTest() async {
    await _speedTestService.runSpeedTestWithFallback(
      configTarget: widget.config.target,
    );
  }

  @override
  void dispose() {
    _resultSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SpeedTestStatus>(
      stream: _speedTestService.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SpeedTestStatus.idle;

        return Column(
          children: [
            Text('Config: ${widget.config.name}'),
            Text('Min Download: ${widget.config.minDownloadMbps} Mbps'),
            Text('Min Upload: ${widget.config.minUploadMbps} Mbps'),

            ElevatedButton(
              onPressed: status == SpeedTestStatus.running ? null : _runTest,
              child: Text(status == SpeedTestStatus.running
                  ? 'Testing...'
                  : 'Run Test'),
            ),

            // Show live results
            StreamBuilder<SpeedTestResult>(
              stream: _speedTestService.resultStream,
              builder: (context, resultSnapshot) {
                final result = resultSnapshot.data;
                if (result == null) return SizedBox.shrink();

                return Column(
                  children: [
                    Text('Download: ${result.formattedDownloadSpeed}'),
                    Text('Upload: ${result.formattedUploadSpeed}'),
                    Text('Latency: ${result.formattedRtt}'),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
```

---

### 3. NetworkGatewayService

**File:** `lib/features/speed_test/data/services/network_gateway_service.dart`

Handles network detection and gateway resolution.

#### Gateway Detection

**iOS:**
```dart
// Uses native getDefaultGateway() - reads system routing table
final gateway = await _iperf3Service.getDefaultGateway();
```

**Android:**
```dart
// Calculates from WiFi IP and subnet mask
final wifiIP = await _networkInfo.getWifiIP();        // e.g., 192.168.1.100
final subnetMask = await _networkInfo.getWifiSubmask(); // e.g., 255.255.255.0

// Network = IP & Mask = 192.168.1.0
// Gateway = Network + 1 = 192.168.1.1
```

---

## Protocol Comparison

### TCP vs UDP

| Feature | TCP | UDP |
|---------|-----|-----|
| **Latency Metric** | RTT (Round Trip Time) | Jitter |
| **Bandwidth Limit** | Not used | Required (81 Mbps default) |
| **Packet Loss** | Retransmitted | Measured |
| **Accuracy** | Higher for wired | Better for WiFi |
| **Default** | No | Yes |

### Why UDP is Default

1. **WiFi Performance**: TCP retransmissions can mask real WiFi issues
2. **Accurate Throughput**: Measures actual channel capacity
3. **Latency Metrics**: Jitter is more relevant for WiFi quality
4. **Bandwidth Control**: Prevents network saturation

---

## iPerf3 JSON Output Parsing

### TCP Response Structure

```json
{
  "end": {
    "sum_sent": {
      "bits_per_second": 94500000,
      "bytes": 118125000
    },
    "sum_received": {
      "bits_per_second": 94200000,
      "bytes": 117750000
    },
    "streams": [{
      "sender": {
        "mean_rtt": 12500  // microseconds
      }
    }]
  }
}
```

### UDP Response Structure

```json
{
  "end": {
    "sum": {
      "jitter_ms": 2.5,
      "lost_packets": 3,
      "packets": 10000,
      "lost_percent": 0.03
    },
    "sum_received": {
      "bits_per_second": 81000000,
      "bytes": 101250000
    }
  }
}
```

### Reverse Mode Logic

```dart
// Download Test (reverse=true): Server → Client
// sum_received = what client received FROM server = DOWNLOAD speed

// Upload Test (reverse=false): Client → Server
// sum_received = what server received FROM client = UPLOAD speed
```

---

## Data Persistence

### SpeedTestResult Entity

```dart
@freezed
class SpeedTestResult with _$SpeedTestResult {
  const factory SpeedTestResult({
    int? id,
    @JsonKey(name: 'speed_test_id') int? speedTestId,  // FK to config
    @JsonKey(name: 'download_mbps') double? downloadMbps,
    @JsonKey(name: 'upload_mbps') double? uploadMbps,
    double? rtt,
    double? jitter,
    @JsonKey(name: 'packet_loss') double? packetLoss,
    @Default(false) bool passed,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    // ... additional fields
  }) = _SpeedTestResult;
}
```

### Speed Swap Validation

The system automatically detects and corrects swapped download/upload values:

```dart
static SpeedTestResult fromJsonWithValidation(Map<String, dynamic> json) {
  final processedJson = _preprocessJson(json);
  return _$SpeedTestResultFromJson(processedJson);
}

// Heuristics:
// 1. Download < 5 Mbps AND Upload > 50 Mbps → Swap
// 2. Upload > Download × 10 → Swap
```

---

## Server Fallback Strategy

### Priority Order

1. **Default Gateway** (e.g., 192.168.1.1)
   - Fastest response time
   - Tests local network performance
   - Requires iPerf3 server on gateway

2. **Test Configuration Target**
   - From `SpeedTestConfig.target`
   - Configured per deployment
   - May be external server

### Fallback Behavior

```
Attempt 1: Default Gateway (192.168.1.1)
    │
    ├── Success → Return Result
    │
    └── Fail → "Trying test configuration..."
              │
              ▼
Attempt 2: Config Target (speedtest.example.com)
    │
    ├── Success → Return Result
    │
    └── Fail → "Unable to connect to server"
```

---

## Usage Examples

### Basic Speed Test

```dart
final speedTestService = SpeedTestService();
await speedTestService.initialize();

// Listen to results
speedTestService.resultStream.listen((result) {
  print('Download: ${result.downloadMbps} Mbps');
  print('Upload: ${result.uploadMbps} Mbps');
  print('Latency: ${result.rtt} ms');
});

// Run test with automatic fallback
await speedTestService.runSpeedTestWithFallback();
```

### With Riverpod Providers

```dart
// Watch all configs with results
final speedTests = ref.watch(allSpeedTestsWithResultsNotifierProvider);

speedTests.when(
  data: (tests) {
    for (final test in tests) {
      print('Config: ${test.config.name}');
      print('Latest: ${test.latestResult?.downloadMbps} Mbps');
      print('Pass Rate: ${test.passRate}%');
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

### Save Result to Server

```dart
final result = SpeedTestResult(
  speedTestId: config.id,
  downloadMbps: 95.5,
  uploadMbps: 42.3,
  rtt: 12.5,
  passed: true,
  completedAt: DateTime.now(),
);

await ref.read(speedTestResultsNotifierProvider.notifier).createResult(result);
```

---

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Connection refused" | No iPerf3 server | Check server is running |
| "Network unreachable" | No network | Check WiFi/cellular |
| "Timeout" | Server not responding | Try different server |
| "Busy" | Server in use | Wait and retry |

### Error Result Factory

```dart
factory SpeedTestResult.error(String message) {
  return SpeedTestResult(
    hasError: true,
    errorMessage: message,
    passed: false,
  );
}
```

---

## Native Implementation Notes

### iOS

- **Library**: `libiperf.a` (static library)
- **Integration**: Linked via Xcode project
- **Gateway Detection**: Uses system routing table (`SCNetworkReachability`)
- **Permissions**: None required for speed test

### Android

- **Library**: `libiperf3.so` (shared library)
- **ABIs**: arm64-v8a, armeabi-v7a, x86_64
- **Gateway Detection**: Calculated from `WifiManager`
- **Permissions**: `ACCESS_WIFI_STATE`, `ACCESS_NETWORK_STATE`

---

## Performance Considerations

### Bandwidth Limiting

UDP tests use 81 Mbps bandwidth limit to:
- Prevent network saturation
- Allow accurate measurements
- Avoid overwhelming routers

### Parallel Streams

16 parallel streams provide:
- Better throughput measurement
- Reduced impact of individual packet delays
- More accurate WiFi performance data

### Test Duration

10 seconds per phase (download/upload):
- Long enough for stable measurements
- Short enough for good UX
- Allows TCP slow-start to complete

---

## Troubleshooting

### Test Always Fails

1. Check iPerf3 server is running: `iperf3 -s`
2. Verify port 5201 is open
3. Check firewall rules
4. Try TCP instead of UDP

### Inconsistent Results

1. Ensure stable WiFi connection
2. Check for network congestion
3. Try different bandwidth limit
4. Use fewer parallel streams

### Gateway Detection Fails

**iOS**: Should work automatically
**Android**: Check WiFi permissions are granted

---

## Related Documentation

- [iPerf3 Official Documentation](https://iperf.fr/iperf-doc.php)
- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Riverpod Package](https://riverpod.dev/)
