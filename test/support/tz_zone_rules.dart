import 'package:prayer_alarm/prayer_times/zone_rules.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// [ZoneRules] backed by the real IANA database, independent of the zone of
/// the machine running the tests.
class TzZoneRules implements ZoneRules {
  TzZoneRules(String zone) : _location = _locationFor(zone);

  final tz.Location _location;

  static var _initialized = false;
  static tz.Location _locationFor(String zone) {
    if (!_initialized) {
      tzdata.initializeTimeZones();
      _initialized = true;
    }
    return tz.getLocation(zone);
  }

  @override
  ({int year, int month, int day}) dateOf(DateTime instant) {
    final local = tz.TZDateTime.from(instant, _location);
    return (year: local.year, month: local.month, day: local.day);
  }

  @override
  DateTime resolve(int year, int month, int day, int hour, int minute) =>
      tz.TZDateTime(_location, year, month, day, hour, minute).toUtc();
}
