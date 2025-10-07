import 'package:rgnets_fdk/core/config/environment.dart';

/// Logging levels supported by the application logger.
enum LogLevel { off, error, warning, info, debug, trace }

/// Centralised logging configuration resolved from compile-time defines or environment.
class LoggingConfig {
  LoggingConfig._();

  /// Desired log level (defaults to environment-specific value).
  static LogLevel get logLevel {
    const raw = String.fromEnvironment('LOG_LEVEL', defaultValue: 'auto');
    if (raw.isEmpty || raw.toLowerCase() == 'auto') {
      return _defaultLevelForEnvironment();
    }
    return _parseLogLevel(raw);
  }

  /// Whether crash/report forwarding should be enabled.
  static bool get crashReportingEnabled {
    return bool.fromEnvironment(
      'ENABLE_CRASH_REPORTING',
      defaultValue: EnvironmentConfig.isProduction,
    );
  }

  static LogLevel _defaultLevelForEnvironment() {
    if (EnvironmentConfig.isProduction) {
      return LogLevel.warning;
    }
    if (EnvironmentConfig.isStaging) {
      return LogLevel.info;
    }
    return LogLevel.debug;
  }

  static LogLevel _parseLogLevel(String value) {
    switch (value.toLowerCase()) {
      case 'off':
        return LogLevel.off;
      case 'error':
        return LogLevel.error;
      case 'warn':
      case 'warning':
        return LogLevel.warning;
      case 'info':
        return LogLevel.info;
      case 'debug':
        return LogLevel.debug;
      case 'trace':
      case 'verbose':
        return LogLevel.trace;
      default:
        return _defaultLevelForEnvironment();
    }
  }
}
