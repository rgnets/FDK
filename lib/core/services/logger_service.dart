import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/logging_config.dart';
import 'package:rgnets_fdk/core/services/error_reporter.dart';

/// Logger service for consistent logging throughout the app.
class LoggerService {
  LoggerService._();

  static const String _tag = 'RGNets-FDK';

  static LogLevel _currentLevel = LogLevel.debug;
  static Logger _logger = _buildLogger(_currentLevel);

  /// Configure the logging service during application bootstrap.
  static void configure({LogLevel? level, bool? enableCrashReporting}) {
    _currentLevel = level ?? LoggingConfig.logLevel;
    _logger = _buildLogger(_currentLevel);
    ErrorReporter.isEnabled =
        enableCrashReporting ?? LoggingConfig.crashReportingEnabled;
  }

  static Logger _buildLogger(LogLevel level) {
    return Logger(
      level: _toLoggerLevel(level),
      printer: PrettyPrinter(
        methodCount: level.index >= LogLevel.debug.index ? 2 : 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );
  }

  /// Trace-level logging (very verbose, typically disabled outside development).
  static void trace(String message, {String? tag}) {
    _log(LogLevel.trace, message, tag: tag);
  }

  /// Debug-level logging.
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Info-level logging.
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Warning-level logging.
  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  /// Error-level logging with optional crash reporting.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    final reportPayload = error ?? message;
    ErrorReporter.report(
      reportPayload,
      stackTrace: stackTrace,
      hint: tag ?? message,
    );
  }

  /// Log outgoing API requests (debug/trace).
  static void apiRequest(
    String method,
    String path, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!_shouldLog(LogLevel.debug)) {
      return;
    }
    _log(LogLevel.debug, 'REQUEST: $method $path', tag: 'API');
    if (headers != null && headers.isNotEmpty) {
      _log(LogLevel.trace, 'Headers: $headers', tag: 'API');
    }
    if (body != null) {
      final bodyStr = body.toString();
      final truncated = bodyStr.length > 800
          ? '${bodyStr.substring(0, 800)}... [truncated]'
          : bodyStr;
      _log(LogLevel.trace, 'Body: $truncated', tag: 'API');
    }
  }

  /// Log API responses (debug/trace).
  static void apiResponse(int? statusCode, String path, {dynamic data}) {
    if (!_shouldLog(LogLevel.debug)) {
      return;
    }
    _log(
      LogLevel.debug,
      'RESPONSE: ${statusCode ?? 'Unknown'} $path',
      tag: 'API',
    );
    if (data != null && _shouldLog(LogLevel.trace)) {
      final dataStr = data.toString();
      final truncated = dataStr.length > 800
          ? '${dataStr.substring(0, 800)}... [truncated]'
          : dataStr;
      _log(LogLevel.trace, 'Data: $truncated', tag: 'API');
    }
  }

  /// Log API errors.
  static void apiError(String path, Object error, {int? statusCode}) {
    _log(
      LogLevel.error,
      'ERROR: ${statusCode ?? 'Unknown'} $path',
      tag: 'API',
      error: error,
    );
  }

  /// Log room data structures for debugging extraction routines.
  static void logRoomDataStructure(
    String roomId,
    Map<String, dynamic> roomData,
  ) {
    if (!_shouldLog(LogLevel.debug)) {
      return;
    }
    _log(LogLevel.debug, 'Analyzing Room $roomId Data Structure:', tag: 'ROOM');
    _log(LogLevel.debug, 'Room Keys: ${roomData.keys.toList()}', tag: 'ROOM');

    void logCollection(String key) {
      if (!roomData.containsKey(key)) {
        return;
      }
      final collection = roomData[key] as List?;
      if (collection == null || collection.isEmpty) {
        _log(LogLevel.debug, 'No $key entries in response', tag: 'ROOM');
        return;
      }
      _log(LogLevel.debug, '$key Count: ${collection.length}', tag: 'ROOM');
      final first = collection.first;
      if (first is Map) {
        _log(
          LogLevel.trace,
          'First $key Keys: ${first.keys.toList()}',
          tag: 'ROOM',
        );
        _log(
          LogLevel.trace,
          'Has pms_room_id: ${first.containsKey('pms_room_id')}',
          tag: 'ROOM',
        );
        _log(
          LogLevel.trace,
          'Has room_id: ${first.containsKey('room_id')}',
          tag: 'ROOM',
        );
      }
    }

    logCollection('access_points');
    logCollection('media_converters');
    logCollection('infrastructure_devices');
  }

  /// Log device extraction results.
  static void logDeviceExtraction(
    String roomId,
    List<String> extractedIds, {
    int? totalInResponse,
  }) {
    if (!_shouldLog(LogLevel.info)) {
      return;
    }
    _log(LogLevel.info, 'Device Extraction for Room $roomId:', tag: 'EXTRACT');
    _log(
      LogLevel.info,
      'Extracted ${extractedIds.length} device IDs',
      tag: 'EXTRACT',
    );

    if (totalInResponse != null) {
      _log(
        LogLevel.info,
        'Total devices in API response: $totalInResponse',
        tag: 'EXTRACT',
      );
      if (totalInResponse > extractedIds.length) {
        _log(
          LogLevel.warning,
          'Filtered out ${totalInResponse - extractedIds.length} devices',
          tag: 'EXTRACT',
        );
      }
    }

    if (extractedIds.isNotEmpty && _shouldLog(LogLevel.debug)) {
      final preview = extractedIds.take(5).toList();
      final suffix = extractedIds.length > 5
          ? '... and ${extractedIds.length - 5} more'
          : '';
      _log(LogLevel.debug, 'Device IDs: $preview$suffix', tag: 'EXTRACT');
    }
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_shouldLog(level)) {
      return;
    }
    final formatted = tag != null
        ? '[$_tag:$tag] $message'
        : '[$_tag] $message';
    _logger.log(
      _toLoggerLevel(level),
      formatted,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static bool _shouldLog(LogLevel level) {
    if (level == LogLevel.off) {
      return false;
    }
    if (_currentLevel == LogLevel.off) {
      return false;
    }
    return level.index <= _currentLevel.index;
  }

  static Level _toLoggerLevel(LogLevel level) {
    switch (level) {
      case LogLevel.off:
        return Level.off;
      case LogLevel.error:
        return Level.error;
      case LogLevel.warning:
        return Level.warning;
      case LogLevel.info:
        return Level.info;
      case LogLevel.debug:
        return Level.debug;
      case LogLevel.trace:
        return Level.trace;
    }
  }
}
