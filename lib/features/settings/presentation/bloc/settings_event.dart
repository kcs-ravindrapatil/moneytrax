part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

class SettingsCurrencyChanged extends SettingsEvent {
  const SettingsCurrencyChanged(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

class SettingsNotificationsToggled extends SettingsEvent {
  const SettingsNotificationsToggled(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}

class SettingsNotificationsConfirmed extends SettingsEvent {
  const SettingsNotificationsConfirmed();
}

class SettingsNotificationsExplanationDismissed extends SettingsEvent {
  const SettingsNotificationsExplanationDismissed();
}

class SettingsPaymentMethodsUpdated extends SettingsEvent {
  const SettingsPaymentMethodsUpdated(this.methods);
  final List<String> methods;
  @override
  List<Object?> get props => [methods];
}

class SettingsDeleteProfileRequested extends SettingsEvent {
  const SettingsDeleteProfileRequested();
}
