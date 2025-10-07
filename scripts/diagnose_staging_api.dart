#!/usr/bin/env dart

// Offline diagnostic summary for staging API behaviour

import 'dart:convert';
import 'dart:io';

void _write([String? message]) => stdout.writeln(message ?? '');

void main() {
  _write('=' * 80);
  _write('STAGING API DIAGNOSTIC SUMMARY (OFFLINE)');
  _write('=' * 80);
  _write();

  describeEndpoints();
  showSamplePaginatedPayload();
  showSampleUnpaginatedPayload();
  showNullNameInvestigation();

  _write();
  _write('=' * 80);
  _write('DIAGNOSIS COMPLETE');
  _write('=' * 80);
}

void describeEndpoints() {
  _write('1. ENDPOINTS UNDER TEST');
  _write('-' * 40);
  _write('  • GET /api/pms_rooms.json?page=1&page_size=5');
  _write('    Returns a Map with pagination metadata and a results array.');
  _write('  • GET /api/pms_rooms.json?page_size=0');
  _write('    Returns either a Map with results or, in some deployments, a direct List.');
  _write('  • GET /api/pms_rooms/<id>.json');
  _write('    Returns a JSON object describing a single room.');
}

void showSamplePaginatedPayload() {
  _write();
  _write('2. SAMPLE PAGINATED RESPONSE (page=1&page_size=5)');
  _write('-' * 40);

  final paginated = {
    'count': 128,
    'next': 'https://example.com/api/pms_rooms.json?page=2&page_size=5',
    'previous': null,
    'results': [
      {
        'id': 128,
        'room': '803',
        'name': '(Interurban) 803',
        'online': true,
        'pms_property': {'id': 1, 'name': 'Interurban'},
      },
    ],
  };

  _write(const JsonEncoder.withIndent('  ').convert(paginated));
}

void showSampleUnpaginatedPayload() {
  _write();
  _write('3. SAMPLE UNPAGINATED RESPONSE (page_size=0)');
  _write('-' * 40);

  final unpaginated = [
    {
      'id': 1000,
      'room': '101',
      'name': '(North Tower) 101',
      'online': true,
      'pms_property': {'id': 2, 'name': 'North Tower'},
    },
    {
      'id': 1001,
      'room': '102',
      'name': null,
      'online': false,
      'pms_property': {'id': 2, 'name': 'North Tower'},
    },
  ];

  _write(const JsonEncoder.withIndent('  ').convert(unpaginated));
  _write('  → Note: some rows may have name=null, which the app must handle.');
}

void showNullNameInvestigation() {
  _write();
  _write('4. NULL NAME INVESTIGATION');
  _write('-' * 40);

  _write('  • When the API returns name=null, RoomRemoteDataSource builds the display');
  _write('    name from (pms_property.name, room).');
  _write('  • Development mock data should mirror this by leaving name empty in the JSON');
  _write('    and letting the RoomModel/Room entity compute the display field.');
  _write('  • Ensure the Room entity used in dev mode stores the computed display name.');
}
