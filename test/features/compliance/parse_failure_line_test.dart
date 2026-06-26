import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';
import 'package:rgnets_fdk/features/compliance/data/parsers/failure_line_parser.dart';

void main() {
  group('parseFailureLine', () {
    test('parses a well-formed Failure: <json> line', () {
      const line =
          'Failure: {"device_type":"access_point","id":42,"name":"Lobby AP","reason":"missing installation images"}';

      final result = parseFailureLine(line, ruleName: 'r', ruleId: 1);

      expect(result, isNotNull);
      expect(result!.deviceType, 'access_point');
      expect(result.deviceId, 42);
      expect(result.deviceName, 'Lobby AP');
      expect(result.reason, 'missing installation images');
      expect(result.ruleName, 'r');
    });

    test('survives an em-dash inside the AP name (JSON escapes it)', () {
      const line =
          'Failure: {"device_type":"access_point","id":7,"name":"AP — Lobby","reason":"latest speed test failed"}';

      final result = parseFailureLine(line, ruleName: 'r', ruleId: 1);

      expect(result, isNotNull);
      expect(result!.deviceName, 'AP — Lobby');
      expect(result.reason, 'latest speed test failed');
    });

    test('survives a JSON-escaped newline inside the AP name', () {
      const line =
          'Failure: {"device_type":"access_point","id":1,"name":"Line1\\nLine2","reason":"missing installation images"}';

      final result = parseFailureLine(line, ruleName: 'r', ruleId: 1);

      expect(result, isNotNull);
      expect(result!.deviceName, 'Line1\nLine2');
    });

    test('survives a unicode AP name', () {
      const line =
          'Failure: {"device_type":"access_point","id":99,"name":"Café — Lobby 北","reason":"missing installation images"}';

      final result = parseFailureLine(line, ruleName: 'r', ruleId: 1);

      expect(result, isNotNull);
      expect(result!.deviceName, 'Café — Lobby 北');
    });

    test('parses a room-level pms_room coverage failure row', () {
      const line =
          'Failure: {"device_type":"pms_room","id":245,"name":"7206","reason":"latest coverage speed test failed","download_mbps":"","upload_mbps":""}';

      final result = parseFailureLine(line, ruleName: 'r', ruleId: 1);

      expect(result, isNotNull);
      expect(result!.deviceType, 'pms_room');
      expect(result.deviceId, 245);
      expect(result.deviceName, '7206');
      expect(result.reason, 'latest coverage speed test failed');
    });

    test('returns null for a malformed JSON body', () {
      const line = 'Failure: {not really json}';

      expect(parseFailureLine(line, ruleName: 'r', ruleId: 1), isNull);
    });

    test('returns null when JSON is missing required keys', () {
      const line = 'Failure: {"device_type":"access_point","id":42}';

      expect(parseFailureLine(line, ruleName: 'r', ruleId: 1), isNull);
    });

    test('returns null when id is non-integer', () {
      const line =
          'Failure: {"device_type":"access_point","id":"forty-two","name":"x","reason":"y"}';

      expect(parseFailureLine(line, ruleName: 'r', ruleId: 1), isNull);
    });

    test('returns null for lines that are not Failure markers', () {
      expect(parseFailureLine('Pass: ...', ruleName: 'r', ruleId: 1), isNull);
      expect(parseFailureLine('Warning: foo', ruleName: 'r', ruleId: 1), isNull);
      expect(parseFailureLine('arbitrary line', ruleName: 'r', ruleId: 1), isNull);
    });

    test('accepts the Fail: alias (RXG parser treats it as Failure)', () {
      const line =
          'Fail: {"device_type":"access_point","id":1,"name":"x","reason":"y"}';

      final result = parseFailureLine(line, ruleName: 'r', ruleId: 1);

      expect(result, isNotNull);
      expect(result!.deviceId, 1);
    });

    test('tolerates leading whitespace before the marker', () {
      const line =
          '   Failure: {"device_type":"access_point","id":3,"name":"x","reason":"y"}';

      final result = parseFailureLine(line, ruleName: 'r', ruleId: 1);

      expect(result, isNotNull);
      expect(result!.deviceId, 3);
    });
  });

  group('parseFailureLines (snapshot.failures array)', () {
    test('parses a list, skipping malformed entries', () {
      const lines = [
        'Failure: {"device_type":"access_point","id":1,"name":"A","reason":"x"}',
        'malformed',
        'Failure: {"device_type":"access_point","id":2,"name":"B","reason":"y"}',
      ];

      final result = parseFailureLines(lines, ruleName: 'r', ruleId: 1);

      expect(result, hasLength(2));
      expect(result.map((f) => f.deviceId), containsAll([1, 2]));
    });

    test('returns empty list for empty input', () {
      expect(parseFailureLines(const [], ruleName: 'r', ruleId: 1), isEmpty);
    });

    test('stamps every entry with the supplied ruleName', () {
      const lines = [
        'Failure: {"device_type":"access_point","id":1,"name":"A","reason":"x"}',
      ];

      final result =
          parseFailureLines(lines, ruleName: 'my-rule', ruleId: 1);

      expect(result.single.ruleName, 'my-rule');
    });
  });

  group('ComplianceFailure equality', () {
    test('two failures with the same fields are equal', () {
      final a = ComplianceFailure(
        deviceType: 'access_point',
        deviceId: 1,
        deviceName: 'x',
        reason: 'y',
        ruleName: 'r',
        ruleId: 1,
        checkedAt: DateTime.utc(2026, 5, 13),
      );
      final b = ComplianceFailure(
        deviceType: 'access_point',
        deviceId: 1,
        deviceName: 'x',
        reason: 'y',
        ruleName: 'r',
        ruleId: 1,
        checkedAt: DateTime.utc(2026, 5, 13),
      );
      expect(a, equals(b));
    });
  });
}
