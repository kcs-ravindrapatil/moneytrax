part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeStarted extends ThemeEvent {
  const ThemeStarted();
}

class ThemeModeSelected extends ThemeEvent {
  const ThemeModeSelected(this.themeMode);
  final ThemeMode themeMode;
  @override
  List<Object?> get props => [themeMode];
}
