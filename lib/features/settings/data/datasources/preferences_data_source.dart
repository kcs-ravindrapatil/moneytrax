import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class PreferencesDataSource {
  Future<bool> isIntroCompleted();
  Future<void> setIntroCompleted(bool value);
  Future<String> getCurrencyCode();
  Future<void> setCurrencyCode(String code);
  Future<bool> areNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool value);
  Future<List<String>> getPaymentMethods();
  Future<void> setPaymentMethods(List<String> methods);
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<bool> isSessionActive();
  Future<void> setSessionActive(bool value);
  Future<void> clearAll();
}

class PreferencesDataSourceImpl implements PreferencesDataSource {
  PreferencesDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> isIntroCompleted() async {
    return _prefs.getBool(AppConstants.prefIntroCompleted) ?? false;
  }

  @override
  Future<void> setIntroCompleted(bool value) async {
    await _prefs.setBool(AppConstants.prefIntroCompleted, value);
  }

  @override
  Future<String> getCurrencyCode() async {
    return _prefs.getString(AppConstants.prefCurrencyCode) ??
        AppConstants.defaultCurrencyCode;
  }

  @override
  Future<void> setCurrencyCode(String code) async {
    await _prefs.setString(AppConstants.prefCurrencyCode, code);
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    return _prefs.getBool(AppConstants.prefNotificationsEnabled) ?? false;
  }

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(AppConstants.prefNotificationsEnabled, value);
  }

  @override
  Future<List<String>> getPaymentMethods() async {
    final raw = _prefs.getString(AppConstants.prefPaymentMethods);
    if (raw == null) return List.from(AppConstants.defaultPaymentMethods);
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      throw const CacheException('Invalid payment methods cache.');
    }
  }

  @override
  Future<void> setPaymentMethods(List<String> methods) async {
    await _prefs.setString(
      AppConstants.prefPaymentMethods,
      jsonEncode(methods),
    );
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final raw = _prefs.getString(AppConstants.prefThemeMode) ??
        AppConstants.defaultThemeMode;
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.prefThemeMode, value);
  }

  @override
  Future<bool> isSessionActive() async {
    // Missing key = upgrade / first install after this feature — stay logged in
    // if the user already had a profile session in practice.
    if (!_prefs.containsKey(AppConstants.prefSessionActive)) {
      return true;
    }
    return _prefs.getBool(AppConstants.prefSessionActive) ?? false;
  }

  @override
  Future<void> setSessionActive(bool value) async {
    await _prefs.setBool(AppConstants.prefSessionActive, value);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
