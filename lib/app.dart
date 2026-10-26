import 'package:flutter/material.dart';

import 'app_info.dart';
import 'home/home_controller.dart';
import 'home/home_page.dart';
import 'ui/ringing/ringing_screen.dart';
import 'ui/theme/app_theme.dart';

final _lightTheme = buildAppTheme(Brightness.light);
final _darkTheme = buildAppTheme(Brightness.dark);

/// While an alarm rings, the ringing screen covers everything (including a
/// cold start from the full-screen notification); when it stops, whatever
/// was underneath is still there.
class PrayerAlarmApp extends StatelessWidget {
  const PrayerAlarmApp({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      themeMode: controller.theme.mode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: HomePage(controller: controller),
      builder: (context, navigator) {
        final ringing = controller.ringing;
        return Stack(
          children: [
            navigator!,
            if (ringing != null)
              Positioned.fill(
                child: RingingScreen(
                  key: ValueKey(ringing.ringKey),
                  label: ringing.label,
                  time: TimeOfDay.fromDateTime(ringing.scheduledAt),
                  verse: controller.ringingVerse!,
                  onDismiss: controller.dismiss,
                  onSnooze: controller.snooze,
                ),
              ),
          ],
        );
      },
    ),
  );
}
