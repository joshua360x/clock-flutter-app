import 'calculation_method.dart';
import 'geo_point.dart';
import 'prayer.dart';
import 'wall_time.dart';

/// One prayer's time on one day: the exact instant, plus the wall-clock time
/// at the location (kept for display and for repeating once the table ends).
class PrayerTime {
  const PrayerTime({required this.at, required this.wall});

  final DateTime at;
  final WallTime wall;
}

/// The five prayer times for one calendar date at the location.
class PrayerDay {
  PrayerDay({required DateTime date, required this.times})
    : date = DateTime.utc(date.year, date.month, date.day);

  /// Date only (UTC midnight is used as a plain calendar-date carrier).
  final DateTime date;
  final Map<Prayer, PrayerTime> times;
}

/// Prayer times fetched from AlAdhan for a location and method.
class Timetable {
  Timetable({
    required this.location,
    required this.method,
    required this.school,
    required this.timeZone,
    required this.fetchedAt,
    required List<PrayerDay> days,
  }) : days = List.unmodifiable(
         [...days]..sort((a, b) => a.date.compareTo(b.date)),
       );

  final GeoPoint location;
  final CalculationMethod method;
  final AsrSchool school;

  /// IANA zone of the location as reported by AlAdhan, e.g. America/New_York.
  final String? timeZone;
  final DateTime fetchedAt;

  /// Sorted by date, oldest first.
  final List<PrayerDay> days;

  bool usesSettings(CalculationMethod method, AsrSchool school) =>
      this.method == method && this.school == school;

  /// Number of whole days in the table on or after [date].
  int daysFrom(DateTime date) {
    final from = DateTime.utc(date.year, date.month, date.day);
    return days.where((day) => !day.date.isBefore(from)).length;
  }

  Map<String, Object?> toJson() => {
    'v': 1,
    'location': location.toJson(),
    'methodId': method.id,
    'methodName': method.name,
    'school': school.apiValue,
    'timeZone': timeZone,
    'fetchedAt': fetchedAt.toUtc().toIso8601String(),
    'days': [
      for (final day in days)
        {
          'date': _isoDate(day.date),
          'times': {
            for (final entry in day.times.entries)
              entry.key.apiKey: {
                'at': entry.value.at.toUtc().toIso8601String(),
                'wall': entry.value.wall.toString(),
              },
          },
        },
    ],
  };

  /// Returns null for anything that is not a complete, current-version table,
  /// so a corrupt cache behaves like an empty one.
  static Timetable? fromJson(Object? json) {
    if (json is! Map || json['v'] != 1) return null;
    final location = GeoPoint.fromJson(json['location']);
    final methodId = json['methodId'];
    final methodName = json['methodName'];
    final school = json['school'];
    final fetchedAt = DateTime.tryParse('${json['fetchedAt']}');
    final rawDays = json['days'];
    if (location == null ||
        methodId is! int ||
        methodName is! String ||
        fetchedAt == null ||
        rawDays is! List) {
      return null;
    }
    final asrSchool = AsrSchool.values
        .where((s) => s.apiValue == school)
        .firstOrNull;
    if (asrSchool == null) return null;

    final days = <PrayerDay>[];
    for (final rawDay in rawDays) {
      if (rawDay is! Map) return null;
      final date = DateTime.tryParse('${rawDay['date']}');
      final rawTimes = rawDay['times'];
      if (date == null || rawTimes is! Map) return null;
      final times = <Prayer, PrayerTime>{};
      for (final prayer in Prayer.values) {
        final raw = rawTimes[prayer.apiKey];
        if (raw is! Map) return null;
        final at = DateTime.tryParse('${raw['at']}');
        final wall = WallTime.tryParse('${raw['wall']}');
        if (at == null || wall == null) return null;
        times[prayer] = PrayerTime(at: at, wall: wall);
      }
      days.add(PrayerDay(date: date, times: times));
    }
    return Timetable(
      location: location,
      method: CalculationMethod(methodId, methodName),
      school: asrSchool,
      timeZone: json['timeZone'] is String ? json['timeZone'] as String : null,
      fetchedAt: fetchedAt,
      days: days,
    );
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
