import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_counts.freezed.dart';

@freezed
class HealthCounts with _$HealthCounts {
  const factory HealthCounts({
    @Default(0) int total,
    @Default(0) int fatal,
    @Default(0) int critical,
    @Default(0) int warning,
    @Default(0) int notice,
  }) = _HealthCounts;

  const HealthCounts._();

  /// Calculate health score (100 - penalties)
  /// Formula: 100 - (fatal*25 + critical*10 + warning*5 + notice*1)
  double get healthScore {
    final penalties = (fatal * 25) + (critical * 10) + (warning * 5) + (notice * 1);
    return (100 - penalties).clamp(0, 100).toDouble();
  }

  /// Check if there are any critical or fatal issues
  bool get hasCritical => fatal > 0 || critical > 0;

  /// Check if there are any issues at all
  bool get hasAny => total > 0;

  /// Get the highest severity level present
  String get highestSeverity {
    if (fatal > 0) return 'FATAL';
    if (critical > 0) return 'CRITICAL';
    if (warning > 0) return 'WARNING';
    if (notice > 0) return 'NOTICE';
    return 'NONE';
  }

  /// Add two HealthCounts together
  HealthCounts operator +(HealthCounts other) {
    return HealthCounts(
      total: total + other.total,
      fatal: fatal + other.fatal,
      critical: critical + other.critical,
      warning: warning + other.warning,
      notice: notice + other.notice,
    );
  }

  /// Create an empty HealthCounts
  static HealthCounts zero() => const HealthCounts();
}
