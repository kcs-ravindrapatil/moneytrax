import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conveygrid_moneytracker/core/result/result.dart';
import 'package:conveygrid_moneytracker/integrations/consent/noop_consent_integration.dart';

void main() {
  test('NoOpConsentIntegration succeeds without transmitting data', () async {
    final consent = NoOpConsentIntegration();
    final create = await consent.createConsent(
      context: _FakeBuildContext(),
      fullName: 'Alex',
      email: 'alex@example.com',
      mobileNumber: '9876543210',
    );
    final revoke = await consent.revokeConsent();
    expect(create, isA<Success<void>>());
    expect(revoke, isA<Success<void>>());
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
