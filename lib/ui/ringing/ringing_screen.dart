import 'package:flutter/material.dart';

import '../../scripture/verse.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/insets.dart';
import '../widgets/clock_text.dart';
import '../widgets/section_label.dart';
import 'scripture_block.dart';

/// Full-screen alarm: label and time at the top, scripture centred in the
/// remaining space, actions at the bottom.
///
/// The two accent uses on this screen are the label and Dismiss. Snooze is a
/// bare muted text button so it is visibly secondary and hard to hit by
/// accident.
class RingingScreen extends StatelessWidget {
  const RingingScreen({
    super.key,
    required this.label,
    required this.time,
    required this.verse,
    required this.onDismiss,
    required this.onSnooze,
  });

  /// Prayer name, shown uppercase.
  final String label;
  final TimeOfDay time;
  final Verse verse;
  final VoidCallback onDismiss;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Insets.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionLabel(label, color: colors.accentText),
              const SizedBox(height: 14),
              // Never wraps: on narrow phones with large system text the
              // clock scales down to the width instead.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ClockText(
                  time,
                  style: AppText.clock.copyWith(color: colors.text),
                  periodStyle: AppText.clockPeriod.copyWith(
                    color: colors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Expanded(child: ScriptureBlock(verse: verse)),
              const SizedBox(height: 32),
              SizedBox(
                height: Insets.dismissHeight,
                child: FilledButton(
                  onPressed: onDismiss,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accentFill,
                    foregroundColor: colors.onAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Insets.dismissRadius),
                    ),
                    textStyle: AppText.button,
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: Insets.snoozeHeight,
                child: TextButton(
                  onPressed: onSnooze,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.muted,
                    textStyle: AppText.button.copyWith(
                      fontWeight: FontWeight.w400,
                      fontVariations: const [FontVariation.weight(400)],
                    ),
                  ),
                  child: const Text('Snooze'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
