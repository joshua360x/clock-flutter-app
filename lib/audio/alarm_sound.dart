import 'package:flutter/services.dart';

import '../prayer_times/prayer.dart';

/// What an alarm plays. The native engine receives [toWire] and resolves it.
sealed class AlarmSound {
  const AlarmSound();

  Map<String, Object?> toWire();
}

/// A file bundled with the app (a Flutter asset path).
final class AssetSound extends AlarmSound {
  const AssetSound(this.assetPath);
  final String assetPath;

  @override
  Map<String, Object?> toWire() => {'kind': 'asset', 'path': assetPath};

  @override
  bool operator ==(Object other) => other is AssetSound && other.assetPath == assetPath;

  @override
  int get hashCode => assetPath.hashCode;

  @override
  String toString() => 'AssetSound($assetPath)';
}

/// A file on the phone, e.g. a prayer recorded in the app later.
final class FileSound extends AlarmSound {
  const FileSound(this.filePath);
  final String filePath;

  @override
  Map<String, Object?> toWire() => {'kind': 'file', 'path': filePath};

  @override
  bool operator ==(Object other) => other is FileSound && other.filePath == filePath;

  @override
  int get hashCode => filePath.hashCode;
}

/// Built-in, always present; played when nothing else is available or a
/// chosen file cannot be played.
const bellSound = AssetSound('assets/audio/bell.ogg');

/// Decides what each prayer's alarm plays. Per-alarm audio (bundled files
/// now, in-app recordings later) means another implementation of this.
abstract interface class AlarmSoundResolver {
  AlarmSound soundFor(Prayer prayer);
}

/// Drop-in files in assets/audio/custom/: `<prayer>.<ext>` for one prayer,
/// `default.<ext>` for the rest, otherwise the bell.
class BundledSoundResolver implements AlarmSoundResolver {
  BundledSoundResolver(Iterable<String> assets) : _assets = assets.toSet();

  final Set<String> _assets;

  static const directory = 'assets/audio/custom';
  static const extensions = ['mp3', 'm4a', 'aac', 'ogg', 'wav'];

  static Future<BundledSoundResolver> load(AssetBundle bundle) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(bundle);
      return BundledSoundResolver(manifest.listAssets());
    } on Exception {
      return BundledSoundResolver(const []);
    }
  }

  @override
  AlarmSound soundFor(Prayer prayer) =>
      _find(prayer.name) ?? _find('default') ?? bellSound;

  AssetSound? _find(String name) {
    for (final ext in extensions) {
      final path = '$directory/$name.$ext';
      if (_assets.contains(path)) return AssetSound(path);
    }
    return null;
  }
}
