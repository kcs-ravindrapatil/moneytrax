part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthIdentifierChanged extends AuthEvent {
  const AuthIdentifierChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class AuthPasswordChanged extends AuthEvent {
  const AuthPasswordChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class AuthConfirmPasswordChanged extends AuthEvent {
  const AuthConfirmPasswordChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class AuthEmailChanged extends AuthEvent {
  const AuthEmailChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class AuthMobileChanged extends AuthEvent {
  const AuthMobileChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class AuthObscureToggled extends AuthEvent {
  const AuthObscureToggled();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted();
}

class AuthResetSubmitted extends AuthEvent {
  const AuthResetSubmitted();
}
