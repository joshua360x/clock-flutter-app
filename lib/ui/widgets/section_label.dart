import 'package:flutter/material.dart';

import '../theme/app_text.dart';

/// 12px uppercase label with wide tracking.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text.toUpperCase(),
      style: AppText.sectionLabel.copyWith(color: color),
    ),
  );
}
