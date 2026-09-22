import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../injection/injection.dart';
import '../bloc/settings_bloc.dart';

@RoutePage()
class DeleteProfilePage extends StatelessWidget {
  const DeleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>(),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.deleted) {
            context.router.replaceAll([const WelcomeRoute()]);
          } else if (state.status == SettingsStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final deleting = state.status == SettingsStatus.deleting;
          return Scaffold(
            appBar: AppBar(title: const Text('Delete Profile')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete your MoneyTrax profile?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This permanently removes from this device:\n'
                    '• Your profile\n'
                    '• Expenses and income\n'
                    '• Custom categories\n'
                    '• Budgets\n'
                    '• Local preferences\n\n'
                    'This cannot be undone.',
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: deleting
                        ? null
                        : () => context
                            .read<SettingsBloc>()
                            .add(const SettingsDeleteProfileRequested()),
                    child: deleting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Delete everything'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed:
                        deleting ? null : () => context.router.maybePop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
