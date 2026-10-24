import 'package:flutter/material.dart';

import 'app_info.dart';

void main() {
  runApp(const PrayerAlarmApp());
}

/// Stage 1 placeholder. The theme, alarm list and ringing screen replace this
/// in later stages.
class PrayerAlarmApp extends StatelessWidget {
  const PrayerAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const Scaffold(
        body: Center(child: Text(appName)),
      ),
    );
  }
}
