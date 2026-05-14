import 'dart:convert';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';

const _tag = 'parseFailureLine';

/// Optional `Failure:` / `Fail:` / `Error:` prefix (RXG's
/// `ComplianceOutputParser` accepts all three as aliases). The prefix is
/// optional because rxg stores only the captured group after the colon —
/// `failures << $1` in the parser — so the persisted array elements come
/// back as raw JSON strings without the prefix. We still match the prefix
/// defensively in case a script bypasses the parser or a future rxg
/// version changes the storage shape.
final _failureMarker =
    RegExp(r'^\s*(?:(?:Failure|Fail|Error):\s*)?(.*)$', caseSensitive: false);

/// Parses one line from `ComplianceCheckResult.failures`.
///
/// Backend scripts emit `Failure: <json>` lines where `<json>` carries
/// `device_type`, `id`, `name`, and `reason`. The rxg's parser strips the
/// `Failure:` prefix before persisting, so each array element is just the
/// JSON portion.
///
/// Returns `null` (and logs a warning) for any line that doesn't decode as
/// JSON or is missing a required key. The caller should skip and continue
/// rather than fail the whole snapshot.
ComplianceFailure? parseFailureLine(
  String line, {
  required String ruleName,
  required int ruleId,
  DateTime? checkedAt,
}) {
  final match = _failureMarker.firstMatch(line);
  if (match == null) return null;

  final body = match.group(1)?.trim();
  if (body == null || body.isEmpty) return null;

  final dynamic decoded;
  try {
    decoded = jsonDecode(body);
  } catch (e) {
    LoggerService.warning('JSON decode failed: $e', tag: _tag);
    return null;
  }

  if (decoded is! Map<String, dynamic>) {
    LoggerService.warning('expected JSON object, got ${decoded.runtimeType}', tag: _tag);
    return null;
  }

  final deviceType = decoded['device_type'];
  final id = decoded['id'];
  final name = decoded['name'];
  final reason = decoded['reason'];

  if (deviceType is! String || id is! int || name is! String || reason is! String) {
    LoggerService.warning('required keys missing or wrong type', tag: _tag);
    return null;
  }

  return ComplianceFailure(
    deviceType: deviceType,
    deviceId: id,
    deviceName: name,
    reason: reason,
    ruleName: ruleName,
    ruleId: ruleId,
    checkedAt: checkedAt ?? DateTime.now().toUtc(),
  );
}

/// Parses every entry in the `failures` JSONB array. Malformed entries are
/// skipped (each logs a warning via [parseFailureLine]).
List<ComplianceFailure> parseFailureLines(
  List<String> lines, {
  required String ruleName,
  required int ruleId,
  DateTime? checkedAt,
}) {
  final out = <ComplianceFailure>[];
  for (final line in lines) {
    final parsed = parseFailureLine(
      line,
      ruleName: ruleName,
      ruleId: ruleId,
      checkedAt: checkedAt,
    );
    if (parsed != null) out.add(parsed);
  }
  return out;
}
