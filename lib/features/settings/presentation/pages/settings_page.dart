import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../app/theme/theme_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection/injection.dart';
import '../../data/datasources/preferences_data_source.dart';
import '../bloc/settings_bloc.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(const SettingsStarted()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (p, c) =>
          p.showNotificationExplanation != c.showNotificationExplanation ||
          p.status != c.status,
      listener: (context, state) async {
        if (state.showNotificationExplanation) {
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
                    'to remind you to log today’s expenses. '
                    'Notifications stay on your device — there is no push server.',
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
        }
        if (state.status == SettingsStatus.deleted) {
          context.router.replaceAll([const WelcomeRoute()]);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: SizedBox(),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListView(
              children: [
                _tile(
                  context,
                  Icons.person_outline,
                  'Profile',
                  onTap: () => context.router.push(const EditProfileRoute()),
                ),
                _tile(
                  context,
                  Icons.category_outlined,
                  'Categories',
                  onTap: () => context.router.push(const CategoriesRoute()),
                ),
                _tile(
                  context,
                  Icons.account_balance_wallet_outlined,
                  'Budget',
                  onTap: () => context.router.push(const BudgetRoute()),
                ),
                _tile(
                  context,
                  Icons.currency_rupee,
                  'Currency',
                  subtitle: state.currencyCode,
                  onTap: () => context.router.push(const CurrencyRoute()),
                ),
                _tile(
                  context,
                  Icons.payment_outlined,
                  'Payment Methods',
                  onTap: () => context.router.push(const PaymentMethodsRoute()),
                ),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    return _tile(
                      context,
                      Icons.brightness_6_outlined,
                      'Appearance',
                      subtitle: themeState.label,
                      onTap: () => _showAppearanceSheet(context),
                    );
                  },
                ),
                _tile(
                  context,
                  Icons.lock_outline,
                  'Update Password',
                  onTap: () =>
                      context.router.push(const ChangePasswordRoute()),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Optional local daily reminder'),
                  value: state.notificationsEnabled,
                  onChanged: (v) => context
                      .read<SettingsBloc>()
                      .add(SettingsNotificationsToggled(v)),
                ),
                _tile(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy',
                  onTap: () => context.router.push(const PrivacyRoute()),
                ),
                _tile(
                  context,
                  Icons.info_outline,
                  'About ${AppConstants.appName}',
                  onTap: () => context.router.push(const AboutRoute()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Lock the app. Your data stays on device.'),
                  onTap: () => _confirmLogout(context),
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Delete Profile',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () => context.router.push(const DeleteProfileRoute()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text(
          'You’ll return to the welcome screen. '
          'Your expenses and profile stay on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await getIt<PreferencesDataSource>().setSessionActive(false);
    if (!context.mounted) return;
    context.router.replaceAll([const WelcomeRoute()]);
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _showAppearanceSheet(BuildContext context) async {
    final themeBloc = context.read<ThemeBloc>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: themeBloc,
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Default follows your device setting.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ...[
                      (ThemeMode.system, Icons.brightness_auto, 'System'),
                      (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
                      (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
                    ].map(
                      (option) {
                        final mode = option.$1;
                        final icon = option.$2;
                        final label = option.$3;
                        final selected = state.themeMode == mode;
                        return ListTile(
                          leading: Icon(icon),
                          title: Text(label),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          selected: selected,
                          onTap: () {
                            context
                                .read<ThemeBloc>()
                                .add(ThemeModeSelected(mode));
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
