import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/notification_service.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../data/datasources/preferences_data_source.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required PreferencesDataSource preferences,
    required NotificationService notificationService,
    required DeleteProfileUseCase deleteProfile,
  })  : _preferences = preferences,
        _notifications = notificationService,
        _deleteProfile = deleteProfile,
        super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsCurrencyChanged>(_onCurrency);
    on<SettingsNotificationsToggled>(_onNotifications);
    on<SettingsNotificationsConfirmed>(_onNotificationsConfirmed);
    on<SettingsNotificationsExplanationDismissed>(_onExplanationDismissed);
    on<SettingsPaymentMethodsUpdated>(_onPaymentMethods);
    on<SettingsDeleteProfileRequested>(_onDelete);
  }

  final PreferencesDataSource _preferences;
  final NotificationService _notifications;
  final DeleteProfileUseCase _deleteProfile;

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final currency = await _preferences.getCurrencyCode();
    final notifications = await _preferences.areNotificationsEnabled();
    final methods = await _preferences.getPaymentMethods();
    emit(
      state.copyWith(
        status: SettingsStatus.success,
        currencyCode: currency,
        notificationsEnabled: notifications,
        paymentMethods: methods,
      ),
    );
  }

  Future<void> _onCurrency(
    SettingsCurrencyChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _preferences.setCurrencyCode(event.code);
    emit(state.copyWith(currencyCode: event.code));
  }

  Future<void> _onNotifications(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (event.enabled) {
      emit(state.copyWith(showNotificationExplanation: true));
      return;
    }
    await _preferences.setNotificationsEnabled(false);
    await _notifications.cancelReminders();
    emit(
      state.copyWith(
        notificationsEnabled: false,
        showNotificationExplanation: false,
      ),
    );
  }

  Future<void> _onNotificationsConfirmed(
    SettingsNotificationsConfirmed event,
    Emitter<SettingsState> emit,
  ) async {
    final granted = await _notifications.requestPermission();
    if (!granted) {
      emit(
        state.copyWith(
          showNotificationExplanation: false,
          errorMessage: 'Notification permission was not granted.',
        ),
      );
      return;
    }
    await _preferences.setNotificationsEnabled(true);
    await _notifications.scheduleDailyReminders();
    emit(
      state.copyWith(
        notificationsEnabled: true,
        showNotificationExplanation: false,
        errorMessage: null,
      ),
    );
  }

  void _onExplanationDismissed(
    SettingsNotificationsExplanationDismissed event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(showNotificationExplanation: false));
  }

  Future<void> _onPaymentMethods(
    SettingsPaymentMethodsUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    await _preferences.setPaymentMethods(event.methods);
    emit(state.copyWith(paymentMethods: event.methods));
  }

  Future<void> _onDelete(
    SettingsDeleteProfileRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.deleting));
    final result = await _deleteProfile();
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (_) => emit(state.copyWith(status: SettingsStatus.deleted)),
    );
  }
}
