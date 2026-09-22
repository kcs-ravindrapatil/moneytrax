import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'How MoneyTrax handles your data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Local expense storage\n'
            'Expenses, income, categories, budgets, and related money-tracking data '
            'are stored locally on your device using SQLite. MoneyTrax does not use '
            'a remote expense backend, Firebase, or cloud database for this data.',
            style: style,
          ),
          const SizedBox(height: 16),
          Text(
            'Profile information\n'
            'MoneyTrax collects your full name, email, and mobile number when you '
            'create a profile. This information is stored locally so the app can '
            'personalize your experience.',
            style: style,
          ),
          const SizedBox(height: 16),
          Text(
            'Consent processing (ConveyGrid)\n'
            'When you create a profile, MoneyTrax may send your full name, email, '
            'and mobile number to ConveyGrid to create or verify consent. If you '
            'already granted the required consents, MoneyTrax skips the consent popup. '
            'Otherwise the ConveyGrid consent UI may appear. Consent processing uses '
            'ConveyGrid’s servers and is separate from your local expense data.',
            style: style,
          ),
          const SizedBox(height: 16),
          Text(
            'Notifications\n'
            'Optional local reminders use on-device notifications only. There is no '
            'push notification backend.',
            style: style,
          ),
          const SizedBox(height: 16),
          Text(
            'Deletion\n'
            'Delete Profile removes your locally stored MoneyTrax profile, expenses, '
            'income, custom categories, budgets, and preferences from this device. '
            'Remote consent revocation depends on ConveyGrid capabilities; this app '
            'version clears local data and does not claim remote deletion.',
            style: style,
          ),
          const SizedBox(height: 16),
          Text(
            'MoneyTrax is an expense tracking utility. It is not a bank, payment '
            'service, investment advisor, or financial institution.',
            style: style,
          ),
        ],
      ),
    );
  }
}
