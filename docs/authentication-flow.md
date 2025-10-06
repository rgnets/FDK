# Authentication Flow - RG Nets FDK

**Created**: 2025-08-17
**Purpose**: Complete authentication flow documentation for all environments

## Overview

Three authentication methods based on build flavor:
1. **Production**: QR code scanning only
2. **Staging**: Test credentials (hardcoded)
3. **Development**: Mock authentication

## QR Code Format (Production)

### QR Code Structure
```json
{
  "fqdn": "vgw1-01.location.mdu.attwifi.com",
  "api_key": "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r",
  "timestamp": "2025-08-17T10:30:00Z",
  "site_name": "Dallas Interurban"
}
```

### QR Code Generation (Server Side)
```python
# Server generates QR codes for field engineers
import qrcode
import json
from datetime import datetime

def generate_qr_code(site):
    data = {
        "fqdn": site.fqdn,
        "api_key": site.api_key,
        "timestamp": datetime.utcnow().isoformat(),
        "site_name": site.name
    }
    
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(json.dumps(data))
    qr.make(fit=True)
    
    return qr.make_image(fill_color="black", back_color="white")
```

## Authentication Implementation

### 1. Authentication Service
```dart
class AuthenticationService {
  static const String _tokenKey = 'auth_token';
  static const String _fqdnKey = 'api_fqdn';
  static const String _siteNameKey = 'site_name';
  static const String _authTimestampKey = 'auth_timestamp';
  
  final _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authState => _authStateController.stream;
  
  AuthCredentials? _currentCredentials;
  
  // Production: QR Code Authentication
  Future<AuthResult> authenticateWithQR(String qrData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);
      
      // Validate QR code structure
      if (!_isValidQRData(data)) {
        return AuthResult.failure('Invalid QR code format');
      }
      
      // Check timestamp (optional - QR codes might expire)
      if (_isExpiredQR(data['timestamp'])) {
        return AuthResult.failure('QR code has expired');
      }
      
      // Test the credentials
      final testResult = await _testConnection(
        data['fqdn'],
        data['api_key'],
      );
      
      if (testResult.success) {
        // Store credentials securely
        await _storeCredentials(data);
        
        _currentCredentials = AuthCredentials(
          fqdn: data['fqdn'],
          apiKey: data['api_key'],
          siteName: data['site_name'],
        );
        
        _authStateController.add(AuthState.authenticated);
        return AuthResult.success();
      } else {
        return AuthResult.failure('Invalid credentials');
      }
    } catch (e) {
      return AuthResult.failure('QR scan failed: $e');
    }
  }
  
  // Staging: Test Credentials
  Future<AuthResult> authenticateWithTestCredentials() async {
    const testCredentials = {
      'fqdn': 'vgw1-01.dal-interurban.mdu.attwifi.com',
      'api_key': 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r',
      'site_name': 'Test Environment',
    };
    
    await _storeCredentials(testCredentials);
    _currentCredentials = AuthCredentials.fromMap(testCredentials);
    _authStateController.add(AuthState.authenticated);
    
    return AuthResult.success();
  }
  
  // Development: Mock Authentication
  Future<AuthResult> authenticateWithMock() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network
    
    _currentCredentials = AuthCredentials(
      fqdn: 'mock.local',
      apiKey: 'mock_api_key',
      siteName: 'Development',
    );
    
    _authStateController.add(AuthState.authenticated);
    return AuthResult.success();
  }
  
  // Test connection to validate credentials
  Future<ConnectionTestResult> _testConnection(String fqdn, String apiKey) async {
    try {
      final uri = Uri.https(fqdn, '/api/whoami.json', {'api_key': apiKey});
      final response = await http.get(uri).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ConnectionTestResult(
          success: true,
          username: data['login'] ?? 'Unknown',
        );
      } else if (response.statusCode == 401) {
        return ConnectionTestResult(
          success: false,
          error: 'Invalid API key',
        );
      } else {
        return ConnectionTestResult(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on SocketException {
      return ConnectionTestResult(
        success: false,
        error: 'Cannot reach server',
      );
    } on TimeoutException {
      return ConnectionTestResult(
        success: false,
        error: 'Connection timeout',
      );
    } catch (e) {
      return ConnectionTestResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}
```

### 2. Secure Storage
```dart
class SecureCredentialStorage {
  static const _storage = FlutterSecureStorage();
  
  // Store credentials securely
  static Future<void> storeCredentials(Map<String, dynamic> credentials) async {
    await _storage.write(
      key: 'api_credentials',
      value: jsonEncode(credentials),
    );
    
    // Also store timestamp for session management
    await _storage.write(
      key: 'auth_timestamp',
      value: DateTime.now().toIso8601String(),
    );
  }
  
  // Retrieve credentials
  static Future<Map<String, dynamic>?> getCredentials() async {
    final data = await _storage.read(key: 'api_credentials');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }
  
  // Clear credentials on logout
  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
  
  // Check if session is still valid
  static Future<bool> isSessionValid() async {
    final timestamp = await _storage.read(key: 'auth_timestamp');
    if (timestamp == null) return false;
    
    final authTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    
    // Sessions expire after 24 hours
    return now.difference(authTime).inHours < 24;
  }
}
```

