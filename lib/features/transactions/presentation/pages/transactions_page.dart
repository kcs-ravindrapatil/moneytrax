import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../bloc/transaction_bloc.dart';

@RoutePage()
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionBloc>()..add(const TransactionStarted()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatefulWidget {
  const _TransactionsView();

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  late final TextEditingController _searchController;

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: SizedBox(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.router.push(const AddExpenseRoute()),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: AppSearchField(
                  controller: _searchController,
                  hintText: 'Search notes, category, source…',
                  onChanged: (v) => context
                      .read<TransactionBloc>()
                      .add(TransactionSearchChanged(v)),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final type in TransactionFilterType.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type.name[0].toUpperCase() +
                              type.name.substring(1)),
                          selected: state.filterType == type,
                          onSelected: (_) => context
                              .read<TransactionBloc>()
                              .add(TransactionTypeFilterChanged(type)),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Custom'),
                        avatar: const Icon(Icons.date_range, size: 16),
                        selected: state.from != null && state.to != null,
                        onSelected: (selected) async {
                          if (!selected) {
                            context.read<TransactionBloc>().add(
                                  const TransactionDateRangeChanged(
                                    clear: true,
                                  ),
                                );
                            return;
                          }
                          final now = DateTime.now();
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(now.year + 1, 12, 31),
                            initialDateRange: DateTimeRange(
                              start: state.from ??
                                  DateTime(now.year, now.month, 1),
                              end: state.to ??
                                  DateTime(now.year, now.month, now.day),
                            ),
                            helpText: 'Select date range',
                            saveText: 'Apply',
                          );
                          if (!context.mounted || range == null) return;
                          context.read<TransactionBloc>().add(
                                TransactionDateRangeChanged(
                                  from: DateTime(
                                    range.start.year,
                                    range.start.month,
                                    range.start.day,
                                  ),
                                  to: DateTime(
                                    range.end.year,
                                    range.end.month,
                                    range.end.day,
                                  ),
                                ),
                              );
                        },
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Sort',
                      onSelected: (value) {
                        if (value == 'date_desc') {
                          context.read<TransactionBloc>().add(
                                const TransactionSortChanged(
                                  sortBy: TransactionSortBy.date,
                                  ascending: false,
                                ),
                              );
                        } else if (value == 'date_asc') {
                          context.read<TransactionBloc>().add(
                                const TransactionSortChanged(
                                  sortBy: TransactionSortBy.date,
                                  ascending: true,
                                ),
                              );
                        } else if (value == 'amount_desc') {
                          context.read<TransactionBloc>().add(
                                const TransactionSortChanged(
                                  sortBy: TransactionSortBy.amount,
                                  ascending: false,
                                ),
                              );
                        } else {
                          context.read<TransactionBloc>().add(
                                const TransactionSortChanged(
                                  sortBy: TransactionSortBy.amount,
                                  ascending: true,
                                ),
                              );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'date_desc',
                          child: Text('Date (newest)'),
                        ),
                        PopupMenuItem(
                          value: 'date_asc',
                          child: Text('Date (oldest)'),
                        ),
                        PopupMenuItem(
                          value: 'amount_desc',
                          child: Text('Amount (high)'),
                        ),
                        PopupMenuItem(
                          value: 'amount_asc',
                          child: Text('Amount (low)'),
                        ),
                      ],
                      child: const Chip(
                        avatar: Icon(Icons.sort, size: 18),
                        label: Text('Sort'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TransactionState state) {
    if (state.status == TransactionStatus.loading ||
        state.status == TransactionStatus.initial) {
      return const LoadingView();
    }
    if (state.status == TransactionStatus.failure) {
      return ErrorStateView(
        message: state.errorMessage ?? 'Failed to load',
        onRetry: () =>
            context.read<TransactionBloc>().add(const TransactionRefreshed()),
      );
    }
    if (state.status == TransactionStatus.empty) {
      return EmptyStateView(
        title: 'No transactions',
        message: 'Add an expense or income to see it here.',
        actionLabel: 'Add Expense',
        onAction: () => context.router.push(const AddExpenseRoute()),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tx = state.items[index];
        return MoneyCard(
          onTap: () {
            if (tx.type == TransactionType.expense) {
              context.router.push(ExpenseDetailsRoute(expenseId: tx.id));
            } else {
              context.router.push(IncomeDetailsRoute(incomeId: tx.id));
            }
          },
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(categoryIconData(tx.icon)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      [
                        DateFormatter.dayMonthYear(tx.date),
                        if (tx.paymentMethod != null &&
                            tx.paymentMethod!.trim().isNotEmpty)
                          tx.paymentMethod!,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (tx.note != null && tx.note!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          tx.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
              AmountText(
                amount: tx.amount,
                currencyCode: state.currencyCode,
                isExpense: tx.isExpense,
                isIncome: !tx.isExpense,
              ),
            ],
          ),
        );
      },
    );
  }
}
