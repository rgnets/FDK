import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';

/// Centralized logger configuration
class LoggerConfig {
  static Logger getLogger({String? className}) {
    return Logger(
      printer: _getPrinter(),
      level: _getLogLevel(),
      filter: _getFilter(),
    );
  }
  
  static PrettyPrinter _getPrinter() {
    return PrettyPrinter(
      methodCount: kDebugMode ? 2 : 0,
      errorMethodCount: kDebugMode ? 8 : 5,
      lineLength: 120,
      colors: true,
      printEmojis: kDebugMode,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    );
  }
  
  static Level _getLogLevel() {
    if (kReleaseMode) {
      return Level.warning; // Only warnings and errors in release
    }
    
    if (EnvironmentConfig.isDevelopment) {
      return Level.debug; // All logs in development
    }
    
    if (EnvironmentConfig.isStaging) {
      return Level.info; // Info and above in staging
    }
    
    return Level.info; // Default to info
  }
  
  static LogFilter _getFilter() {
    if (kReleaseMode) {
      return ProductionFilter(); // Minimal logging in production
    }
    return DevelopmentFilter(); // Full logging in development
  }
  
  /// Check if verbose logging is enabled
  static bool get isVerboseLoggingEnabled {
    return kDebugMode && EnvironmentConfig.isDevelopment;
  }
  
  /// Check if step-by-step logging should be shown
  static bool get shouldShowStepLogging {
    return false; // Disable excessive step-by-step logging
  }
}