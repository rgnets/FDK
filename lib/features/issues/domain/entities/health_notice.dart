import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_notice.freezed.dart';

/// Severity levels for health notices from the backend
enum HealthNoticeSeverity {
  fatal,
  critical,
  warning,
  notice;

  /// Returns severity weight for sorting (higher = more severe)
  int get weight {
    switch (this) {
      case HealthNoticeSeverity.fatal:
        return 4;
      case HealthNoticeSeverity.critical:
        return 3;
      case HealthNoticeSeverity.warning:
        return 2;
      case HealthNoticeSeverity.notice:
        return 1;
    }
  }

  /// Parse severity from backend string (case-insensitive)
  static HealthNoticeSeverity fromString(String value) {
    switch (value.toUpperCase()) {
      case 'FATAL':
        return HealthNoticeSeverity.fatal;
      case 'CRITICAL':
        return HealthNoticeSeverity.critical;
      case 'WARNING':
        return HealthNoticeSeverity.warning;
      case 'NOTICE':
        return HealthNoticeSeverity.notice;
      default:
        return HealthNoticeSeverity.notice;
    }
  }
}

@freezed
class HealthNotice with _$HealthNotice {
  const factory HealthNotice({
    required int id,
    required String name,
    required HealthNoticeSeverity severity,
    required String shortMessage,
    required DateTime createdAt, String? longMessage,
    DateTime? curedAt,
    String? deviceId,
    String? deviceName,
    String? roomName,
    String? deviceType, // 'access_point', 'switch', 'ont'
  }) = _HealthNotice;

  const HealthNotice._();

  /// Check if this notice is still active (not cured)
  bool get isActive => curedAt == null;

  /// Check if this notice is critical or fatal
  bool get isCritical =>
      severity == HealthNoticeSeverity.critical ||
      severity == HealthNoticeSeverity.fatal;

  /// Get duration since notice was created
  Duration get age => DateTime.now().difference(createdAt);

  /// Check if this notice is overdue (older than 24 hours)
  bool get isOverdue => age.inHours > 24;

  /// Whether this notice is a device-actionable FIELD issue worth showing to a
  /// field engineer, mirroring what the AT&T Field Engineer tool surfaces
  /// (offline, missing photos, missing speed test, config-sync). The rxg
  /// `health_notices` table also carries raw infrastructure/OS plumbing notices
  /// — e.g. "heartbeat timeout of 900s exceeded for /var/run/nokia..." — that
  /// ATT-FE never displays; those are filtered out.
  ///
  /// FDK-synthesized notices are always actionable: compliance-derived notices
  /// have negative ids (missing images / failed speed tests), and the offline
  /// synthesis uses the `fdk_device_offline_` name prefix.
  bool get isFieldActionable {
    if (id < 0 || name.startsWith('fdk_')) {
      return true;
    }
    final n = name.toLowerCase();
    final m = shortMessage.toLowerCase();
    // Device offline / unreachable (rxg uses `monitor_infrastructure_*` names).
    if (n.startsWith('monitor_infrastructure_') ||
        n.contains('offline') ||
        m.contains('offline')) {
      return true;
    }
    // Missing / failed speed test.
    if (n.contains('speed_test') || m.contains('speed test')) {
      return true;
    }
    // Configuration sync failure.
    if (n.contains('config_sync') ||
        m.contains('config sync') ||
        m.contains('configuration synchronization')) {
      return true;
    }
    return false;
  }
}

/// Extension for counting health notices by severity
extension HealthNoticeListExtension on List<HealthNotice> {
  /// Count notices by a specific severity
  int countBySeverity(HealthNoticeSeverity severity) =>
      where((n) => n.severity == severity).length;

  /// Get counts for all severities
  Map<HealthNoticeSeverity, int> get severityCounts => {
        for (final severity in HealthNoticeSeverity.values)
          severity: countBySeverity(severity),
      };

  /// Count of critical issues (fatal + critical)
  int get criticalCount =>
      countBySeverity(HealthNoticeSeverity.fatal) +
      countBySeverity(HealthNoticeSeverity.critical);
}
