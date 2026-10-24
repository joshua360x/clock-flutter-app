import 'package:flutter/material.dart';

import '../../prayer_times/prayer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/insets.dart';
import '../widgets/clock_text.dart';
import '../widgets/section_label.dart';

/// One prayer's row: its next ring time and whether the alarm is on.
class AlarmRowData {
  const AlarmRowData({
    required this.prayer,
    required this.time,
    required this.enabled,
    required this.isNextDue,
  });

  final Prayer prayer;
  final TimeOfDay time;
  final bool enabled;

  /// The only row drawn in the accent colour.
  final bool isNextDue;
}

/// The five prayer alarms. One row per time, hairline dividers, toggle on
/// the right; switched-off rows drop to the muted colour.
class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({
    super.key,
    required this.rows,
    required this.sourceLine,
    required this.themeLabel,
    required this.onToggle,
    required this.onCycleTheme,
    required this.onPreviewAlarm,
  });

  final List<AlarmRowData> rows;

  /// Where the times come from, e.g. "AlAdhan · Islamic Society of North
  /// America", or why they are approximate.
  final String sourceLine;
  final String themeLabel;
  final void Function(Prayer prayer, bool enabled) onToggle;
  final VoidCallback onCycleTheme;
  final VoidCallback onPreviewAlarm;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: Insets.screen,
          children: [
            SectionLabel('Prayer times', color: colors.muted),
            const SizedBox(height: 10),
            Text(sourceLine, style: AppText.small.copyWith(color: colors.muted)),
            const SizedBox(height: 20),
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) const Divider(),
              _AlarmRow(row: row, onToggle: onToggle),
            ],
            const SizedBox(height: 40),
            Wrap(
              spacing: 28,
              children: [
                // Zero side padding so the text sits on the 28dp margin like
                // everything above it; the 48dp target comes from minimumSize.
                for (final (label, onPressed) in [
                  ('Theme · $themeLabel', onCycleTheme),
                  ('Preview alarm', onPreviewAlarm),
                ])
                  TextButton(
                    onPressed: onPressed,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlarmRow extends StatelessWidget {
  const _AlarmRow({required this.row, required this.onToggle});

  final AlarmRowData row;
  final void Function(Prayer prayer, bool enabled) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final timeColor = !row.enabled
        ? colors.muted
        : row.isNextDue
        ? colors.accentText
        : colors.text;

    return MergeSemantics(
      child: InkWell(
        onTap: () => onToggle(row.prayer, !row.enabled),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Insets.minTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.rowVertical),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClockText(
                        row.time,
                        style: AppText.rowTime.copyWith(color: timeColor),
                        periodStyle: AppText.small.copyWith(color: colors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        row.prayer.label,
                        style: AppText.rowLabel.copyWith(
                          color: row.enabled ? colors.text : colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: row.enabled,
                  onChanged: (on) => onToggle(row.prayer, on),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