### 3. Authentication Flow UI
```dart
class AuthenticationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    
    return Scaffold(
      body: SafeArea(
        child: switch(flavor) {
          Flavor.production => ProductionAuthView(),
          Flavor.staging => StagingAuthView(),
          Flavor.development => DevelopmentAuthView(),
        },
      ),
    );
  }
}

class ProductionAuthView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  final result = await ref.read(authServiceProvider)
                    .authenticateWithQR(barcode.rawValue!);
                  
                  if (result.success) {
                    context.go('/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.error ?? 'Auth failed')),
                    );
                  }
                }
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Scan QR code to authenticate',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}
```

## Session Management

### Session States
```dart
enum AuthState {
  unauthenticated,
  authenticating,
  authenticated,
  sessionExpired,
  error,
}
```

### Session Refresh
```dart
class SessionManager {
  Timer? _refreshTimer;
  
  void startSessionRefresh() {
    _refreshTimer?.cancel();
    
    // Check session every 30 minutes
    _refreshTimer = Timer.periodic(Duration(minutes: 30), (_) async {
      final isValid = await SecureCredentialStorage.isSessionValid();
      
      if (!isValid) {
        // Session expired, force re-authentication
        await _handleSessionExpired();
      } else {
        // Optionally refresh token if API supports it
        await _refreshSession();
      }
    });
  }
  
  Future<void> _refreshSession() async {
    // If API supports token refresh, implement here
    // Otherwise, just validate current credentials still work
    final creds = await SecureCredentialStorage.getCredentials();
    if (creds != null) {
      final testResult = await _testConnection(
        creds['fqdn'],
        creds['api_key'],
      );
      
      if (!testResult.success) {
        await _handleSessionExpired();
      }
    }
  }
  
  Future<void> _handleSessionExpired() async {
    // Clear stored credentials
    await SecureCredentialStorage.clearCredentials();
    
    // Navigate to login
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
    
    // Show notification
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text('Session expired. Please login again.')),
    );
  }
}
```

## Logout Flow

### Logout Implementation
```dart
class LogoutHandler {
  static Future<void> logout() async {
    // 1. Clear API client data
    RxgApiClient.clearAllData();
    
    // 2. Clear secure storage
    await SecureCredentialStorage.clearCredentials();
    
    // 3. Clear cache
    await CacheManager.clearAll();
    
    // 4. Cancel any pending operations
    await NetworkQueue.cancelAll();
    
    // 5. Reset notification state
    NotificationManager.reset();
    
    // 6. Navigate to login
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}
```

## Error Handling

### Authentication Errors
```dart
enum AuthError {
  invalidQRCode,
  expiredQRCode,
  networkError,
  invalidCredentials,
  serverError,
  timeout,
  unknown,
}

class AuthErrorHandler {
  static String getMessage(AuthError error) {
    return switch(error) {
      AuthError.invalidQRCode => 'Invalid QR code format',
      AuthError.expiredQRCode => 'QR code has expired',
      AuthError.networkError => 'Network connection failed',
      AuthError.invalidCredentials => 'Invalid credentials',
      AuthError.serverError => 'Server error occurred',
      AuthError.timeout => 'Connection timeout',
      AuthError.unknown => 'Unknown error occurred',
    };
  }
  
  static IconData getIcon(AuthError error) {
    return switch(error) {
      AuthError.invalidQRCode => Icons.qr_code_scanner,
      AuthError.expiredQRCode => Icons.timer_off,
      AuthError.networkError => Icons.wifi_off,
      AuthError.invalidCredentials => Icons.lock,
      AuthError.serverError => Icons.error,
      AuthError.timeout => Icons.hourglass_empty,
      AuthError.unknown => Icons.help,
    };
  }
}
```

## Auto-Login

### Check for Existing Session
```dart
class AppStartup {
  static Future<String> determineInitialRoute() async {
    // Check if we have stored credentials
    final creds = await SecureCredentialStorage.getCredentials();
    
    if (creds == null) {
      return '/login';
    }
    
    // Check if session is still valid
    final isValid = await SecureCredentialStorage.isSessionValid();
    
    if (!isValid) {
      // Clear expired credentials
      await SecureCredentialStorage.clearCredentials();
      return '/login';
    }
    
    // Test if credentials still work
    final testResult = await AuthenticationService()._testConnection(
      creds['fqdn'],
      creds['api_key'],
    );
    
    if (testResult.success) {
      // Auto-login successful
      return '/home';
    } else {
      // Credentials no longer valid
      await SecureCredentialStorage.clearCredentials();
      return '/login';
    }
  }
}
```

## Security Considerations

### Credential Security
1. **Never log credentials** - Use [REDACTED] in logs
2. **Use secure storage** - FlutterSecureStorage with encryption
3. **Clear on logout** - Remove all traces of credentials
4. **Session timeout** - 24-hour maximum session
5. **No credential sharing** - Each device needs own QR scan

### Network Security
1. **HTTPS only** - Never send credentials over HTTP
2. **Certificate validation** - Except for test environments
3. **Timeout handling** - 10-second timeout for auth requests
4. **Rate limiting** - Prevent brute force attempts

## Testing

### Mock Authentication for Tests
```dart
class MockAuthService implements AuthenticationService {
  bool shouldSucceed = true;
  
  @override
  Future<AuthResult> authenticateWithQR(String qrData) async {
    await Future.delayed(Duration(milliseconds: 100));
    
    if (shouldSucceed) {
      return AuthResult.success();
    } else {
      return AuthResult.failure('Mock failure');
    }
  }
}
```

## Summary

The authentication flow provides:
1. **Secure QR-based auth** for production
2. **Quick test credentials** for staging
3. **Instant mock auth** for development
4. **Session management** with expiry
5. **Secure credential storage**
6. **Comprehensive error handling**
7. **Auto-login** for returning users