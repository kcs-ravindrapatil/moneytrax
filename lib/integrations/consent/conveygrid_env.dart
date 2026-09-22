/// ConveyGrid host-app configuration.
///
/// Resolution order per key:
/// 1. `--dart-define=KEY=...` (compile-time)
/// 2. `.env` file values (runtime via [loadFrom])
/// 3. built-in defaults
class ConveyGridEnv {
  ConveyGridEnv._();

  static Map<String, String> _fileValues = const {};

  static void loadFrom(Map<String, String> fileValues) {
    _fileValues = Map.unmodifiable(fileValues);
  }

  static const String _apiBaseUrlDefine = String.fromEnvironment(
    'CONVEYGRID_API_BASE_URL',
  );
  static const String _applicationKeyDefine = String.fromEnvironment(
    'CONVEYGRID_APPLICATION_KEY',
  );
  static const String _dfOriginDefine = String.fromEnvironment(
    'CONVEYGRID_DF_ORIGIN',
  );
  static const String _dfRefererDefine = String.fromEnvironment(
    'CONVEYGRID_DF_REFERER',
  );
  static const String _noticeCodeDefine = String.fromEnvironment(
    'CONVEYGRID_NOTICE_CODE',
  );
  static const String _bookingNoticeCodeDefine = String.fromEnvironment(
    'CONVEYGRID_BOOKING_NOTICE_CODE',
  );
  static const String _purposeCodeDefine = String.fromEnvironment(
    'CONVEYGRID_PURPOSE_CODE',
  );
  static const String _pageUrlDefine = String.fromEnvironment(
    'CONVEYGRID_PAGE_URL',
  );
  static const String _cookieConfigCodeDefine = String.fromEnvironment(
    'CONVEYGRID_COOKIE_CONFIG_CODE',
  );

  static String _resolve(
    String key, {
    required String defineValue,
    String fallback = '',
  }) {
    final fromDefine = defineValue.trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromFile = _fileValues[key]?.trim() ?? '';
    if (fromFile.isNotEmpty) return fromFile;
    return fallback;
  }

  static String get apiBaseUrl => _resolve(
        'CONVEYGRID_API_BASE_URL',
        defineValue: _apiBaseUrlDefine,
        fallback: 'https://conveygridapidev.rysun.in',
      );

  static String get applicationKey => _resolve(
        'CONVEYGRID_APPLICATION_KEY',
        defineValue: _applicationKeyDefine,
      );

  static String get dfOrigin => _resolve(
        'CONVEYGRID_DF_ORIGIN',
        defineValue: _dfOriginDefine,
        fallback: 'https://conveygridapidev.rysun.in/',
      );

  static String get dfReferer => _resolve(
        'CONVEYGRID_DF_REFERER',
        defineValue: _dfRefererDefine,
        fallback: 'https://conveygridapidev.rysun.in/',
      );

  /// Registration / consent notice code (iOS: `NOTICE_001`).
  ///
  /// Prefers `CONVEYGRID_NOTICE_CODE`, then `CONVEYGRID_BOOKING_NOTICE_CODE`.
  static String get registrationNoticeCode {
    final notice = _resolve(
      'CONVEYGRID_NOTICE_CODE',
      defineValue: _noticeCodeDefine,
    );
    if (notice.isNotEmpty) return notice;
    return _resolve(
      'CONVEYGRID_BOOKING_NOTICE_CODE',
      defineValue: _bookingNoticeCodeDefine,
      fallback: 'NOTICE_001',
    );
  }

  static String get primaryPurposeCode => _resolve(
        'CONVEYGRID_PURPOSE_CODE',
        defineValue: _purposeCodeDefine,
      );

  static String get pageUrl => _resolve(
        'CONVEYGRID_PAGE_URL',
        defineValue: _pageUrlDefine,
        fallback: 'https://conveygridapidev.rysun.in/',
      );

  static String get cookieConfigCode => _resolve(
        'CONVEYGRID_COOKIE_CONFIG_CODE',
        defineValue: _cookieConfigCodeDefine,
        fallback: 'LUXESTAY_COOKIE_BANNER',
      );

  static bool get hasApplicationKey {
    final key = applicationKey.trim();
    if (key.isEmpty) return false;
    // Placeholder from .env.example — treat as unset.
    if (key == 'your_application_key' || key == 'your_key') return false;
    return true;
  }
}
