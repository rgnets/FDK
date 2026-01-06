import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_test_result.freezed.dart';
part 'speed_test_result.g.dart';

@freezed
class SpeedTestResult with _$SpeedTestResult {
  const factory SpeedTestResult({
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    required DateTime timestamp,
    @Default(false) bool hasError,
    String? errorMessage,
    String? localIpAddress,
    String? serverHost,
  }) = _SpeedTestResult;

  const SpeedTestResult._();

  factory SpeedTestResult.fromJson(Map<String, dynamic> json) =>
      _$SpeedTestResultFromJson(json);

  factory SpeedTestResult.error(String message) {
    return SpeedTestResult(
      downloadSpeed: 0,
      uploadSpeed: 0,
      latency: 0,
      timestamp: DateTime.now(),
      hasError: true,
      errorMessage: message,
    );
  }

  /// Get formatted download speed
  String get formattedDownloadSpeed {
    if (downloadSpeed < 1000.0) {
      return '${downloadSpeed.toStringAsFixed(2)} Mbps';
    } else {
      return '${(downloadSpeed / 1000).toStringAsFixed(2)} Gbps';
    }
  }

  /// Get formatted upload speed
  String get formattedUploadSpeed {
    if (uploadSpeed < 1000.0) {
      return '${uploadSpeed.toStringAsFixed(2)} Mbps';
    } else {
      return '${(uploadSpeed / 1000).toStringAsFixed(2)} Gbps';
    }
  }

  /// Get formatted latency
  String get formattedLatency => '${latency.toStringAsFixed(0)} ms';
}
