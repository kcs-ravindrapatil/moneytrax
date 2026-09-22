import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';

@RoutePage()
class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BudgetBloc>()..add(const BudgetStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budget'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showUpsertDialog(context),
              ),
            ),
          ],
        ),
        body: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            if (state.status == BudgetStatus.loading ||
                state.status == BudgetStatus.initial) {
              return const LoadingView();
            }
            if (state.status == BudgetStatus.failure) {
              return ErrorStateView(
                message: state.errorMessage ?? 'Failed to load budgets',
                onRetry: () =>
                    context.read<BudgetBloc>().add(const BudgetStarted()),
              );
            }
            final monthly = state.monthlyBudget;
            final categoryBudgets = state.categoryBudgets.where((b) {
              final q = _query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return (b.categoryName ?? '').toLowerCase().contains(q);
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        var m = state.month - 1;
                        var y = state.year;
                        if (m < 1) {
                          m = 12;
                          y -= 1;
                        }
                        context.read<BudgetBloc>().add(
                              BudgetPeriodChanged(month: m, year: y),
                            );
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        DateFormatter.monthYear(
                          DateTime(state.year, state.month),
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        var m = state.month + 1;
                        var y = state.year;
                        if (m > 12) {
                          m = 1;
                          y += 1;
                        }
                        context.read<BudgetBloc>().add(
                              BudgetPeriodChanged(month: m, year: y),
                            );
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MoneyCard(
                  onTap: monthly == null
                      ? null
                      : () => _showUpsertDialog(
                            context,
                            existing: monthly,
                            monthlyOnly: true,
                          ),
                  child: monthly == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('No monthly budget set'),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => _showUpsertDialog(
                                context,
                                monthlyOnly: true,
                              ),
                              child: const Text('Set Monthly Budget'),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Monthly Budget',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showUpsertDialog(
                                    context,
                                    existing: monthly,
                                    monthlyOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(
                                monthly.amount,
                                currencyCode: state.currencyCode,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: monthly.usedRatio.clamp(0, 1),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(8),
                              color: monthly.isOverBudget
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              monthly.isOverBudget
                                  ? 'Over budget by ${CurrencyFormatter.format(monthly.spent - monthly.amount, currencyCode: state.currencyCode)}'
                                  : 'Used ${CurrencyFormatter.format(monthly.spent, currencyCode: state.currencyCode)} · Remaining ${CurrencyFormatter.format(monthly.remaining, currencyCode: state.currencyCode)}',
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Category Budgets'),
                const SizedBox(height: 8),
                AppSearchField(
                  controller: _searchController,
                  hintText: 'Search category budgets',
                  onChanged: (q) => setState(() => _query = q),
                ),
                const SizedBox(height: 12),
                if (categoryBudgets.isEmpty)
                  const EmptyStateView(
                    title: 'No category budgets',
                    message: 'Add a category budget to track limits.',
                    icon: Icons.pie_chart_outline,
                  )
                else
                  ...categoryBudgets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MoneyCard(
                        onTap: () => _showUpsertDialog(context, existing: b),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    b.categoryName ?? 'Category',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () =>
                                      _showUpsertDialog(context, existing: b),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => context
                                      .read<BudgetBloc>()
                                      .add(BudgetDeleted(b.id)),
                                ),
                              ],
                            ),
                            Text(
                              '${CurrencyFormatter.format(b.spent, currencyCode: state.currencyCode)} / ${CurrencyFormatter.format(b.amount, currencyCode: state.currencyCode)}',
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: b.usedRatio.clamp(0, 1),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(8),
                              color: b.isOverBudget
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            if (b.isOverBudget)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Over budget',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showUpsertDialog(
    BuildContext context, {
    Budget? existing,
    bool monthlyOnly = false,
  }) async {
    final bloc = context.read<BudgetBloc>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _BudgetUpsertDialog(
          monthlyOnly: monthlyOnly || (existing?.isMonthlyTotal ?? false),
          existing: existing,
        ),
      ),
    );
  }
}

class _BudgetUpsertDialog extends StatefulWidget {
  const _BudgetUpsertDialog({
    required this.monthlyOnly,
    this.existing,
  });

  final bool monthlyOnly;
  final Budget? existing;

  @override
  State<_BudgetUpsertDialog> createState() => _BudgetUpsertDialogState();
}

class _BudgetUpsertDialogState extends State<_BudgetUpsertDialog> {
  late final TextEditingController _amountController;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amountController = TextEditingController(
      text: existing == null
          ? ''
          : (existing.amount == existing.amount.roundToDouble()
              ? existing.amount.toStringAsFixed(0)
              : existing.amount.toStringAsFixed(2)),
    );
    _categoryId = existing?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BudgetBloc>().state;
    final isEdit = widget.existing != null;
    final symbol = CurrencyFormatter.format(
      0,
      currencyCode: state.currencyCode,
    ).replaceAll(RegExp(r'[\d\s.,]'), '');

    return AlertDialog(
      title: Text(
        widget.monthlyOnly
            ? (isEdit ? 'Edit Monthly Budget' : 'Monthly Budget')
            : (isEdit ? 'Edit Budget' : 'Set Budget'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '$symbol ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          if (!widget.monthlyOnly) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Monthly total'),
                ),
                ...state.categories.map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: isEdit
                  ? null
                  : (v) => setState(() => _categoryId = v),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text.trim());
            if (amount == null || amount <= 0) return;
            final bloc = context.read<BudgetBloc>();
            final categoryId = widget.monthlyOnly ? null : _categoryId;
            Navigator.pop(context);
            bloc.add(
              BudgetUpserted(
                amount: amount,
                categoryId: categoryId,
              ),
            );
          },
          child: Text(isEdit ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}
