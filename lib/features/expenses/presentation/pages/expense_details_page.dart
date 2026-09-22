import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../bloc/expense_details_bloc.dart';

@RoutePage()
class ExpenseDetailsPage extends StatelessWidget {
  const ExpenseDetailsPage({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ExpenseDetailsBloc>()..add(ExpenseDetailsStarted(expenseId)),
      child: _ExpenseDetailsView(expenseId: expenseId),
    );
  }
}

class _ExpenseDetailsView extends StatelessWidget {
  const _ExpenseDetailsView({required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseDetailsBloc, ExpenseDetailsState>(
      listener: (context, state) {
        if (state.status == ExpenseDetailsStatus.deleted) {
          getIt<DataRefreshBus>().notifyChanged();
          context.router.maybePop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense Details'),
            actions: [
              if (state.expense != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await context.router.push(
                      EditExpenseRoute(expenseId: expenseId),
                    );
                    if (context.mounted) {
                      context
                          .read<ExpenseDetailsBloc>()
                          .add(ExpenseDetailsStarted(expenseId));
                    }
                  },
                ),
              if (state.expense != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete expense?'),
                        content: const Text(
                          'This removes the expense from your local MoneyTrax data.',
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
                          .read<ExpenseDetailsBloc>()
                          .add(ExpenseDetailsDeleted(expenseId));
                    }
                  },
                ),
            ],
          ),
          body: switch (state.status) {
            ExpenseDetailsStatus.loading ||
            ExpenseDetailsStatus.initial ||
            ExpenseDetailsStatus.deleting =>
              const LoadingView(),
            ExpenseDetailsStatus.failure => ErrorStateView(
                message: state.errorMessage ?? 'Failed to load',
                onRetry: () => context
                    .read<ExpenseDetailsBloc>()
                    .add(ExpenseDetailsStarted(expenseId)),
              ),
            _ => FutureBuilder<String>(
                future: getIt<PreferencesDataSource>().getCurrencyCode(),
                builder: (context, snap) {
                  final currency = snap.data ?? 'INR';
                  final e = state.expense!;
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      MoneyCard(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              child: Icon(
                                categoryIconData(e.categoryIcon),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              e.categoryName ?? 'Expense',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            AmountText(
                              amount: e.amount,
                              currencyCode: currency,
                              isExpense: true,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      MoneyCard(
                        child: Column(
                          children: [
                            _row('Date', DateFormatter.dayMonthYear(e.date)),
                            _row('Payment', e.paymentMethod),
                            if (e.note != null && e.note!.isNotEmpty)
                              _row('Note', e.note!),
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
