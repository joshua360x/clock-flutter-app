import 'dart:async';

import 'package:flutter/material.dart';

import '../ui/alarm_list/alarm_list_screen.dart';
import 'home_controller.dart';

/// The alarm list wired to [HomeController]: starts it on launch, refreshes
/// on resume, and redraws every 30 s so the next-due highlight moves on time.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final HomeController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
    unawaited(widget.controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      unawaited(widget.controller.refresh());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => AlarmListScreen(
        rows: controller.rows(),
        sourceLine: controller.sourceLine,
        notices: controller.missing.toList()..sort((a, b) => a.index - b.index),
        themeLabel: controller.theme.label,
        testNote: controller.testNote,
        onToggle: controller.setEnabled,
        onFix: controller.fix,
        onCycleTheme: controller.cycleTheme,
        onTestAlarm: controller.testAlarm,
      ),
    );
  }
}
