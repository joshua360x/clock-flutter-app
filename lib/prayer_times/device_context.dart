import 'geo_point.dart';

/// The phone's position, used to fetch prayer times. Implemented natively
/// (one coarse fix, foreground only) in the alarm engine stage.
abstract interface class LocationSource {
  /// Null when permission is denied, location is off, or no fix arrives.
  Future<GeoPoint?> currentLocation();
}

/// The phone's country, used to pick the calculation method.
abstract interface class RegionSource {
  /// ISO 3166-1 alpha-2 (e.g. "US"), from the mobile network, then the SIM,
  /// then the locale. Null if none is known.
  Future<String?> countryCode();
}
