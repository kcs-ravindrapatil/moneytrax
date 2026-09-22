part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted({this.isEditing = false});
  final bool isEditing;

  @override
  List<Object?> get props => [isEditing];
}

class ProfileFullNameChanged extends ProfileEvent {
  const ProfileFullNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class ProfileEmailChanged extends ProfileEvent {
  const ProfileEmailChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class ProfileMobileChanged extends ProfileEvent {
  const ProfileMobileChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class ProfilePasswordChanged extends ProfileEvent {
  const ProfilePasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class ProfileConfirmPasswordChanged extends ProfileEvent {
  const ProfileConfirmPasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();
}

class ProfileConsentStarted extends ProfileEvent {
  const ProfileConsentStarted();
}

class ProfileConsentSucceeded extends ProfileEvent {
  const ProfileConsentSucceeded();
}

class ProfileConsentFailed extends ProfileEvent {
  const ProfileConsentFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ProfileRetryConsent extends ProfileEvent {
  const ProfileRetryConsent();
}
