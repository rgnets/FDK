import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Credentials extracted from a deeplink URL.
class DeeplinkCredentials {
  const DeeplinkCredentials({
    required this.fqdn,
    required this.apiKey,
    required this.login,
  });

  final String fqdn;
  final String apiKey;
  final String login;
}

/// Result of parsing a deeplink URI.
sealed class DeeplinkParseResult {
  const DeeplinkParseResult();
}

class DeeplinkParseSuccess extends DeeplinkParseResult {
  const DeeplinkParseSuccess(this.credentials);
  final DeeplinkCredentials credentials;
}

class DeeplinkParseError extends DeeplinkParseResult {
  const DeeplinkParseError(this.message);
  final String message;
}

class DeeplinkParseIgnored extends DeeplinkParseResult {
  const DeeplinkParseIgnored(this.reason);
  final String reason;
}

/// Service for handling FDK deeplinks.
///
/// Follows the pattern from ATT-FE-Tool's DeeplinkService but adapted
/// for FDK's architecture. Handles deeplinks of the form:
///   fdk://login?fqdn=...&apiKey=...&login=...
///
/// Also supports Base64-encoded data parameter:
///   fdk://login?data=eyJmcWRuIjoi...
class DeeplinkService {
  DeeplinkService();

  static const String _tag = 'DEEPLINK';
  static const String _scheme = 'fdk';
  static const String _host = 'login';
  static const int _minApiKeyLength = 32;
  static const Duration _deduplicationWindow = Duration(seconds: 30);

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Deduplication state
  String? _lastProcessedUri;
  DateTime? _lastProcessedTime;
  bool _isProcessing = false;

  // Callbacks
  Future<bool> Function(DeeplinkCredentials credentials)? _confirmCallback;
  Future<void> Function(DeeplinkCredentials credentials)? _authenticateCallback;
  VoidCallback? _onSuccessCallback;
  VoidCallback? _onCancelCallback;
  VoidCallback? _onErrorCallback;

  /// FQDN validation regex - matches valid domain names.
  static final RegExp _fqdnRegex = RegExp(
    r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$',
  );

  /// Initialize the deeplink service with callbacks.
  ///
  /// [confirmCallback] - Called to show confirmation dialog, returns true if user approves.
  /// [authenticateCallback] - Called to authenticate with the credentials.
  /// [onSuccess] - Called after successful authentication.
  /// [onCancel] - Called if user cancels or declines.
  /// [onError] - Called on any error during processing.
  Future<void> initialize({
    required Future<bool> Function(DeeplinkCredentials credentials)
        confirmCallback,
    required Future<void> Function(DeeplinkCredentials credentials)
        authenticateCallback,
    required VoidCallback onSuccess,
    required VoidCallback onCancel,
    VoidCallback? onError,
  }) async {
    LoggerService.info('Initializing DeeplinkService', tag: _tag);

    _confirmCallback = confirmCallback;
    _authenticateCallback = authenticateCallback;
    _onSuccessCallback = onSuccess;
    _onCancelCallback = onCancel;
    _onErrorCallback = onError;

    // Check for initial deeplink (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      LoggerService.info('Initial URI: $initialUri', tag: _tag);
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } on Exception catch (e) {
      LoggerService.error('Error getting initial URI: $e', tag: _tag);
    }

