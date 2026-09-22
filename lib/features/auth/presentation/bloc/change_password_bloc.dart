import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/validators/app_validators.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc(this._updatePassword) : super(const ChangePasswordState()) {
    on<ChangePasswordCurrentChanged>((e, emit) {
      emit(state.copyWith(currentPassword: e.value, errorMessage: null));
    });
    on<ChangePasswordNewChanged>((e, emit) {
      emit(state.copyWith(newPassword: e.value, errorMessage: null));
    });
    on<ChangePasswordConfirmChanged>((e, emit) {
      emit(state.copyWith(confirmPassword: e.value, errorMessage: null));
    });
    on<ChangePasswordSubmitted>(_onSubmit);
  }

  final UpdatePasswordUseCase _updatePassword;

  Future<void> _onSubmit(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    final currentError = AppValidators.password(state.currentPassword);
    final newError = AppValidators.password(state.newPassword);
    final confirmError = AppValidators.confirmPassword(
      state.confirmPassword,
      state.newPassword,
    );
    if (currentError != null || newError != null || confirmError != null) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: currentError ?? newError ?? confirmError,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ChangePasswordStatus.submitting,
        errorMessage: null,
      ),
    );
    final result = await _updatePassword(
      currentPassword: state.currentPassword,
      newPassword: state.newPassword,
    );
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (_) =>
          emit(state.copyWith(status: ChangePasswordStatus.success)),
    );
  }
}
