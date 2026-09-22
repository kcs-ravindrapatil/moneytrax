import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../bloc/income_details_bloc.dart';

@RoutePage()
class IncomeDetailsPage extends StatelessWidget {
  const IncomeDetailsPage({super.key, required this.incomeId});

  final String incomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<IncomeDetailsBloc>()..add(IncomeDetailsStarted(incomeId)),
      child: _IncomeDetailsView(incomeId: incomeId),
    );
  }
}

class _IncomeDetailsView extends StatelessWidget {
  const _IncomeDetailsView({required this.incomeId});

  final String incomeId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncomeDetailsBloc, IncomeDetailsState>(
      listener: (context, state) {
        if (state.status == IncomeDetailsStatus.deleted) {
          getIt<DataRefreshBus>().notifyChanged();
          context.router.maybePop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Income Details'),
            actions: [
              if (state.income != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await context.router
                        .push(EditIncomeRoute(incomeId: incomeId));
                    if (context.mounted) {
                      context
                          .read<IncomeDetailsBloc>()
                          .add(IncomeDetailsStarted(incomeId));
                    }
                  },
                ),
              if (state.income != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete income?'),
                        content: const Text(
                          'This removes the income from your local MoneyTrax data.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      context
                          .read<IncomeDetailsBloc>()
                          .add(IncomeDetailsDeleted(incomeId));
                    }
                  },
                ),
            ],
          ),
          body: switch (state.status) {
            IncomeDetailsStatus.loading ||
            IncomeDetailsStatus.initial ||
            IncomeDetailsStatus.deleting =>
              const LoadingView(),
            IncomeDetailsStatus.failure => ErrorStateView(
                message: state.errorMessage ?? 'Failed to load',
                onRetry: () => context
                    .read<IncomeDetailsBloc>()
                    .add(IncomeDetailsStarted(incomeId)),
              ),
            _ => FutureBuilder<String>(
                future: getIt<PreferencesDataSource>().getCurrencyCode(),
                builder: (context, snap) {
                  final currency = snap.data ?? 'INR';
                  final i = state.income!;
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      MoneyCard(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 32,
                              child: Icon(Icons.payments_rounded, size: 32),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              i.source,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            AmountText(
                              amount: i.amount,
                              currencyCode: currency,
                              isIncome: true,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      MoneyCard(
                        child: Column(
                          children: [
                            _row('Date', DateFormatter.dayMonthYear(i.date)),
                            if (i.note != null && i.note!.isNotEmpty)
                              _row('Note', i.note!),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          },
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
