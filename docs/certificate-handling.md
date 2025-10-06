# Certificate Handling - RG Nets FDK

**Created**: 2025-08-17
**Purpose**: Document SSL/TLS certificate handling requirements

## Requirement

The app MUST accept self-signed certificates for test and staging environments.

## Implementation Strategy

### Certificate Validation

```dart
class HttpClientConfig {
  static void configureCertificateHandling(Dio dio, String environment) {
    if (environment != 'production') {
      // Accept self-signed certificates for non-production
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) {
          // Log the self-signed certificate usage
          logger.warning('Accepting self-signed certificate for $host:$port');
          return true; // Accept all certificates in test/staging
        };
        return client;
      };
    }
  }
}
```

### Connection Status Page

The connection status page MUST clearly indicate certificate status:

```dart
class ConnectionStatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConnectionIndicator(),
        if (isUsingSelfSignedCert)
          WarningBanner(
            icon: Icons.warning_amber,
            message: 'Using self-signed certificate (Test Environment)',
            color: Colors.orange,
          ),
        CertificateDetails(),
      ],
    );
  }
}
```

## UI Requirements

### Connection Status Indicators

1. **Production Environment**
   ```
   ✅ Secure Connection
   Valid SSL Certificate
   Issuer: [Certificate Authority]
   ```

2. **Test/Staging Environment**
   ```
   ⚠️ Test Environment
   Self-Signed Certificate in Use
   Host: vgw1-01.dal-interurban.mdu.attwifi.com
   ```

3. **Connection Error**
   ```
   ❌ Connection Failed
   Unable to verify certificate
   [Retry] [View Details]
   ```

### Certificate Details View

```dart
class CertificateDetailsView extends StatelessWidget {
  final SecurityContext context;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Certificate Status'),
            subtitle: Text(certStatus),
            leading: Icon(certIcon, color: certColor),
          ),
          ListTile(
            title: Text('Host'),
            subtitle: Text(certificate.host),
          ),
          ListTile(
            title: Text('Issuer'),
            subtitle: Text(certificate.issuer ?? 'Self-Signed'),
          ),
          ListTile(
            title: Text('Valid From'),
            subtitle: Text(certificate.validFrom),
          ),
          ListTile(
            title: Text('Valid Until'),
            subtitle: Text(certificate.validUntil),
          ),
          if (isSelfSigned)
            ListTile(
              title: Text('Fingerprint'),
              subtitle: Text(certificate.fingerprint),
            ),
        ],
      ),
    );
  }
}
```

## Security Considerations

### Environment-Specific Behavior

```dart
enum Environment {
  production,  // Strict certificate validation
  staging,     // Accept self-signed certificates
  development, // Accept self-signed certificates
}

class CertificateValidator {
  static bool shouldAcceptCertificate(
    X509Certificate cert,
    String host,
    int port,
    Environment env,
  ) {
    switch (env) {
      case Environment.production:
        // Production: Only accept valid certificates
        return isValidCertificate(cert);
        
      case Environment.staging:
      case Environment.development:
        // Test environments: Accept self-signed
        logSelfSignedUsage(cert, host, port);
        return true;
    }
  }
  
  static void logSelfSignedUsage(cert, host, port) {
    logger.info('Self-signed certificate accepted:');
    logger.info('  Host: $host:$port');
    logger.info('  Fingerprint: ${cert.fingerprint}');
    logger.info('  Environment: ${Environment.current}');
  }
}
```

### User Notifications

```dart
class CertificateNotifications {
  static void showSelfSignedWarning(BuildContext context) {
    if (!hasShownWarningThisSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Using self-signed certificate (Test Environment)',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Details',
            onPressed: () => showCertificateDetails(context),
          ),
        ),
      );
      hasShownWarningThisSession = true;
    }
  }
}
```

## Testing Certificates

### Mock Certificate for Development

```dart
class MockCertificateProvider {
  static X509Certificate getMockCertificate() {
    return X509Certificate(
      subject: 'CN=*.attwifi.com',
      issuer: 'CN=Test CA',
      validFrom: DateTime.now().subtract(Duration(days: 30)),
      validTo: DateTime.now().add(Duration(days: 365)),
      isSelfSigned: true,
    );
  }
}
```

## Configuration

### Environment Configuration

```yaml
# config/staging.yaml
api:
  base_url: https://vgw1-01.dal-interurban.mdu.attwifi.com
  accept_self_signed: true
  show_certificate_warnings: true

# config/production.yaml  
api:
  base_url: https://api.production.attwifi.com
  accept_self_signed: false
  show_certificate_warnings: false
```

### Build Flavor Configuration

```dart
class FlavorConfig {
  static const Map<String, dynamic> staging = {
    'acceptSelfSigned': true,
    'showCertWarnings': true,
    'certValidation': 'permissive',
  };
  
  static const Map<String, dynamic> production = {
    'acceptSelfSigned': false,
    'showCertWarnings': false,
    'certValidation': 'strict',
  };
}
```

## Monitoring

### Certificate Usage Tracking

```dart
class CertificateMetrics {
  static void trackCertificateUsage({
    required bool isSelfSigned,
    required String host,
    required String environment,
  }) {
    analytics.track('certificate_used', {
      'is_self_signed': isSelfSigned,
      'host': host,
      'environment': environment,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

## Error Handling

### Certificate Errors

```dart
class CertificateErrorHandler {
  static Widget handleCertificateError(DioError error) {
    if (error.type == DioErrorType.other && 
        error.error is HandshakeException) {
      return CertificateErrorView(
        message: 'Certificate verification failed',
        suggestion: environment == 'production' 
          ? 'Please check your network connection'
          : 'Self-signed certificate may need to be trusted',
        actions: [
          if (environment != 'production')
            ElevatedButton(
              onPressed: () => trustCertificate(),
              child: Text('Trust Certificate'),
            ),
          TextButton(
            onPressed: () => viewCertificateDetails(),
            child: Text('View Details'),
          ),
        ],
      );
    }
    return GenericErrorView(error);
  }
}
```

## Best Practices

1. **Always indicate** when self-signed certificates are in use
2. **Log certificate usage** for debugging
3. **Never accept** self-signed certificates in production
4. **Show warnings** prominently in UI
5. **Track certificate issues** in analytics
6. **Provide details** for technical users
7. **Cache certificate status** to avoid repeated checks

## Implementation Checklist

- [ ] Configure Dio/HTTP client for each environment
- [ ] Create connection status page
- [ ] Add certificate status indicator to app bar
- [ ] Implement certificate details view
- [ ] Add logging for self-signed usage
- [ ] Create warning notifications
- [ ] Test with actual self-signed certificates
- [ ] Document certificate requirements for deployment

## References

- Flutter HTTP Client: https://api.flutter.dev/flutter/dart-io/HttpClient-class.html
- Dio Certificate Handling: https://pub.dev/packages/dio#https-certificate-verification
- X.509 Certificates: https://datatracker.ietf.org/doc/html/rfc5280