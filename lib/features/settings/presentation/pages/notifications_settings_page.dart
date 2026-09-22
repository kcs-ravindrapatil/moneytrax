import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection/injection.dart';
import '../bloc/settings_bloc.dart';

@RoutePage()
class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(const SettingsStarted()),
      child: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (p, c) =>
            p.showNotificationExplanation != c.showNotificationExplanation ||
            p.errorMessage != c.errorMessage,
        listener: (context, state) async {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (!state.showNotificationExplanation) return;
          final confirm = await showModalBottomSheet<bool>(
            context: context,
            showDragHandle: true,
            builder: (ctx) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable reminders?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MoneyTrax will send local alerts at 6:00 AM and 6:00 PM '
                    'to remind you to log today’s expenses. Nothing leaves your device.',
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Allow notifications'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Not now'),
                  ),
                ],
              ),
            ),
          );
          if (!context.mounted) return;
          if (confirm == true) {
            context
                .read<SettingsBloc>()
                .add(const SettingsNotificationsConfirmed());
          } else {
            context
                .read<SettingsBloc>()
                .add(const SettingsNotificationsExplanationDismissed());
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Notifications')),
          body: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return ListView(
                children: [
                  SwitchListTile(
                    title: const Text('Daily expense reminders'),
                    subtitle: const Text(
                      'Local alerts at 6:00 AM and 6:00 PM. '
                      'You’ll also get a confirmation when you add an expense.',
                    ),
                    value: state.notificationsEnabled,
                    onChanged: (v) => context
                        .read<SettingsBloc>()
                        .add(SettingsNotificationsToggled(v)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