    // Listen for deeplinks while app is running
    LoggerService.info('Setting up deeplink stream listener', tag: _tag);
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) async {
        LoggerService.info('Received URI from stream: $uri', tag: _tag);
        await _handleUri(uri);
      },
      onError: (Object err) =>
          LoggerService.error('Deeplink stream error: $err', tag: _tag),
    );
  }

  /// Handle an incoming URI.
  Future<void> _handleUri(Uri uri) async {
    LoggerService.info('Received deeplink URI: $uri', tag: _tag);

    // Block if already processing
    if (_isProcessing) {
      LoggerService.info('BLOCKING deeplink - already processing one', tag: _tag);
      return;
    }

    // Deduplication check
    final uriString = uri.toString();
    final now = DateTime.now();

    if (_lastProcessedUri == uriString && _lastProcessedTime != null) {
      final elapsed = now.difference(_lastProcessedTime!);
      if (elapsed < _deduplicationWindow) {
        LoggerService.info(
          'BLOCKING duplicate deeplink within ${elapsed.inSeconds}s',
          tag: _tag,
        );
        return;
      }
    }

    LoggerService.info('Processing new deeplink', tag: _tag);
    _isProcessing = true;
    _lastProcessedUri = uriString;
    _lastProcessedTime = now;

    try {
      final result = _parseUri(uri);

      switch (result) {
        case DeeplinkParseSuccess(:final credentials):
          await _performDeeplinkLogin(credentials);
        case DeeplinkParseError(:final message):
          LoggerService.error('Deeplink parse error: $message', tag: _tag);
          _onErrorCallback?.call();
        case DeeplinkParseIgnored(:final reason):
          LoggerService.info('Deeplink ignored: $reason', tag: _tag);
      }
    } finally {
      _isProcessing = false;
      LoggerService.info('Deeplink processing completed', tag: _tag);
    }
  }

  /// Parse a deeplink URI and extract credentials.
  DeeplinkParseResult _parseUri(Uri uri) {
    // Validate scheme and host
    if (uri.scheme != _scheme) {
      return DeeplinkParseIgnored('Unsupported scheme: ${uri.scheme}');
    }
    if (uri.host != _host) {
      return DeeplinkParseIgnored('Unsupported host: ${uri.host}');
    }

    String? fqdn;
    String? apiKey;
    String? login;

    // Try Base64-encoded data parameter first
    final dataParam = uri.queryParameters['data'];
    if (dataParam != null && dataParam.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(dataParam);
        final decodedString = utf8.decode(decodedBytes);
        final decodedData = json.decode(decodedString) as Map<String, dynamic>;

        fqdn = _extractParam(decodedData, ['fqdn', 'server', 'host']);
        apiKey = _extractParam(decodedData, ['apiKey', 'key', 'token', 'api_key']);
        login = _extractParam(decodedData, ['login', 'user', 'username']);
      } on Exception catch (e) {
        LoggerService.error(
          'Failed to decode Base64 data parameter: $e',
          tag: _tag,
        );
        // Fall through to try individual parameters
      }
    }

    // Fallback to individual query parameters
    if (fqdn == null || apiKey == null || login == null) {
      fqdn ??= _extractQueryParam(uri, ['fqdn', 'server', 'host']);
      apiKey ??= _extractQueryParam(uri, ['apiKey', 'key', 'token', 'api_key']);
      login ??= _extractQueryParam(uri, ['login', 'user', 'username']);
    }

    // Validate required parameters are present
    if (fqdn == null || fqdn.isEmpty) {
      return const DeeplinkParseError('Missing or empty fqdn parameter');
    }
    if (apiKey == null || apiKey.isEmpty) {
      return const DeeplinkParseError('Missing or empty apiKey parameter');
    }
    if (login == null || login.isEmpty) {
      return const DeeplinkParseError('Missing or empty login parameter');
    }

    // Validate format
    if (!isValidFqdn(fqdn)) {
      return DeeplinkParseError('Invalid FQDN format: $fqdn');
    }
    if (apiKey.length < _minApiKeyLength) {
      return const DeeplinkParseError(
        'API key too short (min $_minApiKeyLength chars)',
      );
    }

    return DeeplinkParseSuccess(
      DeeplinkCredentials(fqdn: fqdn, apiKey: apiKey, login: login),
    );
  }

  /// Extract a parameter value from a map, trying multiple key aliases.
  String? _extractParam(Map<String, dynamic> data, List<String> aliases) {
    for (final alias in aliases) {
      final value = data[alias];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  /// Extract a query parameter, trying multiple key aliases.
  String? _extractQueryParam(Uri uri, List<String> aliases) {
    for (final alias in aliases) {
      final value = uri.queryParameters[alias];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  /// Validate FQDN format.
  static bool isValidFqdn(String fqdn) {
    return _fqdnRegex.hasMatch(fqdn);
  }

  /// Perform the deeplink login flow.
  Future<void> _performDeeplinkLogin(DeeplinkCredentials credentials) async {
    LoggerService.info(
      'Starting deeplink login for ${credentials.fqdn} as ${credentials.login}',
      tag: _tag,
    );

    // Wait briefly for app to come to foreground
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Show confirmation dialog
    LoggerService.info('Showing confirmation dialog', tag: _tag);
    final confirmed = await _confirmCallback?.call(credentials) ?? false;
    LoggerService.info('Dialog result: confirmed=$confirmed', tag: _tag);

    if (!confirmed) {
      LoggerService.info('User cancelled deeplink login', tag: _tag);
      _onCancelCallback?.call();
      return;
    }

    try {
      // Authenticate
      LoggerService.info('Authenticating with credentials', tag: _tag);
      await _authenticateCallback?.call(credentials);

      LoggerService.info(
        'Deeplink login successful: ${credentials.fqdn} as ${credentials.login}',
        tag: _tag,
      );
      _onSuccessCallback?.call();
    } on Exception catch (e) {
      LoggerService.error('Deeplink login failed: $e', tag: _tag);
      _onErrorCallback?.call();
    }
  }

  /// Dispose of resources.
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _lastProcessedUri = null;
    _lastProcessedTime = null;
    _isProcessing = false;
  }
}
