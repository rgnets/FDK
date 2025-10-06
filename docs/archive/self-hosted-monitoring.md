# Self-Hosted Monitoring & Analytics - ATT FE Tool

**Created**: 2025-08-17
**Purpose**: Define error monitoring and analytics without cloud dependencies

## Requirements

Need error monitoring and analytics that can run:
- Without external cloud services
- On-premises or in private infrastructure
- With data staying within organization boundaries

## Proposed Solution: Local-First Architecture

### 1. Local SQLite Database for Analytics

Store all metrics and errors locally on device first:

```dart
class LocalAnalytics {
  late Database _database;
  
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'analytics.db'),
      version: 1,
      onCreate: (db, version) {
        // Error logs table
        db.execute('''
          CREATE TABLE error_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            error_type TEXT NOT NULL,
            message TEXT NOT NULL,
            stack_trace TEXT,
            user_id TEXT,
            device_info TEXT,
            app_version TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
        
        // Analytics events table
        db.execute('''
          CREATE TABLE analytics_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            event_name TEXT NOT NULL,
            properties TEXT,
            user_id TEXT,
            session_id TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
        
        // Performance metrics table
        db.execute('''
          CREATE TABLE performance_metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            metric_name TEXT NOT NULL,
            value REAL NOT NULL,
            unit TEXT,
            context TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }
  
  Future<void> logError(ErrorInfo error) async {
    await _database.insert('error_logs', {
      'timestamp': DateTime.now().toIso8601String(),
      'error_type': error.type,
      'message': error.message,
      'stack_trace': error.stackTrace,
      'user_id': await getUserId(),
      'device_info': await getDeviceInfo(),
      'app_version': packageInfo.version,
      'synced': 0,
    });
  }
  
  Future<void> trackEvent(String name, Map<String, dynamic> properties) async {
    await _database.insert('analytics_events', {
      'timestamp': DateTime.now().toIso8601String(),
      'event_name': name,
      'properties': jsonEncode(properties),
      'user_id': await getUserId(),
      'session_id': currentSessionId,
      'synced': 0,
    });
  }
}
```

### 2. Self-Hosted Sync Server (Optional)

If centralized collection is needed, deploy a simple server internally:

```dart
// Simple REST API for collecting metrics
class MetricsSyncServer {
  // Deploy using Docker on internal infrastructure
  // No external dependencies required
}

// Dart server code (runs on internal server)
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:postgres/postgres.dart';

void main() async {
  final db = PostgreSQLConnection(
    'localhost', 5432, 'metrics_db',
    username: 'metrics_user',
    password: 'secure_password',
  );
  await db.open();
  
  var handler = Pipeline()
    .addMiddleware(logRequests())
    .addHandler((Request request) async {
      if (request.url.path == 'api/errors' && request.method == 'POST') {
        final payload = await request.readAsString();
        final errors = jsonDecode(payload);
        
        // Store in PostgreSQL
        for (final error in errors) {
          await db.execute('''
            INSERT INTO error_logs 
            (timestamp, error_type, message, stack_trace, device_id, app_version)
            VALUES (@timestamp, @type, @message, @stack, @device, @version)
          ''', substitutionValues: error);
        }
        
        return Response.ok('{"status": "success"}');
      }
      
      return Response.notFound('Not found');
    });
  
  await io.serve(handler, 'localhost', 8080);
}
```

### 3. Export-Based Analytics

Allow manual export of analytics for analysis:

```dart
class AnalyticsExporter {
  Future<File> exportErrors({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final errors = await _database.query(
      'error_logs',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate?.toIso8601String() ?? '2000-01-01',
        endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      ],
    );
    
    // Export as CSV
    final csv = const ListToCsvConverter().convert([
      ['Timestamp', 'Error Type', 'Message', 'App Version', 'Device'],
      ...errors.map((e) => [
        e['timestamp'],
        e['error_type'],
        e['message'],
        e['app_version'],
        e['device_info'],
      ]),
    ]);
    
    final file = File('${await getDownloadsDirectory()}/errors_export.csv');
    await file.writeAsString(csv);
    return file;
  }
  
  Future<File> exportAnalytics() async {
    // Similar for analytics events
  }
  
  Future<Map<String, dynamic>> generateReport() async {
    // Generate summary statistics
    final errorCount = Sqflite.firstIntValue(
      await _database.rawQuery('SELECT COUNT(*) FROM error_logs')
    );
    
    final topErrors = await _database.rawQuery('''
      SELECT error_type, COUNT(*) as count 
      FROM error_logs 
      GROUP BY error_type 
      ORDER BY count DESC 
      LIMIT 10
    ''');
    
    final dailyActiveUsers = await _database.rawQuery('''
      SELECT DATE(timestamp) as date, COUNT(DISTINCT user_id) as users
      FROM analytics_events
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
      LIMIT 30
    ''');
    
    return {
      'total_errors': errorCount,
      'top_errors': topErrors,
      'daily_active_users': dailyActiveUsers,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }
}
```

### 4. Built-in Dashboard

Add an admin screen within the app for viewing metrics:

