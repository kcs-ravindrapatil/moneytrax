part of 'change_password_bloc.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();
  @override
  List<Object?> get props => [];
}

class ChangePasswordCurrentChanged extends ChangePasswordEvent {
  const ChangePasswordCurrentChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ChangePasswordNewChanged extends ChangePasswordEvent {
  const ChangePasswordNewChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ChangePasswordConfirmChanged extends ChangePasswordEvent {
  const ChangePasswordConfirmChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted();
}
