/// Converts between instants and wall-clock dates/times in one time zone.
///
/// Production uses the device zone ([DeviceZoneRules]); tests inject real
/// IANA rules so DST behaviour is checked against the tz database rather
/// than whatever zone the test machine happens to be in.
abstract interface class ZoneRules {
  /// The calendar date of [instant] on this zone's wall clock.
  ({int year, int month, int day}) dateOf(DateTime instant);

  /// The instant at which this zone's wall clock reads the given date and
  /// time. A time skipped by a DST gap resolves to the same instant shifted
  /// forward by the gap (02:30 → 03:30); a repeated time resolves to its
  /// first occurrence. This matches java.time on the native side.
  DateTime resolve(int year, int month, int day, int hour, int minute);
}

class DeviceZoneRules implements ZoneRules {
  const DeviceZoneRules();

  @override
  ({int year, int month, int day}) dateOf(DateTime instant) {
    final local = instant.toLocal();
    return (year: local.year, month: local.month, day: local.day);
  }

  @override
  DateTime resolve(int year, int month, int day, int hour, int minute) =>
      DateTime(year, month, day, hour, minute);
}

/// Picks rules for an IANA zone name (e.g. AlAdhan's `meta.timezone`).
typedef ZoneRulesFactory = ZoneRules Function(String? timeZone);

/// The Dart side only needs zone-exact maths for display, and the prayer
/// times' zone is the phone's own zone in normal use, so device rules are
/// used for every zone. The native engine applies the named zone exactly.
ZoneRules deviceZoneRulesFor(String? timeZone) => const DeviceZoneRules();
