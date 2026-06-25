import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';

void main() {
  group('ComplianceRestDataSource — trigger error mapping', () {
    test('200 → TriggerOutcome.queued', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('{}', 200)),
      );
      expect(await ds.triggerCheckNow(99), TriggerOutcome.queued);
    });

    test('422 → TriggerOutcome.notFound (rxg wraps RecordNotFound as 422)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
            "Compliance check failed: Couldn't find ComplianceRule with 'id'=99",
            422)),
      );
      expect(await ds.triggerCheckNow(99), TriggerOutcome.notFound);
    });

    test('429 → TriggerOutcome.queued (in-flight check produces the row we want anyway)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
            "A compliance check for '<name>' is already running",
            429)),
      );
      expect(await ds.triggerCheckNow(99), TriggerOutcome.queued);
    });

    test('401 → TriggerOutcome.unauthorized', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 401)),
      );
      expect(await ds.triggerCheckNow(99), TriggerOutcome.unauthorized);
    });

    test('500 → TriggerOutcome.networkError', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 500)),
      );
      expect(await ds.triggerCheckNow(99), TriggerOutcome.networkError);
    });

    test('network exception → TriggerOutcome.networkError', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async {
          throw Exception('connection refused');
        }),
      );
      expect(await ds.triggerCheckNow(99), TriggerOutcome.networkError);
    });
  });

  group('ComplianceRestDataSource — lookup', () {
    test('lookupRuleId returns LookupFound with matching row id', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
              '[{"id":7,"name":"FDK Missing Installation Images"},'
              '{"id":8,"name":"Other Rule"}]',
              200,
            )),
      );
      final result = await ds.lookupRuleId('FDK Missing Installation Images');
      expect(result, isA<LookupFound>());
      expect((result as LookupFound).id, 7);
    });

    test('lookupRuleId returns LookupMissing when name not found', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      expect(await ds.lookupRuleId('Anything'), isA<LookupMissing>());
    });

    test('lookupRuleId handles wrapped {records: [...]} response shape', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
              '{"records":[{"id":42,"name":"target"}]}',
              200,
            )),
      );
      final result = await ds.lookupRuleId('target');
      expect(result, isA<LookupFound>());
      expect((result as LookupFound).id, 42);
    });

    test('lookupRuleId handles paginated {results: [...], count, page} response shape', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
              '{"count":1,"page":1,"page_size":30,"total_pages":1,'
              '"results":[{"id":7,"name":"FDK Missing Installation Images"}]}',
              200,
            )),
      );
      final result =
          await ds.lookupRuleId('FDK Missing Installation Images');
      expect(result, isA<LookupFound>());
      expect((result as LookupFound).id, 7);
    });

    test('lookupRuleId 401 → LookupUnauthorized (FM-7 B3)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 401)),
      );
      expect(await ds.lookupRuleId('Anything'), isA<LookupUnauthorized>());
    });

    test('lookupRuleId 403 → LookupMissing (admin scaffold uses 403 for missing/not-triggerable)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 403)),
      );
      expect(await ds.lookupRuleId('Anything'), isA<LookupMissing>());
    });

    test('lookupRuleId 404 → LookupMissing', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 404)),
      );
      expect(await ds.lookupRuleId('Anything'), isA<LookupMissing>());
    });

    test('lookupRuleId 500 → LookupNetworkError', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 500)),
      );
      expect(await ds.lookupRuleId('Anything'), isA<LookupNetworkError>());
    });

    test('lookupRuleId socket exception → LookupNetworkError with scrubbed message', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async {
          throw Exception('connection refused at api_key=SECRET_TOKEN');
        }),
      );
      final result = await ds.lookupRuleId('Anything');
      expect(result, isA<LookupNetworkError>());
      expect((result as LookupNetworkError).message,
          isNot(contains('SECRET_TOKEN')));
      expect(result.message, contains('api_key=[redacted]'));
    });
  });

  group('ComplianceRestDataSource — discoverLocalFleetNode', () {
    test('empty results list → standalone with null id', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
              '{"count":0,"page":1,"page_size":30,"total_pages":0,"results":[]}',
              200,
            )),
      );
      final result = await ds.discoverLocalFleetNode();
      expect(result.status, LocalFleetNodeStatus.standalone);
      expect(result.id, isNull);
      expect(result.allowMissingFleetNode, isTrue);
    });

    test('single result → standalone with that id', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
              '{"count":1,"page":1,"page_size":30,"total_pages":1,'
              '"results":[{"id":12,"name":"local"}]}',
              200,
            )),
      );
      final result = await ds.discoverLocalFleetNode();
      expect(result.status, LocalFleetNodeStatus.standalone);
      expect(result.id, 12);
    });
  });

  group('ComplianceRestDataSource — bootstrapResult', () {
    test('requests newest-first ordering so page 1 holds the current snapshot', () async {
      Uri? requested;
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((req) async {
          requested = req.url;
          return http.Response(jsonEncodedSnapshotList(), 200);
        }),
      );
      await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(requested, isNotNull);
      expect(requested!.queryParameters['ordering'], '-checked_at');
    });

    test('returns found + matching snapshot for (rule, fleet_node)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
              jsonEncodedSnapshotList(),
              200,
            )),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.found);
      expect(result.snapshot!.complianceRuleId, 1);
      expect(result.snapshot!.fleetNodeId, 7);
      expect(result.snapshot!.compliant, isFalse);
    });

    test('rule-only match when fleetNodeId is null (standalone rxg)', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response(
              jsonEncodedSnapshotList(),
              200,
            )),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: null);
      expect(result.status, BootstrapStatus.found);
      expect(result.snapshot!.complianceRuleId, 1);
    });

    test('absent when no snapshot matches', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.absent);
      expect(result.snapshot, isNull);
    });

    test('401 → unauthorized', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 401)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.unauthorized);
    });

    test('500 → networkError', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('', 500)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.networkError);
    });

    test(
        'slice-4 fix: row with null fleet_node_id is ALWAYS accepted, '
        'even when fleetNodeId is known',
        () async {
      // The standalone-rxg path writes `fleet_node_id: null` on result rows
      // produced by checks running on the local rxg itself. Even when FDK's
      // local fleet_node discovery returned a specific id, those null-payload
      // rows are "for us" and must surface as failures (not get filtered out
      // as "delegated to another node"). This is the user's reported bug
      // (2 admin-view failure rows ignored by FDK, surfacing as `unknown`).
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('''
[{"id":99,"compliance_rule_id":1,
  "fleet_node_id":null,"compliant":true,"failures":[],
  "checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.found);
      expect(result.snapshot!.id, 99);
    });

    test(
        'slice-4 fix: row with a different non-null fleet_node_id is rejected',
        () async {
      // Sanity check the inverse: a row whose payload `fleet_node_id` is
      // populated and DIFFERS from ours is a delegated-to-another-node row
      // and must NOT surface as ours. The null case is the exception, not
      // the rule.
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('''
[{"id":99,"compliance_rule_id":1,
  "fleet_node_id":99,"compliant":false,
  "failures":["{\\"device_type\\":\\"access_point\\",\\"id\\":1,\\"name\\":\\"A\\",\\"reason\\":\\"r\\"}"],
  "checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.absent);
    });

    test('returns newest by checked_at when multiple rows match', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('''
[{"id":1,"compliance_rule_id":1,"fleet_node_id":7,
  "compliant":true,"failures":[],"checked_at":"2026-05-12T00:00:00Z"},
 {"id":2,"compliance_rule_id":1,"fleet_node_id":7,
  "compliant":false,"failures":[],"checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.found);
      expect(result.snapshot!.id, 2);
    });

    test('tolerates a malformed row and keeps going', () async {
      final ds = ComplianceRestDataSource(
        siteUrl: 'example.test',
        apiKey: 'secret',
        client: MockClient((_) async => http.Response('''
[{"compliance_rule_id":1,"fleet_node_id":7,"compliant":"not a bool"},
 {"id":101,"compliance_rule_id":1,"fleet_node_id":7,
  "compliant":true,"failures":[],"checked_at":"2026-05-13T00:00:00Z"}]
''', 200)),
      );
      final result = await ds.bootstrapResult(ruleId: 1, ruleName: "rule", fleetNodeId: 7);
      expect(result.status, BootstrapStatus.found);
      expect(result.snapshot!.id, 101);
    });
  });

  group('FM-8 / api_key URL scrubbing', () {
    test('api_key is replaced with [redacted] in scrubbed URLs', () {
      final uri = Uri.parse(
        'https://example.test/admin/scaffolds/compliance_rules/check_now/9.json?api_key=SECRET_SENTINEL',
      );
      final scrubbed = ComplianceRestDataSource.scrubUrlForLog(uri);
      expect(scrubbed, contains('[redacted]'));
      expect(scrubbed, isNot(contains('SECRET_SENTINEL')));
    });

    test('URLs without api_key are unchanged in shape', () {
      final uri = Uri.parse('https://example.test/api/whoami.json');
      expect(
        ComplianceRestDataSource.scrubUrlForLog(uri),
        'https://example.test/api/whoami.json',
      );
    });

    test('api_key mid-query (with following params) is scrubbed', () {
      final uri = Uri.parse(
        'https://example.test/api/x.json?api_key=SECRET&page=2',
      );
      final scrubbed = ComplianceRestDataSource.scrubUrlForLog(uri);
      expect(scrubbed, contains('api_key=[redacted]'));
      expect(scrubbed, contains('page=2'));
      expect(scrubbed, isNot(contains('SECRET')));
    });
  });
}

String jsonEncodedSnapshotList() {
  return '''
[
  {
    "id": 100,
    "compliance_rule_id": 1,
    "fleet_node_id": 7,
    "compliant": false,
    "failures": [
      "Failure: {\\"device_type\\":\\"access_point\\",\\"id\\":1,\\"name\\":\\"AP-Lobby\\",\\"reason\\":\\"missing installation images\\"}"
    ],
    "checked_at": "2026-05-13T00:00:00Z"
  },
  {
    "id": 101,
    "compliance_rule_id": 2,
    "fleet_node_id": 7,
    "compliant": true,
    "failures": [],
    "checked_at": "2026-05-13T00:00:00Z"
  }
]
''';
}
