import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prayer_alarm/alarms/alarm_settings.dart';
import 'package:prayer_alarm/audio/alarm_sound.dart';
import 'package:prayer_alarm/home/home_controller.dart';
import 'package:prayer_alarm/prayer_times/aladhan_client.dart';
import 'package:prayer_alarm/prayer_times/prayer_times_service.dart';
import 'package:prayer_alarm/prayer_times/timetable_store.dart';
import 'package:prayer_alarm/scripture/bible_api_client.dart';
import 'package:prayer_alarm/scripture/scripture_service.dart';
import 'package:prayer_alarm/scripture/verse.dart';
import 'package:prayer_alarm/scripture/verse_cache.dart';
import 'package:prayer_alarm/scripture/verse_source.dart';
import 'package:prayer_alarm/ui/theme/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_alarm_engine.dart';

/// A HomeController on in-memory storage, an offline network, no location
/// and a fake native engine, so widget tests run the real app without I/O.
Future<HomeController> offlineController({
  DateTime Function()? now,
  Map<String, Object> prefs = const {},
  FakeAlarmEngine? engine,
  AlarmSoundResolver? sounds,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final store = await SharedPreferences.getInstance();
  final offline = MockClient(
    (_) async => throw http.ClientException('offline'),
  );
  return HomeController(
    prayerTimes: PrayerTimesService(
      client: AlAdhanClient(httpClient: offline, retryDelay: Duration.zero),
      store: TimetableStore(store),
      location: FakeLocation(),
      region: FakeRegion(),
      now: now,
    ),
    scripture: ScriptureService(
      source: CuratedVerseSource(
        BibleApiClient(httpClient: offline, retryDelay: Duration.zero),
        [fallbackVerse.reference],
      ),
      cache: VerseCache(store),
      bundled: const [fallbackVerse],
      now: now,
    ),
    engine: engine ?? FakeAlarmEngine(),
    sounds: sounds ?? BundledSoundResolver(const []),
    alarmSettingsStore: AlarmSettingsStore(store),
    themeStore: ThemePreferenceStore(store),
    prefs: store,
    now: now,
  );
}
