class AppConstants {
  AppConstants._();

  static const String appName = 'MoneyTrax';
  static const String appTagline = 'Your simple daily expense tracker.';
  static const String appSlogan = 'Track. Understand. Save.';
  static const String prefIntroCompleted = 'intro_completed';
  static const String prefCurrencyCode = 'currency_code';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefPaymentMethods = 'payment_methods';
  static const String prefThemeMode = 'theme_mode';
  static const String prefSessionActive = 'session_active';
  static const String defaultCurrencyCode = 'INR';
  static const String defaultThemeMode = 'system';
  static const List<String> defaultPaymentMethods = [
    'Cash',
    'UPI',
    'Card',
    'Bank Transfer',
    'Other',
  ];
}
