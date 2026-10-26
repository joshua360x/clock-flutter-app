import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/alarms/alarm_engine.dart';
import 'package:prayer_alarm/alarms/native_alarm_engine.dart';
import 'package:prayer_alarm/prayer_times/geo_point.dart';

/// Pins the channel contract with NativeBridge.kt: method names and
/// argument shapes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  Object? Function(MethodCall)? reply;

  setUp(() {
    calls = [];
    reply = null;
    messenger.setMockMethodCallHandler(nativeChannel, (call) async {
      calls.add(call);
      return reply?.call(call);
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(nativeChannel, null));

  test('sync sends the payload as JSON', () async {
    await NativeAlarmEngine().sync({'version': 1, 'alarms': []});

    expect(calls.single.method, 'syncSchedule');
    expect(jsonDecode((calls.single.arguments as Map)['json'] as String), {'version': 1, 'alarms': []});
  });

  test('ringing state is decoded, including test alarms', () async {
    reply = (_) => {'alarmId': 1, 'key': 'fajr', 'label': 'Fajr', 'at': 1793007720000, 'kind': 'test'};

    final ringing = await NativeAlarmEngine().currentRinging();

    expect(ringing!.label, 'Fajr');
    expect(ringing.isTest, isTrue);
    expect(ringing.scheduledAt, DateTime.fromMillisecondsSinceEpoch(1793007720000));
  });

  test('nothing ringing', () async {
    expect(await NativeAlarmEngine().currentRinging(), isNull);
  });

  test('native pushes ringing changes', () async {
    final engine = NativeAlarmEngine();
    final events = <RingingAlarm?>[];
    engine.ringingChanges.listen(events.add);

    await messenger.handlePlatformMessage(
      nativeChannel.name,
      nativeChannel.codec.encodeMethodCall(const MethodCall('ringingChanged', null)),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);

    expect(events, [null]);
  });

  test('test alarm, dismiss, snooze and fix use the agreed names', () async {
    final engine = NativeAlarmEngine();
    reply = (call) => call.method == 'fix' ? true : null;

    await engine.testAlarm(alarmId: 3, delay: const Duration(seconds: 10));
    await engine.dismiss();
    await engine.snooze();
    final fixed = await engine.fix(ReliabilityItem.batteryOptimization);

    expect(calls.map((c) => c.method), ['testAlarm', 'dismiss', 'snooze', 'fix']);
    expect(calls[0].arguments, {'alarmId': 3, 'delaySeconds': 10});
    expect(calls[3].arguments, {'item': 'batteryOptimization'});
    expect(fixed, isTrue);
  });

  test('unknown reliability names from a newer native side are ignored', () async {
    reply = (_) => ['notifications', 'somethingNew', 'alarmVolume'];

    expect(
      await NativeAlarmEngine().missingReliability(),
      {ReliabilityItem.notifications, ReliabilityItem.alarmVolume},
    );
  });

  test('location and country', () async {
    reply = (call) => switch (call.method) {
      'currentLocation' => {'lat': 40.7, 'lng': -74.0},
      'countryCode' => 'US',
      _ => null,
    };

    final point = await const NativeLocationSource().currentLocation();
    expect((point!.latitude, point.longitude), (40.7, -74.0));
    expect(await const NativeRegionSource().countryCode(), 'US');

    reply = (_) => null;
    expect(await const NativeLocationSource().currentLocation(), isA<GeoPoint?>().having((p) => p, 'point', isNull));
  });
}
