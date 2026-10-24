import '../core/result.dart';
import 'aladhan_client.dart';
import 'calculation_method.dart';
import 'device_context.dart';
import 'geo_point.dart';
import 'timetable.dart';
import 'timetable_store.dart';

sealed class RefreshOutcome {
  const RefreshOutcome();
}

final class TimetableUpdated extends RefreshOutcome {
  const TimetableUpdated(this.timetable);
  final Timetable timetable;
}

/// The cached timetable still fits the location, method and horizon.
final class TimetableCurrent extends RefreshOutcome {
  const TimetableCurrent();
}

/// No location, and nothing cached to fall back on.
final class LocationUnavailable extends RefreshOutcome {
  const LocationUnavailable();
}

/// The fetch failed; the previous timetable (if any) stays in use.
final class RefreshFailed extends RefreshOutcome {
  const RefreshFailed(this.failure);
  final AlAdhanFailure failure;
}

/// Keeps a cached AlAdhan timetable covering the coming weeks.
///
/// Refetches when there is no timetable, the phone moved more than
/// [moveThresholdKm], the country's method changed, or fewer than
/// [minDaysAhead] days remain. Each fetch covers [daysAhead] days from today
/// (2–3 monthly requests). A failed fetch never discards the cache.
class PrayerTimesService {
  PrayerTimesService({
    required AlAdhanClient client,
    required TimetableStore store,
    required LocationSource location,
    required RegionSource region,
    DateTime Function()? now,
    this.school = AsrSchool.standard,
    this.moveThresholdKm = 10,
    this.minDaysAhead = 21,
    this.daysAhead = 60,
  }) : _client = client,
       _store = store,
       _location = location,
       _region = region,
       _now = now ?? DateTime.now,
       _timetable = store.load();

  final AlAdhanClient _client;
  final TimetableStore _store;
  final LocationSource _location;
  final RegionSource _region;
  final DateTime Function() _now;
  final AsrSchool school;
  final double moveThresholdKm;
  final int minDaysAhead;
  final int daysAhead;

  Timetable? _timetable;
  Timetable? get timetable => _timetable;

  Future<RefreshOutcome> refresh() async {
    final cached = _timetable;
    final here = await _location.currentLocation() ?? cached?.location;
    if (here == null) return const LocationUnavailable();

    final method = CalculationMethods.forCountry(await _region.countryCode());
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    if (cached != null && !_isStale(cached, here, method, today)) {
      return const TimetableCurrent();
    }

    final days = <PrayerDay>[];
    String? timeZone;
    for (final (:year, :month) in _monthsCovering(today, daysAhead)) {
      final result = await _client.fetchMonth(
        year: year,
        month: month,
        location: here,
        method: method,
        school: school,
      );
      switch (result) {
        case Err(:final error):
          return RefreshFailed(error);
        case Ok(:final value):
          days.addAll(value.days);
          timeZone ??= value.timeZone;
      }
    }

    final fresh = Timetable(
      location: here,
      method: method,
      school: school,
      timeZone: timeZone,
      fetchedAt: now,
      days: [
        for (final day in days)
          if (!day.date.isBefore(
            DateTime.utc(today.year, today.month, today.day),
          ))
            day,
      ],
    );
    _timetable = fresh;
    await _store.save(fresh);
    return TimetableUpdated(fresh);
  }

  bool _isStale(
    Timetable cached,
    GeoPoint here,
    CalculationMethod method,
    DateTime today,
  ) =>
      cached.location.distanceKmTo(here) > moveThresholdKm ||
      !cached.usesSettings(method, school) ||
      cached.daysFrom(today) < minDaysAhead;
}

/// Gregorian months touched by the [days] days starting at [from].
List<({int year, int month})> _monthsCovering(DateTime from, int days) {
  final last = DateTime(from.year, from.month, from.day + days - 1);
  final months = <({int year, int month})>[];
  for (
    var cursor = DateTime(from.year, from.month);
    !cursor.isAfter(DateTime(last.year, last.month));
    cursor = DateTime(cursor.year, cursor.month + 1)
  ) {
    months.add((year: cursor.year, month: cursor.month));
  }
  return months;
}
