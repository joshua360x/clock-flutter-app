import 'dart:math' as math;

/// A position in decimal degrees.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Great-circle distance in kilometres (haversine).
  double distanceKmTo(GeoPoint other) {
    const earthRadiusKm = 6371.0;
    double rad(double degrees) => degrees * math.pi / 180;
    final dLat = rad(other.latitude - latitude);
    final dLon = rad(other.longitude - longitude);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) *
            math.cos(rad(other.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }

  Map<String, Object?> toJson() => {'lat': latitude, 'lng': longitude};

  static GeoPoint? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = json['lat'];
    final lng = json['lng'];
    if (lat is! num || lng is! num) return null;
    return GeoPoint(lat.toDouble(), lng.toDouble());
  }

  @override
  String toString() => '($latitude, $longitude)';
}
