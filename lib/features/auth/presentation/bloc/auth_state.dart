part of 'auth_bloc.dart';

enum AuthStatus { initial, submitting, success, resetSuccess, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.identifier = '',
    this.password = '',
    this.confirmPassword = '',
    this.email = '',
    this.mobileNumber = '',
    this.obscurePassword = true,
    this.errorMessage,
  });

  final AuthStatus status;
  final String identifier;
  final String password;
  final String confirmPassword;
  final String email;
  final String mobileNumber;
  final bool obscurePassword;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? identifier,
    String? password,
    String? confirmPassword,
    String? email,
    String? mobileNumber,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        identifier,
        password,
        confirmPassword,
        email,
        mobileNumber,
        obscurePassword,
        errorMessage,
      ];
}
