import 'package:flutter_test/flutter_test.dart';

import 'package:conveygrid_moneytracker/core/validators/app_validators.dart';

void main() {
  group('AppValidators', () {
    test('fullName rejects empty and short values', () {
      expect(AppValidators.fullName(''), isNotNull);
      expect(AppValidators.fullName('A'), isNotNull);
      expect(AppValidators.fullName('Alex Kumar'), isNull);
    });

    test('email validates format', () {
      expect(AppValidators.email('bad'), isNotNull);
      expect(AppValidators.email('user@example.com'), isNull);
    });

    test('mobileNumber requires enough digits', () {
      expect(AppValidators.mobileNumber('123'), isNotNull);
      expect(AppValidators.mobileNumber('9876543210'), isNull);
    });

    test('amount must be positive', () {
      expect(AppValidators.amount('0'), isNotNull);
      expect(AppValidators.amount('-5'), isNotNull);
      expect(AppValidators.amount('250.50'), isNull);
    });

    test('isProfileValid requires all fields', () {
      expect(
        AppValidators.isProfileValid(
          fullName: 'Alex',
          email: 'a@b.com',
          mobileNumber: '9876543210',
        ),
        isTrue,
      );
      expect(
        AppValidators.isProfileValid(
          fullName: '',
          email: 'a@b.com',
          mobileNumber: '9876543210',
        ),
        isFalse,
      );
    });
  });
}
