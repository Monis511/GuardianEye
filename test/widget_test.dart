import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:child_protection_filter/main.dart';

void main() {
  testWidgets('shows the parent dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardianEyeApp());

    expect(find.text('GuardianEye'), findsOneWidget);
    expect(find.text('Protection is active'), findsOneWidget);
    expect(find.text('Parent controls'), findsOneWidget);
    expect(find.text('Device pairing'), findsOneWidget);
  });

  testWidgets('parent can toggle protection', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardianEyeApp());

    final protectionSwitch = find.byType(Switch).first;
    expect(tester.widget<Switch>(protectionSwitch).value, isTrue);

    await tester.tap(protectionSwitch);
    await tester.pump();

    expect(tester.widget<Switch>(protectionSwitch).value, isFalse);
  });
}
