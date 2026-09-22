part of 'settings_bloc.dart';

enum SettingsStatus { initial, loading, success, deleting, deleted, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.currencyCode = 'INR',
    this.notificationsEnabled = false,
    this.paymentMethods = const [],
    this.showNotificationExplanation = false,
    this.errorMessage,
  });

  final SettingsStatus status;
  final String currencyCode;
  final bool notificationsEnabled;
  final List<String> paymentMethods;
  final bool showNotificationExplanation;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    String? currencyCode,
    bool? notificationsEnabled,
    List<String>? paymentMethods,
    bool? showNotificationExplanation,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      currencyCode: currencyCode ?? this.currencyCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      showNotificationExplanation:
          showNotificationExplanation ?? this.showNotificationExplanation,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currencyCode,
        notificationsEnabled,
        paymentMethods,
        showNotificationExplanation,
        errorMessage,
      ];
}
