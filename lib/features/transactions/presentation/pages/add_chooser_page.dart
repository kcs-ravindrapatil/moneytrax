import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';

@RoutePage()
class AddChooserPage extends StatelessWidget {
  const AddChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'What would you like to add?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 28),
            _ChoiceCard(
              title: 'Expense',
              subtitle: 'Track spending by category',
              icon: Icons.arrow_upward_rounded,
              color: colors.error,
              onTap: () => context.router.push(const AddExpenseRoute()),
            ),
            const SizedBox(height: 16),
            _ChoiceCard(
              title: 'Income',
              subtitle: 'Record salary or other income',
              icon: Icons.arrow_downward_rounded,
              color: colors.tertiary,
              onTap: () => context.router.push(const AddIncomeRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
