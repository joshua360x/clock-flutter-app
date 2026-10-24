# CLAUDE.md

## Environment — hard constraints, read before planning
- Mid-2015 MacBook Pro, Intel x64, macOS 12.7.2. Cannot be upgraded. Ever.
- Flutter 3.35.0 / Dart 3.9.0 at ~/Downloads/flutter, detached HEAD at tag 3.35.0.
- NEVER run `flutter upgrade`, `flutter channel`, or any command that changes the
  Flutter version. Newer Dart SDKs refuse to start on macOS 12 — this already broke
  my install once. If you think a version change is needed, STOP and tell me. Use
  `git checkout <tag>` only, and only with my approval.
- Flutter is pinned to JDK 17 via `flutter config --jdk-dir`. Do NOT change the JDK.
  Android Studio bundles JDK 25, which Gradle 8.12 cannot use — that combination
  fails with a bare "25.0.3" error. Do not bump Gradle or AGP without checking the
  Gradle/Java compatibility matrix first.
- iOS/macOS targets are impossible (Xcode cannot be updated on this OS). `flutter
  doctor` will ALWAYS show Xcode and CocoaPods errors — IGNORE THEM COMPLETELY.
  Never try to fix them. Never write iOS code.
- A clean `flutter create` + `flutter build apk --debug` is verified working.
- All packages must support Dart 3.9.0. Verify constraints before adding.
