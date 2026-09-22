import 'package:flutter/widgets.dart';

import '../../core/result/result.dart';

abstract class ConsentIntegration {
  /// Creates or verifies consent for the registered user.
  ///
  /// [context] is required when the SDK must present a consent UI.
  /// If consent was already granted for mandatory purposes, implementations
  /// must skip showing any popup.
  Future<Result<void>> createConsent({
    required BuildContext context,
    required String fullName,
    required String email,
    required String mobileNumber,
  });

  Future<Result<void>> revokeConsent();
}
