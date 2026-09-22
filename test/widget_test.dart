import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:conveygrid_moneytracker/app/app.dart';
import 'package:conveygrid_moneytracker/injection/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  testWidgets('MoneyTrax app boots to splash', (tester) async {
    await tester.pumpWidget(MoneyTraxApp());
    await tester.pump();
    expect(find.text('MoneyTrax'), findsWidgets);
    // Finish splash delay so no pending timers remain.
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
