import 'prayer.dart';
import 'timetable.dart';
import 'wall_time.dart';
import 'zone_rules.dart';

/// When each prayer alarm rings next. Pure: no I/O, no clock of its own.
///
/// The rule, mirrored by the native engine (NextRing.kt) and pinned by the
/// shared cases in test/fixtures/next_ring_cases.json:
///  1. the first fetched AlAdhan time strictly after now, else
///  2. the next daily occurrence of a fallback wall-clock time: the last
///     fetched time for that prayer, or the built-in default if nothing has
///     been fetched yet.
class PrayerSchedule {
  const PrayerSchedule(
    this.timetable, {
    this.zoneRulesFor = deviceZoneRulesFor,
  });

  final Timetable? timetable;
  final ZoneRulesFactory zoneRulesFor;

  /// Fetched times for [prayer] strictly after [now], soonest first.
  List<DateTime> fetchedAfter(Prayer prayer, DateTime now) => [
    for (final day in timetable?.days ?? const <PrayerDay>[])
      if (day.times[prayer]?.at case final at? when at.isAfter(now)) at,
  ];

  /// Wall-clock time repeated daily once fetched times run out.
  WallTime fallbackTime(Prayer prayer) {
    final days = timetable?.days ?? const <PrayerDay>[];
    for (final day in days.reversed) {
      final time = day.times[prayer];
      if (time != null) return time.wall;
    }
    return prayer.fallbackTime;
  }

  /// Zone the fallback time is read in: the location's, when known.
  String? get fallbackTimeZone => timetable?.timeZone;

  /// Whether [prayer]'s next ring comes from AlAdhan rather than a fallback.
  bool isFetched(Prayer prayer, DateTime now) =>
      fetchedAfter(prayer, now).isNotEmpty;

  DateTime nextRing(Prayer prayer, DateTime now) => nextRingFrom(
    fetched: fetchedAfter(prayer, now),
    fallback: fallbackTime(prayer),
    now: now,
    rules: zoneRulesFor(fallbackTimeZone),
  );

  /// The soonest ring among [enabled] prayers, or null if none are enabled.
  ({Prayer prayer, DateTime at})? nextDue(
    Iterable<Prayer> enabled,
    DateTime now,
  ) {
    ({Prayer prayer, DateTime at})? soonest;
    for (final prayer in enabled) {
      final at = nextRing(prayer, now);
      if (soonest == null || at.isBefore(soonest.at)) {
        soonest = (prayer: prayer, at: at);
      }
    }
    return soonest;
  }
}

/// The scheduling rule for one prayer: the first of [fetched] strictly after
/// [now], else the next occurrence of [fallback]. [fetched] need not be
/// sorted. Mirrored by NextRing.kt; both run test/fixtures/next_ring_cases.json.
DateTime nextRingFrom({
  required Iterable<DateTime> fetched,
  required WallTime fallback,
  required DateTime now,
  required ZoneRules rules,
}) {
  DateTime? soonest;
  for (final at in fetched) {
    if (at.isAfter(now) && (soonest == null || at.isBefore(soonest))) {
      soonest = at;
    }
  }
  return soonest ?? nextOccurrence(fallback, after: now, rules: rules);
}

/// The next instant strictly after [after] at which the wall clock reads
/// [time]. Steps by calendar day and re-resolves the wall time, never by
/// adding 24 hours, so DST changes keep the alarm at the same clock time.
DateTime nextOccurrence(
  WallTime time, {
  required DateTime after,
  required ZoneRules rules,
}) {
  final today = rules.dateOf(after);
  final candidate = rules.resolve(
    today.year,
    today.month,
    today.day,
    time.hour,
    time.minute,
  );
  if (candidate.isAfter(after)) return candidate;
  final tomorrow = DateTime.utc(today.year, today.month, today.day + 1);
  return rules.resolve(
    tomorrow.year,
    tomorrow.month,
    tomorrow.day,
    time.hour,
    time.minute,
  );
}
