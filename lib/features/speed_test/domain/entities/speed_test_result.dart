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
    // PMS Room integration fields
    int? id,                          // Result ID from API
    int? speedTestId,                 // Which speed test config
    int? pmsRoomId,                   // PMS room ID
    String? roomType,                 // Coverage type (e.g., "master bedroom")
    int? accessPointId,               // Target AP
    int? testedViaAccessPointId,      // AP used for testing
    int? testedViaMediaConverterId,   // Media converter used for testing
    int? uplinkId,                    // Uplink ID
    @Default(true) bool isApplicable, // For "Not Applicable" marking
    bool? passed,                     // Explicit pass/fail status
    DateTime? completedAt,            // When test completed
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
