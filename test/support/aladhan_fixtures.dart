import 'dart:convert';

import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Builds AlAdhan `/v1/calendar` bodies in the documented shape, with
/// ISO 8601 times carrying the real UTC offset of [zone] on each date.
///
/// The live API is not reachable from the build environment, so these follow
/// the official SDK's types (@islamicnetwork/sdk) rather than a recording.
class AlAdhanFixtures {
  AlAdhanFixtures({this.zone = 'America/New_York'}) {
    tzdata.initializeTimeZones();
    _location = tz.getLocation(zone);
  }

  final String zone;
  late final tz.Location _location;

  static const defaultTimes = {
    'Fajr': '05:30',
    'Sunrise': '06:55',
    'Dhuhr': '12:45',
    'Asr': '15:50',
    'Sunset': '18:20',
    'Maghrib': '18:20',
    'Isha': '19:40',
    'Imsak': '05:20',
    'Midnight': '00:35',
    'Firstthird': '22:30',
    'Lastthird': '02:40',
  };

  /// ISO time with offset, e.g. 2026-03-08T06:56:00-04:00.
  String iso(int year, int month, int day, String hhmm) {
    final parts = hhmm.split(':');
    final local = tz.TZDateTime(
      _location,
      year,
      month,
      day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}'
        'T${two(local.hour)}:${two(local.minute)}:00'
        '$sign${two(abs.inHours)}:${two(abs.inMinutes % 60)}';
  }

  Map<String, Object?> entry(
    int year,
    int month,
    int day, {
    Map<String, String> times = defaultTimes,
    bool isoFormat = true,
    String abbreviation = 'EST',
  }) {
    String two(int n) => n.toString().padLeft(2, '0');
    return {
      'timings': {
        for (final MapEntry(:key, :value) in times.entries)
          key: isoFormat ? iso(year, month, day, value) : '$value ($abbreviation)',
      },
      'date': {
        'readable': '${two(day)} ${_monthNames[month - 1]} $year',
        'timestamp': '0',
        'gregorian': {
          'date': '${two(day)}-${two(month)}-$year',
          'format': 'DD-MM-YYYY',
          'day': two(day),
          'month': {'number': month, 'en': _monthNames[month - 1]},
          'year': '$year',
        },
        'hijri': {'date': '01-01-1448', 'format': 'DD-MM-YYYY'},
      },
      'meta': {
        'latitude': 40.7128,
        'longitude': -74.006,
        'timezone': zone,
        'method': {'id': 2, 'name': 'Islamic Society of North America (ISNA)'},
        'latitudeAdjustmentMethod': 'ANGLE_BASED',
        'midnightMode': 'STANDARD',
        'school': 'STANDARD',
        'offset': {'Fajr': 0, 'Dhuhr': 0, 'Asr': 0, 'Maghrib': 0, 'Isha': 0},
      },
    };
  }

  /// Every day of [month].
  String monthBody(int year, int month) {
    final days = DateTime.utc(year, month + 1, 0).day;
    return body([for (var d = 1; d <= days; d++) entry(year, month, d)]);
  }

  static String body(List<Map<String, Object?>> entries) =>
      jsonEncode({'code': 200, 'status': 'OK', 'data': entries});

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
