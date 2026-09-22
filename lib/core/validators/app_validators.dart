import '../error/failures.dart';

class AppValidators {
  AppValidators._();

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 2) return 'Enter at least 2 characters';
    if (v.length > 80) return 'Name is too long';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? mobileNumber(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Mobile number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    if (v.length > 64) return 'Password is too long';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final error = AppValidators.password(value);
    if (error != null) return error;
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? loginIdentifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email or mobile number is required';
    if (v.contains('@')) return AppValidators.email(v);
    return AppValidators.mobileNumber(v);
  }

  static String? amount(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Amount is required';
    final parsed = double.tryParse(v);
    if (parsed == null) return 'Enter a valid amount';
    if (parsed <= 0) return 'Amount must be greater than zero';
    if (parsed > 999999999) return 'Amount is too large';
    return null;
  }

  static String? requiredField(String? value, {String field = 'This field'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$field is required';
    return null;
  }

  static bool isProfileValid({
    required String fullName,
    required String email,
    required String mobileNumber,
    String? password,
    String? confirmPassword,
    bool requirePassword = false,
  }) {
    final base = AppValidators.fullName(fullName) == null &&
        AppValidators.email(email) == null &&
        AppValidators.mobileNumber(mobileNumber) == null;
    if (!base) return false;
    if (!requirePassword) return true;
    return AppValidators.password(password) == null &&
        AppValidators.confirmPassword(confirmPassword, password ?? '') == null;
  }

  static Failure? profileFailure({
    required String fullName,
    required String email,
    required String mobileNumber,
  }) {
    final nameError = AppValidators.fullName(fullName);
    if (nameError != null) return ValidationFailure(nameError);
    final emailError = AppValidators.email(email);
    if (emailError != null) return ValidationFailure(emailError);
    final mobileError = AppValidators.mobileNumber(mobileNumber);
    if (mobileError != null) return ValidationFailure(mobileError);
    return null;
  }
}
