import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conveygrid_moneytracker/features/onboarding/presentation/pages/welcome_page.dart';

void main() {
  testWidgets('Welcome shows branding and Get Started', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WelcomePage()),
    );
    expect(find.text('MoneyTrax'), findsOneWidget);
    expect(find.textContaining('expense tracker'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
