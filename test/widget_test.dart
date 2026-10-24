import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_alarm/app_info.dart';
import 'package:prayer_alarm/main.dart';

void main() {
  testWidgets('app starts and shows its name', (tester) async {
    await tester.pumpWidget(const PrayerAlarmApp());

    expect(find.text(appName), findsOneWidget);
  });
}
