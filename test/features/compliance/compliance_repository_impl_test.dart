import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rgnets_fdk/core/services/websocket_compliance_cache_service.dart';
// ignore: unused_import — LocalFleetNodeResult is the constructor type now.
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/data/repositories/compliance_repository_impl.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';

const _ruleName = 'FDK Missing Installation Images';
const _ruleId = 1;
const _fleetNodeId = 7;

ComplianceRepositoryImpl _build({
  required MockClient client,
  WebSocketComplianceCacheService? cache,
  LocalFleetNodeResult fleetNode = const LocalFleetNodeResult(
      LocalFleetNodeStatus.known, _fleetNodeId),
}) {
  final cacheSvc = cache ?? WebSocketComplianceCacheService();
  return ComplianceRepositoryImpl(
    ruleName: _ruleName,
    ruleId: _ruleId,
    fleetNode: fleetNode,
    rest: ComplianceRestDataSource(
      siteUrl: 'example.test',
      apiKey: 'secret',
      client: client,
    ),
    cache: cacheSvc,
  );
}

void main() {
  group('ComplianceRepositoryImpl.bootstrap', () {
    test('returns unknown when no snapshot matches (200 + empty list)', () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      final state = await repo.bootstrap();
      expect(state, const ComplianceFeedState.unknown());
    });

    test('returns error("authentication failed") on 401', () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('', 401)),
      );
      final state = await repo.bootstrap();
      expect(state, const ComplianceFeedState.error('authentication failed'));
    });

    test('returns error("network unreachable") on 500', () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('', 500)),
      );
      final state = await repo.bootstrap();
      expect(state, const ComplianceFeedState.error('network unreachable'));
    });

    test('returns error on network exception', () async {
      final repo = _build(
        client: MockClient((_) async => throw Exception('connection refused')),
      );
      final state = await repo.bootstrap();
      state.when(
        unknown: () => fail('expected error'),
        loading: () => fail('expected error'),
        compliant: () => fail('expected error'),
        failures: (_) => fail('expected error'),
        indeterminate: () => fail('expected error'),
        error: (msg) => expect(msg, contains('network')),
      );
    });

    test('returns compliant when snapshot.compliant is true', () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('''
[{"id":50,"compliance_check_result_id":100,"compliance_rule_id":$_ruleId,
  "fleet_node_id":$_fleetNodeId,"compliant":true,"failures":[],
  "checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final state = await repo.bootstrap();
      expect(state, const ComplianceFeedState.compliant());
    });

    test('returns failures when snapshot.compliant is false with parseable entries',
        () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('''
[{"id":50,"compliance_check_result_id":100,"compliance_rule_id":$_ruleId,
  "fleet_node_id":$_fleetNodeId,"compliant":false,
  "failures":["Failure: {\\"device_type\\":\\"access_point\\",\\"id\\":1,\\"name\\":\\"x\\",\\"reason\\":\\"y\\"}"],
  "checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final state = await repo.bootstrap();
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

  group('ComplianceRepositoryImpl.watch', () {
    test('WS upsert pushes a fresh state via the stream', () async {
      final cache = WebSocketComplianceCacheService();
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
        cache: cache,
      );

      await repo.bootstrap();

      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      cache.applyUpsert({
        'id': 50,
        'compliance_check_result_id': 100,
        'compliance_rule_id': _ruleId,
        'fleet_node_id': _fleetNodeId,
        'compliant': true,
        'failures': <String>[],
        'checked_at': '2026-05-13T00:00:00Z',
      });

      await Future<void>.delayed(Duration.zero);
      expect(emissions, contains(const ComplianceFeedState.compliant()));

      await sub.cancel();
      repo.dispose();
    });

    test('older checked_at deltas are ignored (latest-wins merge)', () async {
      final cache = WebSocketComplianceCacheService();
      final repo = _build(
        client: MockClient((_) async => http.Response('''
[{"id":50,"compliance_check_result_id":100,"compliance_rule_id":$_ruleId,
  "fleet_node_id":$_fleetNodeId,"compliant":true,"failures":[],
  "checked_at":"2026-05-13T12:00:00Z"}]
''', 200)),
        cache: cache,
      );

      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      // An older delta should be ignored.
      cache.applyUpsert({
        'id': 50,
        'compliance_check_result_id': 100,
        'compliance_rule_id': _ruleId,
        'fleet_node_id': _fleetNodeId,
        'compliant': false,
        'failures': ['Failure: {"device_type":"access_point","id":1,"name":"x","reason":"y"}'],
        'checked_at': '2026-05-13T10:00:00Z',
      });

      await Future<void>.delayed(Duration.zero);
      expect(emissions, isEmpty);

      await sub.cancel();
      repo.dispose();
    });

    test('multiple snapshots: picks the one matching our (rule, fleet_node)', () async {
      final cache = WebSocketComplianceCacheService();
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
        cache: cache,
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      // Snapshot for a different fleet_node should be ignored.
      cache.applySnapshot([
        {
          'id': 60,
          'compliance_check_result_id': 200,
          'compliance_rule_id': _ruleId,
          'fleet_node_id': 999, // different node
          'compliant': false,
          'failures': ['Failure: {"device_type":"access_point","id":1,"name":"x","reason":"y"}'],
          'checked_at': '2026-05-13T12:00:00Z',
        },
        {
          'id': 50,
          'compliance_check_result_id': 100,
          'compliance_rule_id': _ruleId,
          'fleet_node_id': _fleetNodeId, // our node
          'compliant': true,
          'failures': <String>[],
          'checked_at': '2026-05-13T11:00:00Z',
        },
      ]);

      await Future<void>.delayed(Duration.zero);
      expect(emissions, [const ComplianceFeedState.compliant()]);

      await sub.cancel();
      repo.dispose();
    });
  });

  group('ComplianceRepositoryImpl.triggerRecheck', () {
    test('returns queued on 200', () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('{}', 200)),
      );
      expect(await repo.triggerRecheck(), TriggerOutcome.queued);
    });

    test('returns notFound on 422 (rxg wraps RecordNotFound)', () async {
      final repo = _build(
        client: MockClient((_) async => http.Response(
            "Compliance check failed: Couldn't find ComplianceRule with 'id'=1",
            422)),
      );
      expect(await repo.triggerRecheck(), TriggerOutcome.notFound);
    });
  });

  group('ComplianceRepositoryImpl.emitTriggerError — B3 / FM-7', () {
    test('unauthorized emits error("authentication failed") on watch stream',
        () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      repo.emitTriggerError(TriggerOutcome.unauthorized);
      await Future<void>.delayed(Duration.zero);

      expect(emissions,
          contains(const ComplianceFeedState.error('authentication failed')));
      await sub.cancel();
      repo.dispose();
    });

    test('networkError emits error("network unreachable") when no fresh snapshot',
        () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      repo.emitTriggerError(TriggerOutcome.networkError);
      await Future<void>.delayed(Duration.zero);

      expect(emissions,
          contains(const ComplianceFeedState.error('network unreachable')));
      await sub.cancel();
      repo.dispose();
    });

    test('queued is a no-op (does not push an error state)', () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      repo.emitTriggerError(TriggerOutcome.queued);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, isEmpty);
      await sub.cancel();
      repo.dispose();
    });

    test('notFound is a no-op (handled by lookup invalidation, not feed error)',
        () async {
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      repo.emitTriggerError(TriggerOutcome.notFound);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, isEmpty);
      await sub.cancel();
      repo.dispose();
    });
  });

  group('ComplianceRepositoryImpl.watch — robustness', () {
    test('malformed WS broadcast does not crash the stream', () async {
      final cache = WebSocketComplianceCacheService();
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
        cache: cache,
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      // Malformed: non-bool compliant + missing checked_at.
      cache.applyUpsert({
        'id': 50,
        'compliance_check_result_id': 100,
        'compliance_rule_id': _ruleId,
        'fleet_node_id': _fleetNodeId,
        'compliant': 'not a bool',
      });
      // Garbage row mixed in with a good one.
      cache.applySnapshot([
        {'this': 'is junk'},
        {
          'id': 51,
          'compliance_check_result_id': 101,
          'compliance_rule_id': _ruleId,
          'fleet_node_id': _fleetNodeId,
          'compliant': true,
          'failures': <String>[],
          'checked_at': '2026-05-13T00:00:00Z',
        },
      ]);

      await Future<void>.delayed(Duration.zero);
      // Only the good one made it through.
      expect(emissions, [const ComplianceFeedState.compliant()]);

      await sub.cancel();
      repo.dispose();
    });

    test('slice-4 data-bug fix: null payload fleet_node_id is accepted even when we know our id',
        () async {
      // The user's reported bug: standalone rxg writes
      // `fleet_node_id: null` on `compliance_check_results` while
      // `discoverLocalFleetNode` returns a real id. The pre-slice-4 filter
      // rejected those rows and FDK surfaced `unknown` instead of the
      // actual failures. Post-fix: null payload rows are accepted
      // unconditionally on the WS delta path.
      final cache = WebSocketComplianceCacheService();
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
        cache: cache,
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      cache.applyUpsert({
        'id': 60,
        'compliance_check_result_id': 200,
        'compliance_rule_id': _ruleId,
        'fleet_node_id': null,
        'compliant': true,
        'failures': <String>[],
        'checked_at': '2026-05-13T00:00:00Z',
      });

      await Future<void>.delayed(Duration.zero);
      expect(emissions, [const ComplianceFeedState.compliant()]);

      await sub.cancel();
      repo.dispose();
    });

    test('slice-4 data-bug fix: bootstrap accepts null payload fleet_node_id (REST path)',
        () async {
      // Mirror of the WS-path test above for the REST bootstrap path.
      // Standalone rxg returns a failure row with `fleet_node_id: null`
      // even though our discovery returned id=$_fleetNodeId.
      final repo = _build(
        client: MockClient((_) async => http.Response('''
[{"id":50,"compliance_check_result_id":100,"compliance_rule_id":$_ruleId,
  "fleet_node_id":null,"compliant":false,
  "failures":["Failure: {\\"device_type\\":\\"access_point\\",\\"id\\":2238,\\"name\\":\\"Ap in Bedroom\\",\\"reason\\":\\"missing installation images\\"}"],
  "checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final state = await repo.bootstrap();
      state.when(
        unknown: () => fail('expected failures (null fleet_node_id should be accepted)'),
        loading: () => fail('expected failures'),
        compliant: () => fail('expected failures'),
        failures: (list) {
          expect(list, hasLength(1));
          expect(list.single.deviceId, 2238);
          expect(list.single.reason, 'missing installation images');
        },
        indeterminate: () => fail('expected failures'),
        error: (msg) => fail('expected failures, got error: $msg'),
      );
      repo.dispose();
    });

    test('slice-4 data-bug fix: bootstrap still rejects rows with a different non-null fleet_node_id',
        () async {
      // Defensive: the relaxed filter must not start accepting rows that
      // belong to OTHER fleet nodes. Only nulls are unconditionally
      // accepted.
      final repo = _build(
        client: MockClient((_) async => http.Response('''
[{"id":50,"compliance_check_result_id":100,"compliance_rule_id":$_ruleId,
  "fleet_node_id":999,"compliant":false,
  "failures":["Failure: {\\"device_type\\":\\"access_point\\",\\"id\\":1,\\"name\\":\\"x\\",\\"reason\\":\\"y\\"}"],
  "checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final state = await repo.bootstrap();
      expect(state, const ComplianceFeedState.unknown());
      repo.dispose();
    });

    test('codex final blocker #4 (in-flight): WS upsert during REST bootstrap is captured', () async {
      final cache = WebSocketComplianceCacheService();
      // REST client that delays so we can fire a WS upsert while it's
      // in-flight — exercises the actual race the fix targets.
      var requestSeen = 0;
      final repo = _build(
        client: MockClient((_) async {
          requestSeen++;
          // Trigger the WS upsert AFTER bootstrap has registered its
          // listener (already done in _ensureSubscribed) but BEFORE the
          // REST round-trip completes.
          Future<void>.delayed(const Duration(milliseconds: 5), () {
            cache.applyUpsert({
              'id': 50,
              'compliance_check_result_id': 100,
              'compliance_rule_id': _ruleId,
              'fleet_node_id': _fleetNodeId,
              'compliant': true,
              'failures': <String>[],
              'checked_at': '2026-05-13T05:00:00Z',
            });
          });
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return http.Response('[]', 200);
        }),
        cache: cache,
      );

      final initial = await repo.bootstrap();
      expect(requestSeen, 1);
      // The WS upsert during the in-flight REST round-trip is captured by
      // the listener registered before REST starts, so the repo emits the
      // delivered state rather than `unknown` from the empty REST response.
      expect(initial, const ComplianceFeedState.compliant());
      repo.dispose();
    });

    test('codex final blocker #4: WS delta arriving during bootstrap is not lost', () async {
      final cache = WebSocketComplianceCacheService();
      // Seed the cache BEFORE the repository is constructed — simulates a
      // snapshot broadcast that landed before bootstrap finished.
      cache.applyUpsert({
        'id': 50,
        'compliance_check_result_id': 100,
        'compliance_rule_id': _ruleId,
        'fleet_node_id': _fleetNodeId,
        'compliant': true,
        'failures': <String>[],
        'checked_at': '2026-05-13T01:00:00Z',
      });

      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
        cache: cache,
      );

      // Bootstrap returns the snapshot replayed from the cache, NOT
      // unknown — the listener was registered before bootstrap so the
      // pre-populated cache entry is consumed.
      final initial = await repo.bootstrap();
      expect(initial, const ComplianceFeedState.compliant());
      repo.dispose();
    });

    test('latestKnownCheckedAt is advanced by WS deltas', () async {
      final cache = WebSocketComplianceCacheService();
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
        cache: cache,
      );
      await repo.bootstrap();
      repo.watch();

      expect(repo.latestKnownCheckedAt, isNull);

      cache.applyUpsert({
        'id': 50,
        'compliance_check_result_id': 100,
        'compliance_rule_id': _ruleId,
        'fleet_node_id': _fleetNodeId,
        'compliant': true,
        'failures': <String>[],
        'checked_at': '2026-05-13T00:00:00Z',
      });
      await Future<void>.delayed(Duration.zero);
      expect(repo.latestKnownCheckedAt, isNotNull);

      repo.dispose();
    });
  });

  group('ComplianceRepositoryImpl.dispose', () {
    test('is idempotent', () {
      final repo = _build(
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      repo.dispose();
      repo.dispose(); // must not throw
    });
  });
}
