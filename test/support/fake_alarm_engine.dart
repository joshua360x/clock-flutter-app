import 'dart:async';

import 'package:prayer_alarm/alarms/alarm_engine.dart';
import 'package:prayer_alarm/prayer_times/device_context.dart';
import 'package:prayer_alarm/prayer_times/geo_point.dart';

/// Records what the app asks of the native engine.
class FakeAlarmEngine implements AlarmEngine {
  final synced = <Map<String, Object?>>[];
  final fixed = <ReliabilityItem>[];
  final tests = <({int alarmId, Duration delay})>[];
  var dismissals = 0, snoozes = 0;
  Set<ReliabilityItem> missing = {};
  RingingAlarm? ringingNow;
  final _changes = StreamController<RingingAlarm?>.broadcast();

  /// Simulates the native side starting or stopping a ring.
  void ring(RingingAlarm? alarm) {
    ringingNow = alarm;
    _changes.add(alarm);
  }

  @override
  Stream<RingingAlarm?> get ringingChanges => _changes.stream;

  @override
  Future<void> sync(Map<String, Object?> payload) async => synced.add(payload);

  @override
  Future<RingingAlarm?> currentRinging() async => ringingNow;

  @override
  Future<void> dismiss() async {
    dismissals++;
    ring(null);
  }

  @override
  Future<void> snooze() async {
    snoozes++;
    ring(null);
  }

  @override
  Future<void> testAlarm({required int alarmId, required Duration delay}) async =>
      tests.add((alarmId: alarmId, delay: delay));

  @override
  Future<Set<ReliabilityItem>> missingReliability() async => {...missing};

  @override
  Future<bool> fix(ReliabilityItem item) async {
    fixed.add(item);
    return missing.remove(item);
  }
}

class FakeLocation implements LocationSource {
  FakeLocation([this.point]);
  GeoPoint? point;

  @override
  Future<GeoPoint?> currentLocation() async => point;
}

class FakeRegion implements RegionSource {
  FakeRegion([this.country = 'US']);
  String? country;

  @override
  Future<String?> countryCode() async => country;
}
