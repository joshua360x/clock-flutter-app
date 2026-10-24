import 'prayer.dart';
import 'timetable.dart';
import 'wall_time.dart';
import 'zone_rules.dart';

/// One month of AlAdhan calendar data.
class AlAdhanMonth {
  const AlAdhanMonth({required this.days, required this.timeZone});

  final List<PrayerDay> days;
  final String? timeZone;
}

/// Parses a `/v1/calendar/{year}/{month}` response body (already decoded).
///
/// Shape, from AlAdhan's official SDK types:
///   {code, status, data: [{timings: {Fajr, Dhuhr, Asr, Maghrib, Isha, ...},
///                          date: {gregorian: {date: "DD-MM-YYYY"}, ...},
///                          meta: {timezone: "America/New_York", ...}}]}
/// Timings are ISO 8601 with an offset when requested with `iso8601=true`
/// ("2026-03-08T05:58:00-05:00"), otherwise "HH:mm" or "HH:mm (EST)"; both
/// are accepted. A day with any unusable prayer time is skipped rather than
/// guessed at. Throws [FormatException] when no usable day remains.
AlAdhanMonth parseAlAdhanCalendar(
  Object? body, {
  ZoneRulesFactory zoneRulesFor = deviceZoneRulesFor,
}) {
  if (body is! Map) throw const FormatException('body is not an object');
  final code = body['code'];
  if (code != null && code != 200) {
    throw FormatException('code $code in a 200 response');
  }
  final data = body['data'];
  if (data is! List) throw const FormatException('data is not a list');

  final days = <PrayerDay>[];
  String? timeZone;
  for (final entry in data) {
    if (entry is! Map) continue;
    final entryZone = _timeZoneOf(entry);
    timeZone ??= entryZone;
    final day = _parseDay(entry, zoneRulesFor(entryZone ?? timeZone));
    if (day != null) days.add(day);
  }
  if (days.isEmpty) throw const FormatException('no usable days');
  return AlAdhanMonth(days: days, timeZone: timeZone);
}

String? _timeZoneOf(Map<dynamic, dynamic> entry) {
  final meta = entry['meta'];
  if (meta is! Map) return null;
  final zone = meta['timezone'];
  return zone is String && zone.isNotEmpty ? zone : null;
}

PrayerDay? _parseDay(Map<dynamic, dynamic> entry, ZoneRules rules) {
  final date = _gregorianDate(entry);
  final timings = entry['timings'];
  if (date == null || timings is! Map) return null;

  final times = <Prayer, PrayerTime>{};
  for (final prayer in Prayer.values) {
    final raw = timings[prayer.apiKey];
    if (raw is! String) return null;
    final time = _parseTime(raw, date, rules);
    if (time == null) return null;
    times[prayer] = time;
  }
  return PrayerDay(date: date, times: times);
}

/// `date.gregorian.date` is "DD-MM-YYYY".
DateTime? _gregorianDate(Map<dynamic, dynamic> entry) {
  final date = entry['date'];
  final gregorian = date is Map ? date['gregorian'] : null;
  final text = gregorian is Map ? gregorian['date'] : null;
  if (text is! String) return null;
  final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(text.trim());
  if (match == null) return null;
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final parsed = DateTime.utc(year, month, day);
  // Reject dates DateTime silently normalised, like 31-02-2026.
  if (parsed.day != day || parsed.month != month) return null;
  return parsed;
}

PrayerTime? _parseTime(String raw, DateTime date, ZoneRules rules) {
  final token = raw.trim().split(RegExp(r'\s+')).first;

  // ISO form carries its own offset, so the instant is exact.
  if (token.contains('T')) {
    final at = DateTime.tryParse(token);
    final wall = WallTime.tryParse(token.substring(token.indexOf('T') + 1));
    if (at == null || wall == null || !_hasOffset(token)) return null;
    return PrayerTime(at: at.toUtc(), wall: wall);
  }

  final wall = WallTime.tryParse(token);
  if (wall == null) return null;
  final at = rules.resolve(
    date.year,
    date.month,
    date.day,
    wall.hour,
    wall.minute,
  );
  return PrayerTime(at: at.toUtc(), wall: wall);
}

/// Without an offset DateTime.parse would read the time as device-local,
/// which is a guess; refuse it instead.
bool _hasOffset(String iso) =>
    RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(iso);
