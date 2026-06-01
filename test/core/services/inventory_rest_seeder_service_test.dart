import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rgnets_fdk/core/services/inventory_rest_seeder_service.dart';

void main() {
  group('InventoryRestSeederService', () {
    test('siteUrl is normalized (https:// prefix and trailing / stripped)', () async {
      final hits = <Uri>[];
      final client = MockClient((http.Request req) async {
        hits.add(req.url);
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'https://example.netlab.ninja/',
        apiKey: 'k',
        client: client,
      );

      await seeder.seedAll(
        onDevices: (_, __) {},
        onRooms: (_) {},
      );

      expect(hits, isNotEmpty);
      for (final uri in hits) {
        expect(uri.scheme, 'https');
        expect(uri.host, 'example.netlab.ninja');
        expect(uri.path, startsWith('/api/'));
        expect(uri.queryParameters['api_key'], 'k');
        expect(uri.queryParameters['page_size'], '1000');
        expect(uri.queryParameters['page'], '1');
      }
    });

    test('seedAll fires GETs for AP + switch + MC + rooms (parallel)', () async {
      final hits = <String>[];
      final client = MockClient((http.Request req) async {
        hits.add(req.url.path);
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      await seeder.seedAll(
        onDevices: (_, __) {},
        onRooms: (_) {},
      );

      expect(hits, containsAll(<String>[
        '/api/access_points.json',
        '/api/switch_devices.json',
        '/api/media_converters.json',
        '/api/wlan_devices.json',
        '/api/pms_rooms.json',
      ]));
      expect(hits.length, 5);
    });

    test('per-resource success is independent (one 500 does not block others)',
        () async {
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/switch_devices.json') {
          return http.Response('server boom', 500);
        }
        return http.Response('[{"id": 1}]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      String? lastDeviceType;
      final deviceCalls = <String, int>{};
      var roomCalls = 0;
      final result = await seeder.seedAll(
        onDevices: (type, items) {
          lastDeviceType = type;
          deviceCalls[type] = items.length;
        },
        onRooms: (items) {
          roomCalls = items.length;
        },
      );

      expect(result.allSucceeded, isFalse);
      expect(result.outcomes.where((o) => o.success).length, 4);
      final failed = result.outcomes
          .firstWhere((o) => o.resourceType == 'switch_devices');
      expect(failed.success, isFalse);
      expect(failed.statusCode, 500,
          reason: 'non-200 status must be propagated for diagnostics');
      expect(deviceCalls['access_points'], 1);
      expect(deviceCalls['media_converters'], 1);
      expect(deviceCalls['wlan_devices'], 1);
      expect(deviceCalls.containsKey('switch_devices'), isFalse,
          reason: 'failed resource never invokes the apply callback');
      expect(roomCalls, 1);
      expect(lastDeviceType, isNotNull);
    });

    test('extracts results from bare-array body shape', () async {
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/access_points.json') {
          return http.Response(jsonEncode([
            {'id': 1, 'name': 'AP-1'},
            {'id': 2, 'name': 'AP-2'},
          ]), 200);
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      List<Map<String, dynamic>>? captured;
      await seeder.seedAll(
        onDevices: (type, items) {
          if (type == 'access_points') captured = items;
        },
        onRooms: (_) {},
      );

      expect(captured, isNotNull);
      expect(captured!.length, 2);
      expect(captured!.first['name'], 'AP-1');
    });

    test('extracts results from `{records: [...]}` envelope', () async {
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/pms_rooms.json') {
          return http.Response(jsonEncode({
            'records': [
              {'id': 1, 'room': 'A1'},
              {'id': 2, 'room': 'B1'},
              {'id': 3, 'room': 'C1'},
            ],
          }), 200);
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      List<Map<String, dynamic>>? captured;
      await seeder.seedAll(
        onDevices: (_, __) {},
        onRooms: (items) {
          captured = items;
        },
      );

      expect(captured, isNotNull);
      expect(captured!.length, 3);
    });

    test('extracts results from `{results: [...]}` paginated envelope', () async {
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/access_points.json') {
          return http.Response(jsonEncode({
            'results': [
              {'id': 1, 'name': 'AP-1'},
            ],
            'count': 1,
            'page': 1,
          }), 200);
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      List<Map<String, dynamic>>? captured;
      await seeder.seedAll(
        onDevices: (type, items) {
          if (type == 'access_points') captured = items;
        },
        onRooms: (_) {},
      );

      expect(captured!.length, 1);
    });

    test('paginates across pages until a short page and combines results',
        () async {
      // Page 1 is full (1000), page 2 is short (300) — total 1300 across 2 GETs.
      List<Map<String, dynamic>> pageItems(int start, int n) => [
            for (var i = 0; i < n; i++) {'id': start + i},
          ];
      final apPages = <int>[];
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/access_points.json') {
          final page = int.parse(req.url.queryParameters['page']!);
          apPages.add(page);
          final items = page == 1 ? pageItems(0, 1000) : pageItems(1000, 300);
          return http.Response(
            jsonEncode({'results': items, 'count': 1300, 'page': page}),
            200,
          );
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      List<Map<String, dynamic>>? captured;
      await seeder.seedAll(
        onDevices: (type, items) {
          if (type == 'access_points') captured = items;
        },
        onRooms: (_) {},
      );

      expect(apPages, [1, 2]);
      expect(captured!.length, 1300);
    });

    test('stops at the advertised count even when the last page is full',
        () async {
      // Page 1 returns a full page AND count==1000 — no second request needed.
      final apPages = <int>[];
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/access_points.json') {
          apPages.add(int.parse(req.url.queryParameters['page']!));
          return http.Response(
            jsonEncode({
              'results': [for (var i = 0; i < 1000; i++) {'id': i}],
              'count': 1000,
              'page': 1,
            }),
            200,
          );
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      await seeder.seedAll(onDevices: (_, __) {}, onRooms: (_) {});

      expect(apPages, [1]);
    });

    test('does not loop unboundedly when the server ignores `page`', () async {
      // Server always re-serves a full page 1 (no count). The echoed-page guard
      // must stop paging instead of running to the _maxPages cap.
      final apPages = <int>[];
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/access_points.json') {
          apPages.add(int.parse(req.url.queryParameters['page']!));
          return http.Response(
            jsonEncode({
              'results': [for (var i = 0; i < 1000; i++) {'id': i}],
              'page': 1,
            }),
            200,
          );
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      await seeder.seedAll(onDevices: (_, __) {}, onRooms: (_) {});

      // Page 1 then page 2 (which echoes page 1 → stop). Far below the cap.
      expect(apPages, [1, 2]);
    });

    test('a later-page failure fails the whole resource (no partial seed)',
        () async {
      // Page 1 full + count high so paging continues; page 2 errors. The
      // resource must report failure rather than seeding only page 1.
      final client = MockClient((http.Request req) async {
        if (req.url.path == '/api/access_points.json') {
          final page = int.parse(req.url.queryParameters['page']!);
          if (page == 1) {
            return http.Response(
              jsonEncode({
                'results': [for (var i = 0; i < 1000; i++) {'id': i}],
                'count': 5000,
                'page': 1,
              }),
              200,
            );
          }
          return http.Response('boom', 500);
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      var applied = false;
      final result = await seeder.seedAll(
        onDevices: (type, _) {
          if (type == 'access_points') applied = true;
        },
        onRooms: (_) {},
      );

      expect(applied, isFalse);
      final ap = result.outcomes
          .firstWhere((o) => o.resourceType == 'access_points');
      expect(ap.success, isFalse);
      expect(ap.statusCode, 500);
    });

    test('network exception is caught — failure recorded, no propagation',
        () async {
      final client = MockClient((http.Request req) async {
        throw http.ClientException('connection refused');
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      final result = await seeder.seedAll(
        onDevices: (_, __) {},
        onRooms: (_) {},
      );

      expect(result.outcomes, hasLength(5));
      expect(result.outcomes.every((o) => o.success), isFalse);
      expect(result.outcomes.every((o) => o.itemCount == 0), isTrue);
    });

    test('api_key is scrubbed from exception messages in SeedOutcome.error',
        () async {
      const sensitiveKey = 'SECRET-API-KEY-DO-NOT-LEAK';
      final client = MockClient((http.Request req) async {
        // http.ClientException toString format includes the URL when one is
        // supplied — exactly the leak surface we're guarding against.
        throw http.ClientException(
          'Connection failed',
          Uri.parse('https://rxg.test/api/access_points.json'
              '?api_key=$sensitiveKey&per_page=10000'),
        );
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: sensitiveKey,
        client: client,
      );

      final result = await seeder.seedAll(
        onDevices: (_, __) {},
        onRooms: (_) {},
      );

      for (final outcome in result.outcomes) {
        if (outcome.error != null) {
          expect(outcome.error, isNot(contains(sensitiveKey)),
              reason: 'api_key must never appear in SeedOutcome.error');
        }
      }
    });

    test('401 / 403 / 429 / 500 all yield success=false without throwing',
        () async {
      final statuses = [401, 403, 429, 500];
      for (final status in statuses) {
        final client = MockClient((http.Request req) async {
          return http.Response('blocked', status);
        });
        final seeder = InventoryRestSeederService(
          siteUrl: 'rxg.test',
          apiKey: 'k',
          client: client,
        );

        final result = await seeder.seedAll(
          onDevices: (_, __) {},
          onRooms: (_) {},
        );

        expect(result.outcomes.every((o) => !o.success), isTrue,
            reason: 'all $status responses should mark every outcome as failed');
      }
    });

    test('malformed JSON body yields failure, no exception bubbles', () async {
      final client = MockClient((http.Request req) async {
        return http.Response('this is not json', 200);
      });
      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      final result = await seeder.seedAll(
        onDevices: (_, __) {},
        onRooms: (_) {},
      );

      expect(result.outcomes.every((o) => !o.success), isTrue);
    });

    test('unknown body shape (object, no records/results) yields failure',
        () async {
      final client = MockClient((http.Request req) async {
        return http.Response(jsonEncode({'foo': 'bar'}), 200);
      });
      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      final result = await seeder.seedAll(
        onDevices: (_, __) {},
        onRooms: (_) {},
      );

      expect(result.outcomes.every((o) => !o.success), isTrue);
      expect(result.outcomes.every((o) => o.itemCount == 0), isTrue);
    });

    test('seedAll happy path applies snapshots and reports total items', () async {
      final client = MockClient((http.Request req) async {
        final path = req.url.path;
        if (path == '/api/access_points.json') {
          return http.Response(
            jsonEncode([
              for (var i = 1; i <= 379; i++) {'id': i, 'name': 'AP$i'},
            ]),
            200,
          );
        }
        if (path == '/api/switch_devices.json') {
          return http.Response(
            jsonEncode([
              {'id': 1, 'name': 'Switch-1'},
              {'id': 2, 'name': 'Switch-2'},
            ]),
            200,
          );
        }
        if (path == '/api/media_converters.json') {
          return http.Response(
            jsonEncode([
              for (var i = 1; i <= 386; i++) {'id': i, 'name': 'MC$i'},
            ]),
            200,
          );
        }
        if (path == '/api/pms_rooms.json') {
          return http.Response(
            jsonEncode([
              for (var i = 1; i <= 396; i++) {'id': i, 'room': 'Room$i'},
            ]),
            200,
          );
        }
        return http.Response('[]', 200);
      });

      final seeder = InventoryRestSeederService(
        siteUrl: 'rxg.test',
        apiKey: 'k',
        client: client,
      );

      final devicePerType = <String, int>{};
      var roomCount = 0;
      final result = await seeder.seedAll(
        onDevices: (type, items) => devicePerType[type] = items.length,
        onRooms: (items) => roomCount = items.length,
      );

      expect(result.allSucceeded, isTrue);
      expect(result.totalItems, 379 + 2 + 386 + 396);
      expect(devicePerType['access_points'], 379);
      expect(devicePerType['switch_devices'], 2);
      expect(devicePerType['media_converters'], 386);
      expect(roomCount, 396);
    });
  });
}
