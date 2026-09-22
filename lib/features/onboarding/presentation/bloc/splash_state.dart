part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashNavigateToIntro extends SplashState {
  const SplashNavigateToIntro();
}

class SplashNavigateToWelcome extends SplashState {
  const SplashNavigateToWelcome();
}

class SplashNavigateToHome extends SplashState {
  const SplashNavigateToHome();
}

class SplashFailure extends SplashState {
  const SplashFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
