# Alarm audio

Files here are bundled into the app but **not committed** (see `.gitignore`):
personal or copyrighted recordings stay on your machine.

Each prayer plays the first file that exists:

1. `<prayer>.<ext>` for that prayer: `fajr`, `dhuhr`, `asr`, `maghrib`, `isha`
2. `default.<ext>` for every prayer without its own file
3. the built-in bell (`assets/audio/bell.ogg`)

`<ext>` can be `mp3`, `m4a`, `aac`, `ogg` or `wav`. After adding or renaming a
file, rebuild the app (`flutter run` or `flutter build apk`); no code changes.

If a file cannot be played on the phone, the alarm falls back to the bell,
then the phone's default alarm tone, then vibration. It is never silent.
