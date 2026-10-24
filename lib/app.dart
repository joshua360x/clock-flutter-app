import 'package:flutter/material.dart';

import 'app_info.dart';
import 'home/home_controller.dart';
import 'home/home_page.dart';
import 'ui/theme/app_theme.dart';

final _lightTheme = buildAppTheme(Brightness.light);
final _darkTheme = buildAppTheme(Brightness.dark);

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
    ),
  );
}
