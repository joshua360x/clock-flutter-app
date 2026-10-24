import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prayer_alarm/alarms/alarm_settings.dart';
import 'package:prayer_alarm/home/home_controller.dart';
import 'package:prayer_alarm/prayer_times/aladhan_client.dart';
import 'package:prayer_alarm/prayer_times/interim_sources.dart';
import 'package:prayer_alarm/prayer_times/prayer_times_service.dart';
import 'package:prayer_alarm/prayer_times/timetable_store.dart';
import 'package:prayer_alarm/scripture/bible_api_client.dart';
import 'package:prayer_alarm/scripture/scripture_service.dart';
import 'package:prayer_alarm/scripture/verse.dart';
import 'package:prayer_alarm/scripture/verse_cache.dart';
import 'package:prayer_alarm/scripture/verse_source.dart';
import 'package:prayer_alarm/ui/theme/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A HomeController wired to in-memory storage and an offline network, so
/// widget tests exercise the real app without I/O.
Future<HomeController> offlineController({
  DateTime Function()? now,
  Map<String, Object> prefs = const {},
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
      location: const NoLocationSource(),
      region: const LocaleRegionSource(),
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
    alarmSettingsStore: AlarmSettingsStore(store),
    themeStore: ThemePreferenceStore(store),
    now: now,
  );
}
