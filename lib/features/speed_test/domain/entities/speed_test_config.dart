import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_test_config.freezed.dart';
part 'speed_test_config.g.dart';

/// Safely converts a value to int, handling strings and nulls
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Safely converts a value to double, handling strings and nulls
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

@freezed
class SpeedTestConfig with _$SpeedTestConfig {
  const factory SpeedTestConfig({
    @JsonKey(fromJson: _toInt) int? id,
    String? name,
    @JsonKey(name: 'test_type') String? testType,
    String? target,
    @JsonKey(fromJson: _toInt) int? port,
    @JsonKey(name: 'iperf_protocol') String? iperfProtocol,
    @JsonKey(name: 'min_download_mbps', fromJson: _toDouble)
    double? minDownloadMbps,
    @JsonKey(name: 'min_upload_mbps', fromJson: _toDouble)
    double? minUploadMbps,
    @JsonKey(fromJson: _toInt) int? period,
    @JsonKey(name: 'period_unit') String? periodUnit,
    @JsonKey(name: 'starts_at') DateTime? startsAt,
    @JsonKey(name: 'next_check_at') DateTime? nextCheckAt,
    @JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,
    @Default(false) bool passing,
    @JsonKey(name: 'last_result') String? lastResult,
    @JsonKey(name: 'max_failures', fromJson: _toInt) int? maxFailures,
    @JsonKey(name: 'disable_uplink_on_failure')
    @Default(false)
    bool disableUplinkOnFailure,
    @JsonKey(name: 'sample_size_pct', fromJson: _toInt) int? sampleSizePct,
    @JsonKey(name: 'psk_override') String? pskOverride,
    @JsonKey(name: 'wlan_id', fromJson: _toInt) int? wlanId,
    String? note,
    String? scratch,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SpeedTestConfig;

  const SpeedTestConfig._();

  factory SpeedTestConfig.fromJson(Map<String, dynamic> json) =>
      _$SpeedTestConfigFromJson(json);

  /// Check if this is an iperf3 test
  bool get isIperfTest =>
      testType?.toLowerCase() == 'iperf3' || testType?.toLowerCase() == 'iperf';

  /// Check if this uses UDP protocol
  bool get isUdp => iperfProtocol?.toLowerCase() == 'udp';

  /// Check if this uses TCP protocol
  bool get isTcp => iperfProtocol?.toLowerCase() == 'tcp';

  /// Get the server host (alias for target)
  String? get serverHost => target;

  /// Get the server port with default fallback
  int get serverPort => port ?? 5201;

  /// Get the test duration from period
  int? get durationSeconds => period;

  /// Check if test is currently scheduled
  bool get isScheduled =>
      nextCheckAt != null && nextCheckAt!.isAfter(DateTime.now());

  /// Check if test has ever run
  bool get hasRun => lastCheckedAt != null;

  /// Get time until next test
  Duration? get timeUntilNextTest {
    if (nextCheckAt == null) return null;
    final now = DateTime.now();
    if (nextCheckAt!.isBefore(now)) return null;
    return nextCheckAt!.difference(now);
  }

  /// Get time since last test
  Duration? get timeSinceLastTest {
    if (lastCheckedAt == null) return null;
    return DateTime.now().difference(lastCheckedAt!);
  }
}
