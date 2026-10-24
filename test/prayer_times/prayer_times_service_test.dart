import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prayer_alarm/prayer_times/aladhan_client.dart';
import 'package:prayer_alarm/prayer_times/calculation_method.dart';
import 'package:prayer_alarm/prayer_times/device_context.dart';
import 'package:prayer_alarm/prayer_times/geo_point.dart';
import 'package:prayer_alarm/prayer_times/prayer_times_service.dart';
import 'package:prayer_alarm/prayer_times/timetable_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/aladhan_fixtures.dart';
import '../support/tz_zone_rules.dart';

class FakeLocation implements LocationSource {
  GeoPoint? point = const GeoPoint(40.7128, -74.006);

  @override
  Future<GeoPoint?> currentLocation() async => point;
}

class FakeRegion implements RegionSource {
  String? country = 'US';

  @override
  Future<String?> countryCode() async => country;
}

void main() {
  final fixtures = AlAdhanFixtures();
  late List<Uri> requests;
  late bool serverDown;
  late FakeLocation location;
  late FakeRegion region;
  late SharedPreferences prefs;
  late DateTime now;

  setUp(() async {
    requests = [];
    serverDown = false;
    location = FakeLocation();
    region = FakeRegion();
    now = DateTime(2026, 10, 25, 14);
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  PrayerTimesService service() => PrayerTimesService(
    client: AlAdhanClient(
      httpClient: MockClient((request) async {
        requests.add(request.url);
        if (serverDown) return http.Response('', 503);
        final [_, _, year, month] = request.url.pathSegments;
        return http.Response(
          fixtures.monthBody(int.parse(year), int.parse(month)),
          200,
        );
      }),
      retryDelay: Duration.zero,
      zoneRulesFor: (zone) => TzZoneRules(zone ?? 'America/New_York'),
    ),
    store: TimetableStore(prefs),
    location: location,
    region: region,
    now: () => now,
  );

  test('first run fetches the months covering the next 60 days', () async {
    final outcome = await service().refresh();

    final timetable = (outcome as TimetableUpdated).timetable;
    expect(requests.map((u) => u.path), [
      '/v1/calendar/2026/10',
      '/v1/calendar/2026/11',
      '/v1/calendar/2026/12',
    ]);
    expect(timetable.method, CalculationMethods.isna);
    expect(timetable.days.first.date, DateTime.utc(2026, 10, 25));
    expect(timetable.days.last.date, DateTime.utc(2026, 12, 31));
    expect(timetable.timeZone, 'America/New_York');
  });

  test('the timetable survives a restart', () async {
    await service().refresh();

    expect(service().timetable?.days.first.date, DateTime.utc(2026, 10, 25));
  });

  test('same place, enough days left: no network', () async {
    await service().refresh();
    requests.clear();

    expect(await service().refresh(), isA<TimetableCurrent>());
    expect(requests, isEmpty);
  });

  test('a small move (2 km) does not refetch; a large move (50 km) does', () async {
    await service().refresh();
    requests.clear();

    location.point = const GeoPoint(40.73, -74.0);
    expect(await service().refresh(), isA<TimetableCurrent>());

    location.point = const GeoPoint(40.3, -74.6);
    final outcome = await service().refresh();
    expect(outcome, isA<TimetableUpdated>());
    expect(
      (outcome as TimetableUpdated).timetable.location.latitude,
      40.3,
    );
  });

  test('a new country with a different method refetches with that method', () async {
    await service().refresh();
    requests.clear();

    region.country = 'TR';
    final outcome = await service().refresh();

    expect((outcome as TimetableUpdated).timetable.method.id, 13);
    expect(requests.first.queryParameters['method'], '13');
  });

  test('fewer than 21 days left: refetch from today', () async {
    await service().refresh();
    requests.clear();

    now = DateTime(2026, 12, 15, 9);
    final outcome = await service().refresh();

    expect(outcome, isA<TimetableUpdated>());
    expect(requests.first.path, '/v1/calendar/2026/12');
    expect(requests.last.path, '/v1/calendar/2027/2');
  });

  test('a failed fetch keeps the old timetable', () async {
    await service().refresh();
    final before = service().timetable!;
    serverDown = true;
    location.point = const GeoPoint(51.5, -0.12);

    final s = service();
    final outcome = await s.refresh();

    expect((outcome as RefreshFailed).failure, isA<AlAdhanServerError>());
    expect(s.timetable!.location.latitude, before.location.latitude);
    expect(service().timetable!.days.length, before.days.length);
  });

  test('no location fix: keep using the cached location', () async {
    await service().refresh();
    requests.clear();
    location.point = null;

    expect(await service().refresh(), isA<TimetableCurrent>());
    expect(requests, isEmpty);
  });

  test('no location fix and nothing cached: nothing to fetch', () async {
    location.point = null;

    expect(await service().refresh(), isA<LocationUnavailable>());
    expect(requests, isEmpty);
  });
}
