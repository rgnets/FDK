import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';

void main() {
  group('ComplianceFeedState mapping (snapshot → state)', () {
    final aFailure = ComplianceFailure(
      deviceType: 'access_point',
      deviceId: 1,
      deviceName: 'x',
      reason: 'missing installation images',
      ruleName: 'FDK Missing Installation Images',
      ruleId: 11,
      checkedAt: DateTime.utc(2026, 5, 13),
    );

    test('compliant snapshot → ComplianceFeedState.compliant regardless of failures content', () {
      const state = ComplianceFeedState.compliant();
      expect(state, isA<ComplianceFeedState>());
      state.when(
        unknown: () => fail('expected compliant'),
        loading: () => fail('expected compliant'),
        compliant: () {},
        failures: (_) => fail('expected compliant'),
        indeterminate: () => fail('expected compliant'),
        error: (_) => fail('expected compliant'),
      );
    });

    test('failures(list) variant carries the failure list', () {
      final state = ComplianceFeedState.failures([aFailure]);
      state.when(
        unknown: () => fail('expected failures'),
        loading: () => fail('expected failures'),
        compliant: () => fail('expected failures'),
        failures: (list) => expect(list, [aFailure]),
        indeterminate: () => fail('expected failures'),
        error: (_) => fail('expected failures'),
      );
    });

    test('unknown is distinguishable from compliant', () {
      const unknown = ComplianceFeedState.unknown();
      const compliant = ComplianceFeedState.compliant();
      expect(unknown, isNot(equals(compliant)));
    });

    test('indeterminate is distinguishable from compliant and from failures([])', () {
      const indet = ComplianceFeedState.indeterminate();
      const compliant = ComplianceFeedState.compliant();
      const noFailures = ComplianceFeedState.failures([]);
      expect(indet, isNot(equals(compliant)));
      expect(indet, isNot(equals(noFailures)));
    });

    test('error carries a message', () {
      const state = ComplianceFeedState.error('boom');
      state.when(
        unknown: () => fail('expected error'),
        loading: () => fail('expected error'),
        compliant: () => fail('expected error'),
        failures: (_) => fail('expected error'),
        indeterminate: () => fail('expected error'),
        error: (msg) => expect(msg, 'boom'),
      );
    });

    test('loading is a singleton-equal value', () {
      const a = ComplianceFeedState.loading();
      const b = ComplianceFeedState.loading();
      expect(a, equals(b));
    });
  });
}
