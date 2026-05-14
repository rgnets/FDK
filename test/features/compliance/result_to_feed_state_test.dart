import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/data/models/compliance_check_result_model.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';

void main() {
  group('ComplianceCheckResultModel.toFeedState', () {
    const ruleName = 'FDK Missing Installation Images';

    test('compliant: true → ComplianceFeedState.compliant (failures content ignored)', () {
      final model = ComplianceCheckResultModel(
        id: 100,
        complianceRuleId: 1,
        fleetNodeId: 7,
        compliant: true,
        failures: const [
          'Failure: {"device_type":"access_point","id":1,"name":"x","reason":"y"}',
        ],
        checkedAt: DateTime.utc(2026, 5, 13),
      );

      expect(model.toFeedState(ruleName: ruleName),
          const ComplianceFeedState.compliant());
    });

    test('compliant: false with parseable failures → ComplianceFeedState.failures([...])', () {
      final model = ComplianceCheckResultModel(
        id: 100,
        complianceRuleId: 1,
        fleetNodeId: 7,
        compliant: false,
        failures: const [
          'Failure: {"device_type":"access_point","id":1,"name":"A","reason":"missing installation images"}',
          'Failure: {"device_type":"access_point","id":2,"name":"B","reason":"missing installation images"}',
        ],
        checkedAt: DateTime.utc(2026, 5, 13),
      );

      final state = model.toFeedState(ruleName: ruleName);
      state.when(
        unknown: () => fail('expected failures'),
        loading: () => fail('expected failures'),
        compliant: () => fail('expected failures'),
        failures: (list) {
          expect(list, hasLength(2));
          expect(list.map((f) => f.deviceId), containsAll([1, 2]));
        },
        indeterminate: () => fail('expected failures'),
        error: (_) => fail('expected failures'),
      );
    });

    test('compliant: false with empty failures → ComplianceFeedState.indeterminate', () {
      final model = ComplianceCheckResultModel(
        id: 100,
        complianceRuleId: 1,
        fleetNodeId: 7,
        compliant: false,
        failures: const [],
        checkedAt: DateTime.utc(2026, 5, 13),
      );

      expect(model.toFeedState(ruleName: ruleName),
          const ComplianceFeedState.indeterminate());
    });

    test('compliant: false with only malformed failures → ComplianceFeedState.indeterminate', () {
      final model = ComplianceCheckResultModel(
        id: 100,
        complianceRuleId: 1,
        fleetNodeId: 7,
        compliant: false,
        failures: const ['not json', 'still not json'],
        checkedAt: DateTime.utc(2026, 5, 13),
      );

      expect(model.toFeedState(ruleName: ruleName),
          const ComplianceFeedState.indeterminate());
    });

    test('compliant: false with mix of parseable + malformed → failures([parseable subset])', () {
      final model = ComplianceCheckResultModel(
        id: 100,
        complianceRuleId: 1,
        fleetNodeId: 7,
        compliant: false,
        failures: const [
          'Failure: {"device_type":"access_point","id":1,"name":"A","reason":"x"}',
          'not json',
        ],
        checkedAt: DateTime.utc(2026, 5, 13),
      );

      final state = model.toFeedState(ruleName: ruleName);
      state.when(
        unknown: () => fail('expected failures'),
        loading: () => fail('expected failures'),
        compliant: () => fail('expected failures'),
        failures: (list) => expect(list.single.deviceId, 1),
        indeterminate: () => fail('expected failures'),
        error: (_) => fail('expected failures'),
      );
    });
  });

  group('ComplianceCheckResultModel.fromJson', () {
    test('parses a server response containing the fleet_node_id column', () {
      final json = {
        'id': 100,
        'compliance_rule_id': 1,
        'fleet_node_id': 7,
        'compliant': false,
        'failures': [
          'Failure: {"device_type":"access_point","id":1,"name":"x","reason":"y"}',
        ],
        'checked_at': '2026-05-13T00:00:00Z',
      };

      final model = ComplianceCheckResultModel.fromJson(json);

      expect(model.id, 100);
      expect(model.complianceRuleId, 1);
      expect(model.fleetNodeId, 7);
      expect(model.compliant, isFalse);
      expect(model.failures, hasLength(1));
    });

    test('parses with fleet_node_id absent (server omitted; standalone fallback path)', () {
      final json = {
        'id': 100,
        'compliance_rule_id': 1,
        'compliant': true,
        'failures': <String>[],
        'checked_at': '2026-05-13T00:00:00Z',
      };

      final model = ComplianceCheckResultModel.fromJson(json);

      expect(model.fleetNodeId, isNull);
    });
  });
}
