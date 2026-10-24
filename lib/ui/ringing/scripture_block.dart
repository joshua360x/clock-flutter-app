import 'package:flutter/material.dart';

import '../../scripture/verse.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// The verse in Lora with its reference beneath, centred vertically in the
/// space it is given.
///
/// Starts at the 23px design size and steps down only if a long verse (or a
/// large system font size) would not fit; below 18px it scrolls instead, so
/// text is never clipped.
class ScriptureBlock extends StatelessWidget {
  const ScriptureBlock({super.key, required this.verse});

  final Verse verse;

  static const _sizes = [23.0, 21.0, 19.0, 18.0];
  static const _gap = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final referenceStyle = AppText.reference.copyWith(color: colors.muted);
    final referenceText = '${verse.reference} · ${ScriptureTranslation.id.toUpperCase()}';

    Widget content(TextStyle style) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(verse.text, style: style),
        const SizedBox(height: _gap),
        Text(referenceText, style: referenceStyle),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        double height(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: scaler,
          )..layout(maxWidth: constraints.maxWidth);
          final h = painter.height;
          painter.dispose();
          return h;
        }

        final referenceHeight = height(referenceText, referenceStyle);
        for (final size in _sizes) {
          final style = AppText.scripture.copyWith(
            fontSize: size,
            color: colors.text,
          );
          if (height(verse.text, style) + _gap + referenceHeight <=
              constraints.maxHeight) {
            return Align(alignment: Alignment.centerLeft, child: content(style));
          }
        }
        return SingleChildScrollView(
          child: content(
            AppText.scripture.copyWith(fontSize: _sizes.last, color: colors.text),
          ),
        );
      },
    );
  }
}
