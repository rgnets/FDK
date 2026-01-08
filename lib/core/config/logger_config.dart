import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';

/// Centralized logger configuration
class LoggerConfig {
  static Logger getLogger({String? className}) {
    // Completely disable logging in production to prevent memory issues
    if (EnvironmentConfig.isProduction || kReleaseMode) {
      return Logger(level: Level.off, printer: _NullPrinter());
    }

    return Logger(
      printer: _getPrinter(),
      level: _getLogLevel(),
      filter: _getFilter(),
    );
  }

  static PrettyPrinter _getPrinter() {
    return PrettyPrinter(
      methodCount: 0, // No stack traces
      errorMethodCount: 2,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.none,
    );
  }

  static Level _getLogLevel() {
    if (EnvironmentConfig.isDevelopment) {
      return Level.debug;
    }
    if (EnvironmentConfig.isStaging) {
      return Level.info;
    }
    return Level.warning;
  }

  static LogFilter _getFilter() {
    return DevelopmentFilter();
  }

  /// Check if verbose logging is enabled
  static bool get isVerboseLoggingEnabled {
    return kDebugMode && EnvironmentConfig.isDevelopment;
  }

  /// Check if step-by-step logging should be shown
  static bool get shouldShowStepLogging {
    return false;
  }
}

/// Null printer that outputs nothing
class _NullPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) => [];
}