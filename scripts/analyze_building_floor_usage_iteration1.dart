#!/usr/bin/env dart

import 'dart:io';

void _write([String? message]) => stdout.writeln(message ?? '');

/// Iteration 1: Analyze if building/floor fields are actually used
void main() {
  _write('=' * 80);
  _write('ITERATION 1: Building/Floor Field Usage Analysis');
  _write('=' * 80);

  _write();
  _write('1. STAGING API ANALYSIS');
  _write('-' * 40);
  _write('Based on our previous investigation:');
  _write('Staging API returns:');
  _write('{');
  _write('  "id": 128,');
  _write('  "room": "803",');
  _write('  "pms_property": {"name": "Interurban"}');
  _write('}');
  _write();
  _write('Does NOT include:');
  _write('  ❌ "building" field');
  _write('  ❌ "floor" field');

  _write();
  _write('2. VIEW/UI USAGE ANALYSIS');
  _write('-' * 40);
  _write('From room_view_models.dart (lines 34-43):');
  _write(r'''
String get locationDisplay {
  final parts = <String>[];
  if (building != null) {
    parts.add(building!);
  }
  if (floor != null) {
    parts.add('Floor $floor');
  }
  return parts.join(' ');
}
''');
  _write('The view DOES use building and floor fields!');
  _write('But only for locationDisplay, which shows as extra line.');

  _write();
  _write('3. WHERE ELSE ARE THEY USED?');
  _write('-' * 40);
  _write('RoomViewModel exposes (lines 23-25):');
  _write('  String? get building => room.building;');
  _write('  String? get floor => room.floor?.toString();');
  _write();
  _write('Used in:');
  _write('  ✓ locationDisplay getter (for extra line in UI)');
  _write('  ? Potentially in room detail screen');
  _write('  ? Potentially in other views');

  _write();
  _write('4. ROOM ENTITY STRUCTURE');
  _write('-' * 40);
  _write('Room entity has (room.dart):');
  _write('  String? building');
  _write('  int? floor');
  _write();
  _write('These are optional fields in the domain entity.');

  _write();
  _write('5. ROOMMODEL STRUCTURE');
  _write('-' * 40);
  _write('RoomModel has (room_model.dart):');
  _write('  final String? building;');
  _write('  final String? floor;');
  _write();
  _write('These map to Room entity fields.');

  _write();
  _write('6. THE FUNDAMENTAL QUESTION');
  _write('-' * 40);
  _write("If the API doesn't provide building/floor:");
  _write('  1. Should RoomModel have these fields? Maybe NO');
  _write('  2. Should Room entity have these fields? Maybe NO');
  _write('  3. Should the view use these fields? Currently YES (locationDisplay)');
  _write();
  _write('BUT: The room name already contains "(Building) Room" format!');
  _write('So building/floor fields are REDUNDANT.');

  _write();
  _write('7. CURRENT DATA FLOW');
  _write('-' * 40);
  _write('STAGING:');
  _write(
    '  API: No building/floor → Parser: "" → Entity: null → View: empty locationDisplay',
  );
  _write();
  _write('DEVELOPMENT:');
  _write(
    '  Mock: No building/floor → Parser: SYNTHESIZES → Entity: values → View: shows locationDisplay',
  );

  _write();
  _write('8. ARCHITECTURAL CONSIDERATION');
  _write('-' * 40);
  _write('Clean Architecture principle:');
  _write('  - Domain entities should represent business concepts');
  _write('  - If building/floor are business concepts, keep them');
  _write("  - If they're just parsing artifacts, remove them");
  _write();
  _write('Given that:');
  _write("  - API doesn't provide them");
  _write('  - Name already contains the info');
  _write('  - They cause UI inconsistency');
  _write();
  _write('Recommendation: These fields might not belong in the domain!');

  _write();
  _write('=' * 80);
  _write('ITERATION 1 COMPLETE');
  _write('=' * 80);
}
