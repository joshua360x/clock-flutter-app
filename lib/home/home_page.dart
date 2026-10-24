import 'dart:async';

import 'package:flutter/material.dart';

import '../ui/alarm_list/alarm_list_screen.dart';
import '../ui/ringing/ringing_screen.dart';
import 'home_controller.dart';

/// Wires the alarm list to [HomeController]: refreshes on launch and resume,
/// and redraws every minute so the next-due highlight moves on time.
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
    unawaited(widget.controller.refresh());
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

  void _previewAlarm() {
    final controller = widget.controller;
    final due = controller.schedule.nextDue(
      controller.settings.enabled,
      controller.now(),
    );
    final rows = controller.rows();
    final row = rows.firstWhere(
      (r) => r.prayer == due?.prayer,
      orElse: () => rows.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => RingingScreen(
          label: row.prayer.label,
          time: row.time,
          verse: controller.scripture.verseForAlarm(
            'preview@${DateTime.now().millisecondsSinceEpoch}',
          ),
          onDismiss: () => Navigator.of(context).pop(),
          onSnooze: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => AlarmListScreen(
        rows: controller.rows(),
        sourceLine: controller.sourceLine,
        themeLabel: controller.theme.label,
        onToggle: controller.setEnabled,
        onCycleTheme: controller.cycleTheme,
        onPreviewAlarm: _previewAlarm,
      ),
    );
  }
}
