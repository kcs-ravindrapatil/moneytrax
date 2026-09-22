import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../../transactions/domain/entities/transaction_item.dart';
import '../bloc/dashboard_bloc.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const DashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playEntrance() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status != DashboardStatus.success) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    context.router.push(const AddExpenseRoute()),
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: BlocConsumer<DashboardBloc, DashboardState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == DashboardStatus.success) {
              _playEntrance();
            }
          },
          builder: (context, state) {
            if (state.status == DashboardStatus.loading ||
                state.status == DashboardStatus.initial) {
              return const LoadingView();
            }
            if (state.status == DashboardStatus.failure) {
              return ErrorStateView(
                message: state.errorMessage ?? 'Failed to load dashboard',
                onRetry: () => context
                    .read<DashboardBloc>()
                    .add(const DashboardRefreshed()),
              );
            }
            final data = state.data!;
            final colors = Theme.of(context).colorScheme;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRefreshed());
              },
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                    children: [
                      Text(
                        '${DateFormatter.greeting(DateTime.now())} 👋',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      Text(
                        data.userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.monthLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 20),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.96, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: MoneyCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: data.balance),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) => Text(
                                  CurrencyFormatter.format(
                                    value,
                                    currencyCode: data.currencyCode,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Income',
                                      value: CurrencyFormatter.format(
                                        data.totalIncome,
                                        currencyCode: data.currencyCode,
                                      ),
                                      color: colors.tertiary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Expense',
                                      value: CurrencyFormatter.format(
                                        data.totalExpense,
                                        currencyCode: data.currencyCode,
                                      ),
                                      color: colors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SectionHeader(
                        title: 'Recent Transactions',
                        actionLabel: 'See all',
                        onAction: () =>
                            AutoTabsRouter.of(context).setActiveIndex(1),
                      ),
                      const SizedBox(height: 12),
                      if (data.recentTransactions.isEmpty)
                        MoneyCard(
                          child: Text(
                            'No transactions yet. Add your first expense!',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        )
                      else
                        ...data.recentTransactions.asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final tx = entry.value;
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 350 + (index * 80),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 16),
                                  child: child,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: MoneyCard(
                                  onTap: () {
                                    if (tx.type == TransactionType.expense) {
                                      context.router.push(
                                        ExpenseDetailsRoute(expenseId: tx.id),
                                      );
                                    } else {
                                      context.router.push(
                                        IncomeDetailsRoute(incomeId: tx.id),
                                      );
                                    }
                                  },
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: colors.primaryContainer
                                            .withValues(alpha: 0.5),
                                        child: Icon(
                                          categoryIconData(tx.icon),
                                          color: colors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              [
                                                DateFormatter.dayMonthYear(
                                                  tx.date,
                                                ),
                                                if (tx.paymentMethod != null &&
                                                    tx.paymentMethod!
                                                        .trim()
                                                        .isNotEmpty)
                                                  tx.paymentMethod!,
                                              ].join(' · '),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            if (tx.note != null &&
                                                tx.note!.trim().isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 2),
                                                child: Text(
                                                  tx.note!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: colors
                                                            .onSurfaceVariant,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      AmountText(
                                        amount: tx.amount,
                                        currencyCode: data.currencyCode,
                                        isExpense: tx.isExpense,
                                        isIncome: !tx.isExpense,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
