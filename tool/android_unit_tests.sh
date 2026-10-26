#!/bin/sh
# Runs the native alarm engine's JVM unit tests (android/app/src/test).
#
# Gradle is started with the JDK pinned by `flutter config --jdk-dir` (JDK 17),
# never whatever JAVA_HOME points at: Android Studio's bundled JDK 25 cannot
# run Gradle 8.12. This changes no settings.
set -e
JDK=$(flutter config --list 2>/dev/null | sed -n 's/^ *jdk-dir: //p' | head -n 1)
if [ -z "$JDK" ] || [ ! -d "$JDK" ]; then
  echo "flutter config has no jdk-dir; expected the pinned JDK 17." >&2
  exit 1
fi
cd "$(dirname "$0")/../android"
JAVA_HOME="$JDK" ./gradlew :app:testDebugUnitTest "$@"
