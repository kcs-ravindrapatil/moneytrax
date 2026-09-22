part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;

  String get label {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  List<Object?> get props => [themeMode];
}
