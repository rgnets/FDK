import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

class SpeedTestDebugLogger {
  SpeedTestDebugLogger._();

  static const String tag = 'SpeedTest';

  static String newRunId([String prefix = 'speed-test']) =>
      '$prefix-${DateTime.now().millisecondsSinceEpoch}';

  static String newRequestId(String scope) =>
      '$scope-${DateTime.now().millisecondsSinceEpoch}';

  static void debug(String phase, Map<String, dynamic> details) {
    if (!LoggerService.isVerboseLoggingEnabled) {
      return;
    }
    LoggerService.debug(
      '[SPEED_TEST:$phase] ${formatForLog(details)}',
      tag: tag,
    );
  }

  static void info(String phase, Map<String, dynamic> details) {
    LoggerService.info(
      '[SPEED_TEST:$phase] ${formatForLog(details)}',
      tag: tag,
    );
  }

  static void warning(String phase, Map<String, dynamic> details) {
    LoggerService.warning(
      '[SPEED_TEST:$phase] ${formatForLog(details)}',
      tag: tag,
    );
  }

  static void error(
    String phase,
    Map<String, dynamic> details, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    LoggerService.error(
      '[SPEED_TEST:$phase] ${formatForLog(details)}',
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static Map<String, dynamic> configDetails({
    required String host,
    required int port,
    required int durationSeconds,
    required bool useUdp,
    required int parallelStreams,
    int? bandwidthMbps,
    bool? reverse,
    String? phase,
    String? serverLabel,
  }) {
    return {
      'server_host': host,
      'server_port': port,
      'duration_seconds': durationSeconds,
      'protocol': useUdp ? 'udp' : 'tcp',
      'parallel_streams': parallelStreams,
      if (bandwidthMbps != null) 'bandwidth_mbps': bandwidthMbps,
      if (reverse != null) 'direction': reverse ? 'download' : 'upload',
      if (phase != null) 'phase': phase,
      if (serverLabel != null) 'server_label': serverLabel,
    };
  }

  static Map<String, dynamic> speedTestConfigSummary(SpeedTestConfig? config) {
    if (config == null) {
      return {};
    }
    return {
      'speed_test_id': config.id,
      if (config.name != null) 'name': config.name,
      if (config.target != null) 'target': config.target,
      'port': config.serverPort,
      if (config.iperfProtocol != null) 'protocol': config.iperfProtocol,
      if (config.minDownloadMbps != null)
        'min_download_mbps': config.minDownloadMbps,
      if (config.minUploadMbps != null) 'min_upload_mbps': config.minUploadMbps,
    };
  }

  static Map<String, dynamic> resultSummary(SpeedTestResult result) {
    return {
      if (result.id != null) 'result_id': result.id,
      if (result.speedTestId != null) 'speed_test_id': result.speedTestId,
      if (result.source != null) 'source': result.source,
      if (result.destination != null) 'destination': result.destination,
      if (result.port != null) 'port': result.port,
      if (result.iperfProtocol != null) 'protocol': result.iperfProtocol,
      if (result.downloadMbps != null) 'download_mbps': result.downloadMbps,
      if (result.uploadMbps != null) 'upload_mbps': result.uploadMbps,
      if (result.rtt != null) 'latency_ms': result.rtt,
      if (result.jitter != null) 'jitter_ms': result.jitter,
      if (result.packetLoss != null) 'packet_loss': result.packetLoss,
      'passed': result.passed,
      if (result.testedViaAccessPointId != null)
        'tested_via_access_point_id': result.testedViaAccessPointId,
      if (result.testedViaMediaConverterId != null)
        'tested_via_media_converter_id': result.testedViaMediaConverterId,
      if (result.pmsRoomId != null) 'pms_room_id': result.pmsRoomId,
      if (result.initiatedAt != null)
        'initiated_at': result.initiatedAt!.toIso8601String(),
      if (result.completedAt != null)
        'completed_at': result.completedAt!.toIso8601String(),
      if (result.hasError) 'error_message': result.errorMessage,
    };
  }
}
