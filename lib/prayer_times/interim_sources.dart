import 'dart:ui';

import 'device_context.dart';
import 'geo_point.dart';

/// Stands in until the native location bridge exists (Stage 5): no fix, so
/// the alarms use the fallback times.
class NoLocationSource implements LocationSource {
  const NoLocationSource();

  @override
  Future<GeoPoint?> currentLocation() async => null;
}

/// Country from the phone's locale. The native bridge (Stage 5) prefers the
/// mobile network and SIM, which follow the phone rather than its language.
class LocaleRegionSource implements RegionSource {
  const LocaleRegionSource();

  @override
  Future<String?> countryCode() async =>
      PlatformDispatcher.instance.locale.countryCode;
}
