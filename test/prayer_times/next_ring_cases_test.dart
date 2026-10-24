import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/prayer_times/prayer_schedule.dart';
import 'package:prayer_alarm/prayer_times/wall_time.dart';

import '../support/tz_zone_rules.dart';

/// Runs the cases shared with the native engine, so Dart and Kotlin cannot
/// drift apart on when an alarm rings.
void main() {
  final fixture =
      jsonDecode(File('test/fixtures/next_ring_cases.json').readAsStringSync())
          as Map<String, dynamic>;

  for (final raw in fixture['cases'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    test(c['name'], () {
      final at = nextRingFrom(
        fetched: [
          for (final iso in c['fetched'] as List<dynamic>)
            DateTime.parse(iso as String),
        ],
        fallback: WallTime.tryParse(c['fallback'] as String)!,
        now: DateTime.parse(c['now'] as String),
        rules: TzZoneRules(c['zone'] as String),
      );
      expect(at.toUtc(), DateTime.parse(c['expected'] as String));
    });
  }
}
