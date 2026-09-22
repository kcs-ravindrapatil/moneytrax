import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../injection/injection.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'theme/theme_bloc.dart';

class MoneyTraxApp extends StatelessWidget {
  MoneyTraxApp({super.key, AppRouter? appRouter})
      : _appRouter = appRouter ?? AppRouter();

  final AppRouter _appRouter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ThemeBloc>()..add(const ThemeStarted()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,
            routerConfig: _appRouter.config(),
          );
        },
      ),
    );
  }
}
