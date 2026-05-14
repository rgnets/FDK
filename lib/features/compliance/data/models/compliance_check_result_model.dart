import 'package:rgnets_fdk/features/compliance/data/parsers/failure_line_parser.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';

/// Wire model for `ComplianceCheckResult` rows arriving from RXG (REST list
/// endpoint or WebSocket broadcasts).
///
/// We subscribe to results (not snapshots) because the snapshot table
/// delegates `compliance_rule_id` and `fleet_node_id` through its parent —
/// the auto-serialised JSON omits those columns. The result table stores
/// both as actual columns, so FDK can filter directly by `(rule_id,
/// fleet_node_id)` without a join fetch. Trade-off: result rows accumulate
/// as history; FDK de-dupes by `(rule_id, fleet_node_id)` newest
/// `checked_at` winning.
class ComplianceCheckResultModel {
  ComplianceCheckResultModel({
    required this.id,
    required this.complianceRuleId,
    required this.compliant,
    required this.failures,
    required this.checkedAt,
    this.fleetNodeId,
  });

  /// Result row primary key.
  final int id;
  final int complianceRuleId;
  final int? fleetNodeId;
  final bool compliant;
  final List<String> failures;
  final DateTime checkedAt;

  /// Hard-cast factory. Use [tryFromJson] for wire input.
  factory ComplianceCheckResultModel.fromJson(Map<String, dynamic> json) {
    return ComplianceCheckResultModel(
      id: json['id'] as int,
      complianceRuleId: json['compliance_rule_id'] as int,
      fleetNodeId: json['fleet_node_id'] as int?,
      compliant: json['compliant'] as bool,
      failures:
          (json['failures'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      checkedAt: DateTime.parse(json['checked_at'] as String).toUtc(),
    );
  }

  /// Tolerant parser. Returns null on any unexpected shape — missing or
  /// wrongly-typed columns, unparseable `checked_at`, etc. A malformed
  /// payload must never crash the UI isolate or break the stream.
  static ComplianceCheckResultModel? tryFromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'];
      final rid = json['compliance_rule_id'];
      final compliant = json['compliant'];
      final checkedAtRaw = json['checked_at'];
      if (id is! int ||
          rid is! int ||
          compliant is! bool ||
          checkedAtRaw is! String) {
        return null;
      }
      final checkedAt = DateTime.tryParse(checkedAtRaw);
      if (checkedAt == null) return null;
      final fleetNodeRaw = json['fleet_node_id'];
      return ComplianceCheckResultModel(
        id: id,
        complianceRuleId: rid,
        fleetNodeId: fleetNodeRaw is int ? fleetNodeRaw : null,
        compliant: compliant,
        failures: (json['failures'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        checkedAt: checkedAt.toUtc(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Maps the wire model to the FDK domain state.
  ///
  /// Authoritative rule (spec TR-4): `compliant` column is the sole source
  /// of truth. FDK must NOT derive compliance from `failures.length`.
  ///
  /// - `compliant: true` → [ComplianceFeedState.compliant], regardless of
  ///   `failures` content.
  /// - `compliant: false` with parseable failures → [ComplianceFeedState.failures].
  /// - `compliant: false` with empty / unparseable failures →
  ///   [ComplianceFeedState.indeterminate]. A non-compliant result with
  ///   nothing to show is a sign the script errored mid-run; surfacing
  ///   "everything OK" would silently hide the problem.
  ComplianceFeedState toFeedState({required String ruleName}) {
    if (compliant) return const ComplianceFeedState.compliant();
    final parsed = parseFailureLines(
      failures,
      ruleName: ruleName,
      ruleId: complianceRuleId,
      checkedAt: checkedAt,
    );
    if (parsed.isEmpty) return const ComplianceFeedState.indeterminate();
    return ComplianceFeedState.failures(parsed);
  }
}