```dart
class AnalyticsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics Dashboard')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: AnalyticsExporter().generateReport(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingIndicator();
          
          final report = snapshot.data!;
          return ListView(
            children: [
              // Error Statistics
              Card(
                child: ListTile(
                  title: Text('Total Errors'),
                  subtitle: Text('Last 30 days'),
                  trailing: Text(
                    '${report['total_errors']}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              
              // Top Errors Chart
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Errors', 
                        style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 16),
                      ...report['top_errors'].map((error) => 
                        ErrorBar(
                          type: error['error_type'],
                          count: error['count'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Export Actions
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Export Error Logs'),
                      subtitle: Text('Download CSV file'),
                      trailing: Icon(Icons.download),
                      onTap: () => _exportErrors(),
                    ),
                    ListTile(
                      title: Text('Export Analytics'),
                      subtitle: Text('Download CSV file'),
                      trailing: Icon(Icons.download),
                      onTap: () => _exportAnalytics(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 5. Crash Reporting Without Cloud

Capture crashes locally and view on next app launch:

```dart
class LocalCrashReporter {
  static const String crashFile = 'crash_report.json';
  
  static void init() {
    FlutterError.onError = (FlutterErrorDetails details) async {
      // Log to local database
      await LocalAnalytics().logError(ErrorInfo(
        type: 'flutter_error',
        message: details.exception.toString(),
        stackTrace: details.stack.toString(),
      ));
      
      // Also save last crash for immediate viewing
      final crashDir = await getApplicationDocumentsDirectory();
      final file = File('${crashDir.path}/$crashFile');
      await file.writeAsString(jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'error': details.exception.toString(),
        'stack': details.stack.toString(),
      }));
    };
    
    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      LocalAnalytics().logError(ErrorInfo(
        type: 'platform_error',
        message: error.toString(),
        stackTrace: stack.toString(),
      ));
      return true;
    };
  }
  
  static Future<bool> hasUnreportedCrash() async {
    final crashDir = await getApplicationDocumentsDirectory();
    final file = File('${crashDir.path}/$crashFile');
    return file.existsSync();
  }
  
  static Future<Map<String, dynamic>?> getLastCrash() async {
    final crashDir = await getApplicationDocumentsDirectory();
    final file = File('${crashDir.path}/$crashFile');
    if (await file.exists()) {
      final content = await file.readAsString();
      await file.delete(); // Clear after reading
      return jsonDecode(content);
    }
    return null;
  }
}

// Show crash dialog on app start
class CrashReportDialog extends StatelessWidget {
  final Map<String, dynamic> crashData;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('App Crashed Previously'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('The app crashed on ${crashData['timestamp']}'),
          SizedBox(height: 8),
          Text('Error: ${crashData['error']}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Dismiss'),
        ),
        ElevatedButton(
          onPressed: () => _sendToInternalServer(crashData),
          child: Text('Send Report'),
        ),
      ],
    );
  }
}
```

## Configuration Options

### Environment-Based Setup

```yaml
# config/production.yaml
monitoring:
  type: local_with_sync
  sync_server: https://internal-metrics.company.local
  sync_interval: 3600  # seconds
  retain_days: 90

# config/development.yaml
monitoring:
  type: local_only
  sync_server: null
  retain_days: 7
```

### Privacy-Preserving Analytics

```dart
class PrivacyAnalytics {
  // Hash user IDs for privacy
  String getUserId() {
    final deviceId = await PlatformDeviceId.getDeviceId;
    return sha256.convert(utf8.encode(deviceId)).toString();
  }
  
  // Aggregate metrics before storage
  void trackScreenView(String screenName) {
    // Don't store individual views, just increment counter
    incrementCounter('screen_views', screenName);
  }
  
  // Sanitize error messages
  String sanitizeError(String error) {
    // Remove potential PII from error messages
    return error
      .replaceAll(RegExp(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b', caseSensitive: false), '[EMAIL]')
      .replaceAll(RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), '[PHONE]')
      .replaceAll(RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b'), '[IP]');
  }
}
```

## Implementation Checklist

### Required Components
- [ ] Local SQLite database for metrics
- [ ] Error capture and logging
- [ ] Analytics event tracking
- [ ] Export functionality (CSV/JSON)
- [ ] Built-in dashboard/viewer
- [ ] Crash reporting system
- [ ] Data retention policies
- [ ] Privacy controls

### Optional Components
- [ ] Internal sync server (if centralization needed)
- [ ] Grafana integration (for visualization)
- [ ] Prometheus metrics export
- [ ] Email alerts for critical errors
- [ ] Scheduled report generation

## Benefits of This Approach

1. **No External Dependencies**: Everything runs locally or on-premises
2. **Data Privacy**: Complete control over data, no third-party access
3. **Offline First**: Works without internet connection
4. **Cost Effective**: No cloud service fees
5. **Compliance Friendly**: Easier to meet security requirements
6. **Developer Friendly**: View metrics directly in app during development
7. **Export Options**: Can analyze data with any tool via CSV export

## Alternative Solutions

### 1. Sentry Self-Hosted
- Can run Sentry on internal infrastructure
- Requires Docker and more setup
- More features but heavier

### 2. ELK Stack (Elasticsearch, Logstash, Kibana)
- Powerful but complex
- Good for large-scale deployments
- Requires dedicated infrastructure

### 3. Simple File Logging
- Write logs to files
- Ship files to internal server periodically
- Minimal but less structured

## Recommended Approach

For ATT FE Tool, recommend:

1. **Phase 1**: Local-only analytics with export
   - SQLite database on device
   - Built-in viewer in app
   - CSV export for analysis

2. **Phase 2**: Add internal sync (if needed)
   - Simple REST API on internal server
   - PostgreSQL for centralized storage
   - Basic web dashboard

3. **Phase 3**: Enhanced visualization (if needed)
   - Grafana for dashboards
   - Automated reports
   - Alert system

This approach starts simple and can grow as needed without external dependencies.