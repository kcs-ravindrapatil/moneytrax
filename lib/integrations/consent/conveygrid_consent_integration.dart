import 'package:conveygrid_flutter_sdk/conveygrid_flutter_sdk.dart' as cg;
import 'package:flutter/material.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/result/result.dart';
import '../../core/utils/app_logger.dart';
import 'consent_integration.dart';
import 'conveygrid_env.dart';

/// Real ConveyGrid consent integration.
///
/// Only this file (and DI wiring) may import `conveygrid_flutter_sdk`.
class ConveyGridConsentIntegration implements ConsentIntegration {
  ConveyGridConsentIntegration(this._client);

  final cg.ConveyGridClient _client;

  @override
  Future<Result<void>> createConsent({
    required BuildContext context,
    required String fullName,
    required String email,
    required String mobileNumber,
  }) async {
    try {
      if (!_client.isInitialized) {
        final init = await _client.initialize();
        if (init.isFailure) {
          return Error(
            ConsentFailure(
              init.failureOrNull?.message ??
                  'Consent SDK failed to initialize.',
            ),
          );
        }
      }

      final subject = cg.ConveyGridSubject(
        email: email.trim(),
        mobile: mobileNumber.trim(),
        fullName: fullName.trim(),
      );

      final purposeCode = ConveyGridEnv.primaryPurposeCode.trim();
      if (purposeCode.isNotEmpty) {
        final validated = await _client.validateConsent(
          purposeCode: purposeCode,
          noticeCode: ConveyGridEnv.registrationNoticeCode,
          subject: subject,
        );
        if (validated.isSuccess && validated.valueOrNull == true) {
          AppLogger.debug('Consent already valid — skipping consent UI.');
          return const Success(null);
        }
      }

      final noticeResult = await _client.getConsentNotice(
        noticeCode: ConveyGridEnv.registrationNoticeCode,
        subject: subject,
      );
      if (noticeResult.isFailure) {
        return Error(
          ConsentFailure(
            noticeResult.failureOrNull?.message ??
                'Unable to load consent notice.',
          ),
        );
      }

      final notice = noticeResult.valueOrNull!;
      final mandatory = notice.mandatoryPurposes;
      final alreadyGranted = mandatory.isEmpty ||
          mandatory.every((purpose) => purpose.alreadyGranted) ||
          (mandatory.isNotEmpty &&
              mandatory.every(
                (purpose) =>
                    notice.alreadyGrantedPurposeIds
                        .contains(purpose.purposeId) ||
                    notice.alreadyGrantedPurposeIds
                        .contains(purpose.noticePurposeId),
              ));

      if (alreadyGranted || !notice.showNotice) {
        AppLogger.debug(
          'Consent already granted / notice hidden — skipping consent UI.',
        );
        return const Success(null);
      }

      if (!context.mounted) {
        return const Error(
          ConsentFailure('Consent UI context is unavailable.'),
        );
      }

      final uiResult = await _client.showConsentNotice(
        context,
        noticeCode: ConveyGridEnv.registrationNoticeCode,
        subject: subject,
        pageUrl: ConveyGridEnv.pageUrl,
      );

      if (uiResult.isFailure) {
        return Error(
          ConsentFailure(
            uiResult.failureOrNull?.message ?? 'Consent request failed.',
          ),
        );
      }

      final submitted = uiResult.valueOrNull;
      if (submitted == null) {
        return const Error(
          ConsentFailure('Consent is required to continue with MoneyTrax.'),
        );
      }
      if (!submitted.allMandatoryGranted) {
        return const Error(
          ConsentFailure(
            'Please grant all required consents to create your profile.',
          ),
        );
      }

      return const Success(null);
    } on ConsentException catch (e) {
      return Error(ConsentFailure(e.message));
    } catch (e) {
      AppLogger.error('Consent integration error', e);
      return const Error(
        ConsentFailure('Consent processing failed. Please try again.'),
      );
    }
  }

  @override
  Future<Result<void>> revokeConsent() async {
    return const Success(null);
  }
}
