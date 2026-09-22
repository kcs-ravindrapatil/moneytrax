import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/validators/app_validators.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase login,
    required ResetPasswordUseCase resetPassword,
  })  : _login = login,
        _resetPassword = resetPassword,
        super(const AuthState()) {
    on<AuthIdentifierChanged>(_onIdentifier);
    on<AuthPasswordChanged>(_onPassword);
    on<AuthConfirmPasswordChanged>(_onConfirm);
    on<AuthEmailChanged>(_onEmail);
    on<AuthMobileChanged>(_onMobile);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthResetSubmitted>(_onReset);
    on<AuthObscureToggled>(_onObscure);
  }

  final LoginUseCase _login;
  final ResetPasswordUseCase _resetPassword;

  void _onIdentifier(AuthIdentifierChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(identifier: event.value, errorMessage: null));
  }

  void _onPassword(AuthPasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(password: event.value, errorMessage: null));
  }

  void _onConfirm(AuthConfirmPasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(confirmPassword: event.value, errorMessage: null));
  }

  void _onEmail(AuthEmailChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(email: event.value, errorMessage: null));
  }

  void _onMobile(AuthMobileChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(mobileNumber: event.value, errorMessage: null));
  }

  void _onObscure(AuthObscureToggled event, Emitter<AuthState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final idError = AppValidators.loginIdentifier(state.identifier);
    final passError = AppValidators.password(state.password);
    if (idError != null || passError != null) {
      emit(
        state.copyWith(
          errorMessage: idError ?? passError,
          status: AuthStatus.failure,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AuthStatus.submitting, errorMessage: null));
    final result = await _login(
      identifier: state.identifier.trim(),
      password: state.password,
    );
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: f.message),
      ),
      onSuccess: (_) => emit(state.copyWith(status: AuthStatus.success)),
    );
  }

  Future<void> _onReset(
    AuthResetSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = AppValidators.email(state.email);
    final mobileError = AppValidators.mobileNumber(state.mobileNumber);
    final passError = AppValidators.password(state.password);
    final confirmError =
        AppValidators.confirmPassword(state.confirmPassword, state.password);
    if (emailError != null ||
        mobileError != null ||
        passError != null ||
        confirmError != null) {
      emit(
        state.copyWith(
          errorMessage:
              emailError ?? mobileError ?? passError ?? confirmError,
          status: AuthStatus.failure,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AuthStatus.submitting, errorMessage: null));
    final result = await _resetPassword(
      email: state.email.trim(),
      mobileNumber: state.mobileNumber.trim(),
      newPassword: state.password,
    );
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: f.message),
      ),
      onSuccess: (_) => emit(state.copyWith(status: AuthStatus.resetSuccess)),
    );
  }
}
