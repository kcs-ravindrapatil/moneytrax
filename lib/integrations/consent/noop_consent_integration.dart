import 'package:flutter/widgets.dart';

import '../../core/result/result.dart';
import 'consent_integration.dart';

/// Fallback when ConveyGrid is not configured (missing application key).
class NoOpConsentIntegration implements ConsentIntegration {
  @override
  Future<Result<void>> createConsent({
    required BuildContext context,
    required String fullName,
    required String email,
    required String mobileNumber,
  }) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> revokeConsent() async {
    return const Success(null);
  }
}
