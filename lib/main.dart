import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'core/utils/notification_service.dart';
import 'features/settings/data/datasources/preferences_data_source.dart';
import 'injection/injection.dart';
import 'integrations/consent/conveygrid_env.dart';
import 'integrations/consent/env_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  ConveyGridEnv.loadFrom(await EnvLoader.load());
  await configureDependencies();
  final notifications = getIt<NotificationService>();
  await notifications.initialize();
  if (await getIt<PreferencesDataSource>().areNotificationsEnabled()) {
    await notifications.scheduleDailyReminders();
  }
  runApp(MoneyTraxApp());
}
