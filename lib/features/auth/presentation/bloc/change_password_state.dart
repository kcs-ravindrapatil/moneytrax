part of 'change_password_bloc.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.errorMessage,
  });

  final ChangePasswordStatus status;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final String? errorMessage;

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentPassword,
        newPassword,
        confirmPassword,
        errorMessage,
      ];
}
