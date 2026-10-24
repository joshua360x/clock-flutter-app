/// Bible translation used everywhere: live requests and bundled verses.
abstract final class ScriptureTranslation {
  /// bible-api.com `translation` value.
  static const id = 'kjv';
  static const name = 'King James Version';
}

/// A passage ready to show: text plus its reference.
class Verse {
  const Verse({required this.reference, required this.text});

  final String reference;
  final String text;

  /// Collapses the raw newlines and runs of spaces bible-api returns
  /// ("\nFor God so loved...\n\n") into display text.
  static String normalize(String raw) =>
      raw.replaceAll('¶', '').replaceAll(RegExp(r'\s+'), ' ').trim();

  Map<String, Object?> toJson() => {'reference': reference, 'text': text};

  static Verse? fromJson(Object? json) {
    if (json is! Map) return null;
    final reference = json['reference'];
    final text = json['text'];
    if (reference is! String || text is! String) return null;
    if (reference.trim().isEmpty || text.trim().isEmpty) return null;
    return Verse(reference: reference.trim(), text: normalize(text));
  }

  @override
  bool operator ==(Object other) =>
      other is Verse && other.reference == reference && other.text == text;

  @override
  int get hashCode => Object.hash(reference, text);

  @override
  String toString() => '$reference: $text';
}

/// Shown if everything else is unavailable, so the alarm is never blank.
const fallbackVerse = Verse(
  reference: 'John 3:16',
  text:
      'For God so loved the world, that he gave his only begotten Son, that '
      'whosoever believeth in him should not perish, but have everlasting '
      'life.',
);
