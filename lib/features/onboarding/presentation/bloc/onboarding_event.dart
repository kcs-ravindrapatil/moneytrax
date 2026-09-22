part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  const OnboardingPageChanged(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

class OnboardingSkipPressed extends OnboardingEvent {
  const OnboardingSkipPressed();
}

class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
