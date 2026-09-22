import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/settings/data/datasources/preferences_data_source.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._preferences) : super(const ThemeState()) {
    on<ThemeStarted>(_onStarted);
    on<ThemeModeSelected>(_onSelected);
  }

  final PreferencesDataSource _preferences;

  Future<void> _onStarted(
    ThemeStarted event,
    Emitter<ThemeState> emit,
  ) async {
    final mode = await _preferences.getThemeMode();
    emit(ThemeState(themeMode: mode));
  }

  Future<void> _onSelected(
    ThemeModeSelected event,
    Emitter<ThemeState> emit,
  ) async {
    await _preferences.setThemeMode(event.themeMode);
    emit(ThemeState(themeMode: event.themeMode));
  }
}
