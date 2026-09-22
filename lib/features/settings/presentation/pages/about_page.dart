import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About ${AppConstants.appName}')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(AppConstants.appTagline),
          const SizedBox(height: 8),
          Text(AppConstants.appSlogan),
          const SizedBox(height: 24),
          const Text(
            'MoneyTrax helps you track daily expenses and income locally on your '
            'device. It does not provide banking, payments, investment advice, or '
            'financial recommendations.',
          ),
          const SizedBox(height: 16),
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
