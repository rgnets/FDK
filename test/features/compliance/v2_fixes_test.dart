import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rgnets_fdk/core/services/websocket_compliance_cache_service.dart';
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/data/repositories/compliance_repository_impl.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';

void main() {
  group('codex v2 blocker #1 — siteUrl normalization', () {
    test('strips https:// prefix; URL is not double-scheme', () async {
      late Uri capturedUri;
      final ds = ComplianceRestDataSource(
        siteUrl: 'https://my-rxg.example.com', // stored with scheme
        apiKey: 'secret',
        client: MockClient((req) async {
          capturedUri = req.url;
          return http.Response('[]', 200);
        }),
      );
      await ds.lookupRuleId('anything');
      expect(capturedUri.scheme, 'https');
      expect(capturedUri.host, 'my-rxg.example.com');
      expect(capturedUri.toString(),
          isNot(contains('https://https')));
    });

    test('strips http:// prefix and trailing slash', () async {
      late Uri capturedUri;
      final ds = ComplianceRestDataSource(
        siteUrl: 'http://my-rxg.example.com/',
        apiKey: 'secret',
        client: MockClient((req) async {
          capturedUri = req.url;
          return http.Response('[]', 200);
        }),
      );
      await ds.lookupRuleId('anything');
      expect(capturedUri.host, 'my-rxg.example.com');
      expect(capturedUri.path.startsWith('//'), isFalse);
    });

    test('bare hostname works (no scheme)', () async {
      late Uri capturedUri;
      final ds = ComplianceRestDataSource(
        siteUrl: 'my-rxg.example.com',
        apiKey: 'secret',
        client: MockClient((req) async {
          capturedUri = req.url;
          return http.Response('[]', 200);
        }),
      );
      await ds.lookupRuleId('anything');
      expect(capturedUri.host, 'my-rxg.example.com');
    });
  });

  group('codex v2 blocker #2 — LocalFleetNodeResult status discovery', () {
    test('single row → standalone (allows missing fleet_node_id in payload)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'x',
        apiKey: 'x',
        client: MockClient((_) async => http.Response(
              '[{"id":7,"name":"only-node"}]',
              200,
            )),
      );
      final result = await ds.discoverLocalFleetNode();
      expect(result.status, LocalFleetNodeStatus.standalone);
      expect(result.id, 7);
      expect(result.allowMissingFleetNode, isTrue);
    });

    test('multi-row + is_self marker → known(id) (strict match)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'x',
        apiKey: 'x',
        client: MockClient((_) async => http.Response(
              '[{"id":1,"name":"a"},{"id":2,"name":"b","is_self":true}]',
              200,
            )),
      );
      final result = await ds.discoverLocalFleetNode();
      expect(result.status, LocalFleetNodeStatus.known);
      expect(result.id, 2);
      expect(result.allowMissingFleetNode, isFalse);
    });

    test('lookup failure (5xx) → unknown (must NOT enable rule-only fallback)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'x',
        apiKey: 'x',
        client: MockClient((_) async => http.Response('', 503)),
      );
      final result = await ds.discoverLocalFleetNode();
      expect(result.status, LocalFleetNodeStatus.unknown);
      expect(result.allowMissingFleetNode, isFalse);
      expect(result.isResolved, isFalse);
    });

    test('malformed body → unknown (never throws)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'x',
        apiKey: 'x',
        client: MockClient((_) async => http.Response('not json', 200)),
      );
      final result = await ds.discoverLocalFleetNode();
      expect(result.status, LocalFleetNodeStatus.unknown);
    });

    test('repository with status=unknown is not built (caller checks isResolved)', () {
      // This is a contract test: a repository SHOULD NOT be built when
      // status is unknown. The provider enforces this; here we verify the
      // contract on the result object itself.
      const unknown = LocalFleetNodeResult(LocalFleetNodeStatus.unknown);
      expect(unknown.isResolved, isFalse);
      expect(unknown.allowMissingFleetNode, isFalse);
    });
  });

  group('codex v2 blocker #3 — bootstrap tolerates malformed 200 body', () {
    test('malformed JSON in 200 response → networkError, not exception', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'x',
        apiKey: 'x',
        client: MockClient((_) async => http.Response('totally invalid', 200)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.networkError);
    });
  });

  group('codex v2 blocker #4 — speed-test trigger baseline', () {
    test(
        'slice-4 fix: repository in fleet-manager mode ALSO accepts null '
        'fleet_node_id (rxg writes null for results produced locally)',
        () async {
      // Pre-slice-4 behavior: known-fleet-node repos rejected null payloads.
      // Slice-4 fix: null-payload rows are accepted regardless of discovery
      // status because the rxg writes `fleet_node_id: null` for results
      // produced by checks running on the local rxg itself — and those are
      // always "for us." See compliance_rest_data_source.dart bootstrapResult
      // doc-comment for the full rationale.
      final cache = WebSocketComplianceCacheService();
      final repo = ComplianceRepositoryImpl(
        ruleName: 'r',
        ruleId: 1,
        fleetNode: const LocalFleetNodeResult(LocalFleetNodeStatus.known, 7),
        rest: ComplianceRestDataSource(
          siteUrl: 'x',
          apiKey: 'x',
          client: MockClient((_) async => http.Response('[]', 200)),
        ),
        cache: cache,
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      cache.applyUpsert({
        'id': 50,
        'compliance_check_result_id': 100,
        'compliance_rule_id': 1,
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

    test(
        'slice-4 fix: known-fleet-node repos still reject rows with a '
        'DIFFERENT non-null fleet_node_id',
        () async {
      // Inverse sanity: payload `fleet_node_id` that's populated and
      // differs from ours still means "delegated to another node" and must
      // not surface.
      final cache = WebSocketComplianceCacheService();
      final repo = ComplianceRepositoryImpl(
        ruleName: 'r',
        ruleId: 1,
        fleetNode: const LocalFleetNodeResult(LocalFleetNodeStatus.known, 7),
        rest: ComplianceRestDataSource(
          siteUrl: 'x',
          apiKey: 'x',
          client: MockClient((_) async => http.Response('[]', 200)),
        ),
        cache: cache,
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      cache.applyUpsert({
        'id': 51,
        'compliance_check_result_id': 101,
        'compliance_rule_id': 1,
        'fleet_node_id': 999,
        'compliant': true,
        'failures': <String>[],
        'checked_at': '2026-05-13T00:00:00Z',
      });
      await Future<void>.delayed(Duration.zero);
      expect(emissions, isEmpty);
      await sub.cancel();
      repo.dispose();
    });

    test('repository in standalone mode accepts null fleet_node_id', () async {
      final cache = WebSocketComplianceCacheService();
      final repo = ComplianceRepositoryImpl(
        ruleName: 'r',
        ruleId: 1,
        fleetNode:
            const LocalFleetNodeResult(LocalFleetNodeStatus.standalone, 7),
        rest: ComplianceRestDataSource(
          siteUrl: 'x',
          apiKey: 'x',
          client: MockClient((_) async => http.Response('[]', 200)),
        ),
        cache: cache,
      );
      await repo.bootstrap();
      final emissions = <ComplianceFeedState>[];
      final sub = repo.watch().listen(emissions.add);

      cache.applyUpsert({
        'id': 50,
        'compliance_check_result_id': 100,
        'compliance_rule_id': 1,
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
  });
}
