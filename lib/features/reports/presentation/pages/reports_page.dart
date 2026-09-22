import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../data/services/invoice_pdf_service.dart';
import '../../domain/usecases/get_report_summary_usecase.dart';
import '../bloc/report_bloc.dart';

@RoutePage()
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportBloc>()..add(const ReportStarted()),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Reports',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: SizedBox(),
        actions: [
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              return PopupMenuButton<StatementExportType>(
                tooltip: 'Export statement PDF',
                enabled: state.summary != null && !state.isExporting,
                onSelected: (type) => context
                    .read<ReportBloc>()
                    .add(ReportInvoiceRequested(type: type)),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: StatementExportType.all,
                    child: Text('All transactions'),
                  ),
                  PopupMenuItem(
                    value: StatementExportType.expense,
                    child: Text('Expenses only'),
                  ),
                  PopupMenuItem(
                    value: StatementExportType.income,
                    child: Text('Income only'),
                  ),
                ],
                icon: state.isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state.status == ReportStatus.loading ||
              state.status == ReportStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ReportStatus.failure) {
            return ErrorStateView(
              message: state.errorMessage ?? 'Failed to load reports',
              onRetry: () =>
                  context.read<ReportBloc>().add(const ReportStarted()),
            );
          }
          final summary = state.summary!;
          final colors = Theme.of(context).colorScheme;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              SegmentedButton<ReportPeriod>(
                segments: const [
                  ButtonSegment(
                    value: ReportPeriod.daily,
                    label: Text('Daily'),
                  ),
                  ButtonSegment(
                    value: ReportPeriod.weekly,
                    label: Text('Weekly'),
                  ),
                  ButtonSegment(
                    value: ReportPeriod.monthly,
                    label: Text('Monthly'),
                  ),
                  ButtonSegment(
                    value: ReportPeriod.custom,
                    label: Text('Custom'),
                  ),
                ],
                selected: {state.period},
                onSelectionChanged: (s) async {
                  final period = s.first;
                  if (period == ReportPeriod.custom) {
                    final now = DateTime.now();
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(now.year + 1, 12, 31),
                      initialDateRange: DateTimeRange(
                        start: state.customFrom ??
                            DateTime(now.year, now.month, 1),
                        end: state.customTo ??
                            DateTime(now.year, now.month, now.day),
                      ),
                      helpText: 'Select report date range',
                      saveText: 'Apply',
                    );
                    if (!context.mounted) return;
                    if (range == null) return;
                    context.read<ReportBloc>().add(
                          ReportDateRangeChanged(
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
                    return;
                  }
                  context.read<ReportBloc>().add(ReportPeriodChanged(period));
                },
              ),
              if (state.period == ReportPeriod.custom) ...[
                const SizedBox(height: 12),
                DateRangeFilterBar(
                  from: state.customFrom ?? summary.from,
                  to: state.customTo ?? summary.to,
                  allowClear: false,
                  onChanged: (from, to) => context.read<ReportBloc>().add(
                        ReportDateRangeChanged(from: from, to: to),
                      ),
                ),
              ],
              const SizedBox(height: 16),
              MoneyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormatter.dayMonthYear(summary.from)} – ${DateFormatter.dayMonthYear(summary.to)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _metric(
                            context,
                            'Income',
                            CurrencyFormatter.format(
                              summary.totalIncome,
                              currencyCode: state.currencyCode,
                            ),
                            colors.tertiary,
                          ),
                        ),
                        Expanded(
                          child: _metric(
                            context,
                            'Expense',
                            CurrencyFormatter.format(
                              summary.totalExpense,
                              currencyCode: state.currencyCode,
                            ),
                            colors.error,
                          ),
                        ),
                        Expanded(
                          child: _metric(
                            context,
                            'Savings',
                            CurrencyFormatter.format(
                              summary.savings,
                              currencyCode: state.currencyCode,
                            ),
                            colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              MoneyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income vs Expense',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles(),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final labels = ['Income', 'Expense'];
                                  final i = v.toInt();
                                  if (i < 0 || i > 1) return const SizedBox();
                                  return Text(labels[i]);
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: summary.totalIncome,
                                  color: colors.tertiary,
                                  width: 28,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: summary.totalExpense,
                                  color: colors.error,
                                  width: 28,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              MoneyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending over time',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: summary.dailySpending.isEmpty
                          ? const Center(child: Text('No spending data'))
                          : LineChart(
                              LineChartData(
                                titlesData: const FlTitlesData(
                                  topTitles: AxisTitles(),
                                  rightTitles: AxisTitles(),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    isCurved: true,
                                    color: colors.primary,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    spots: [
                                      for (var i = 0;
                                          i < summary.dailySpending.length;
                                          i++)
                                        FlSpot(
                                          i.toDouble(),
                                          summary.dailySpending[i].amount,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              MoneyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category spending',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    if (summary.categoryBreakdown.isEmpty)
                      const Text('No category data for this period.')
                    else ...[
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: [
                              for (var i = 0;
                                  i < summary.categoryBreakdown.length && i < 6;
                                  i++)
                                PieChartSectionData(
                                  value: summary.categoryBreakdown[i].amount,
                                  title: '',
                                  color: colors.primary
                                      .withValues(alpha: 1 - (i * 0.12)),
                                  radius: 48,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...summary.categoryBreakdown.take(8).map(
                            (c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(categoryIconData(c.icon), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(c.name)),
                                  Text(
                                    CurrencyFormatter.format(
                                      c.amount,
                                      currencyCode: state.currencyCode,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
