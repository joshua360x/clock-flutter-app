import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'alarms/alarm_settings.dart';
import 'app.dart';
import 'home/home_controller.dart';
import 'prayer_times/aladhan_client.dart';
import 'prayer_times/interim_sources.dart';
import 'prayer_times/prayer_times_service.dart';
import 'prayer_times/timetable_store.dart';
import 'scripture/bible_api_client.dart';
import 'scripture/bundled_verses.dart';
import 'scripture/scripture_service.dart';
import 'scripture/verse.dart';
import 'scripture/verse_cache.dart';
import 'scripture/verse_source.dart';
import 'ui/font_licenses.dart';
import 'ui/theme/theme_preference.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();

  final prefs = await SharedPreferences.getInstance();
  final bundled = await loadBundledVerses(rootBundle);
  final httpClient = http.Client();

  final controller = HomeController(
    prayerTimes: PrayerTimesService(
      client: AlAdhanClient(httpClient: httpClient),
      store: TimetableStore(prefs),
      location: const NoLocationSource(),
      region: const LocaleRegionSource(),
    ),
    scripture: ScriptureService(
      source: CuratedVerseSource(
        BibleApiClient(httpClient: httpClient),
        bundled.isEmpty
            ? [fallbackVerse.reference]
            : [for (final verse in bundled) verse.reference],
      ),
      cache: VerseCache(prefs),
      bundled: bundled,
    ),
    alarmSettingsStore: AlarmSettingsStore(prefs),
    themeStore: ThemePreferenceStore(prefs),
  );

  runApp(PrayerAlarmApp(controller: controller));
}
