import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../prayer_times/device_context.dart';
import '../prayer_times/geo_point.dart';
import 'alarm_engine.dart';

/// The one channel to the native side. Method names match NativeBridge.kt.
const nativeChannel = MethodChannel('prayer_alarm/native');

class NativeAlarmEngine implements AlarmEngine {
  NativeAlarmEngine({MethodChannel channel = nativeChannel}) : _channel = channel {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'ringingChanged') {
        _ringing.add(RingingAlarm.fromMap(call.arguments));
      }
    });
  }

  final MethodChannel _channel;
  final _ringing = StreamController<RingingAlarm?>.broadcast();

  @override
  Stream<RingingAlarm?> get ringingChanges => _ringing.stream;

  @override
  Future<void> sync(Map<String, Object?> payload) =>
      _channel.invokeMethod('syncSchedule', {'json': jsonEncode(payload)});

  @override
  Future<RingingAlarm?> currentRinging() async =>
      RingingAlarm.fromMap(await _channel.invokeMethod<Object?>('ringing'));

  @override
  Future<void> dismiss() => _channel.invokeMethod('dismiss');

  @override
  Future<void> snooze() => _channel.invokeMethod('snooze');

  @override
  Future<void> testAlarm({required int alarmId, required Duration delay}) =>
      _channel.invokeMethod('testAlarm', {
        'alarmId': alarmId,
        'delaySeconds': delay.inSeconds,
      });

  @override
  Future<Set<ReliabilityItem>> missingReliability() async {
    final names = await _channel.invokeListMethod<Object?>('missingReliability');
    return {
      for (final name in names ?? const <Object?>[])
        if (ReliabilityItem.fromWire(name) case final item?) item,
    };
  }

  @override
  Future<bool> fix(ReliabilityItem item) async =>
      await _channel.invokeMethod<bool>('fix', {'item': item.wireName}) ?? false;
}

/// One coarse fix from the phone (null without permission or a fix).
class NativeLocationSource implements LocationSource {
  const NativeLocationSource({MethodChannel channel = nativeChannel})
    : _channel = channel;
  final MethodChannel _channel;

  @override
  Future<GeoPoint?> currentLocation() async {
    try {
      final map = await _channel.invokeMapMethod<String, Object?>('currentLocation');
      final lat = map?['lat'], lng = map?['lng'];
      if (lat is! num || lng is! num) return null;
      return GeoPoint(lat.toDouble(), lng.toDouble());
    } on PlatformException {
      return null;
    }
  }
}

/// The phone's country: mobile network, then SIM, then locale.
class NativeRegionSource implements RegionSource {
  const NativeRegionSource({MethodChannel channel = nativeChannel})
    : _channel = channel;
  final MethodChannel _channel;

  @override
  Future<String?> countryCode() async {
    try {
      return await _channel.invokeMethod<String>('countryCode');
    } on PlatformException {
      return null;
    }
  }
}
