import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../transactions/domain/entities/transaction_item.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

enum ReportPeriod { daily, weekly, monthly, custom }

class CategorySpend extends Equatable {
  const CategorySpend({
    required this.categoryId,
    required this.name,
    required this.amount,
    this.icon,
  });

  final String categoryId;
  final String name;
  final double amount;
  final String? icon;

  @override
  List<Object?> get props => [categoryId, name, amount, icon];
}

class DailySpend extends Equatable {
  const DailySpend({required this.date, required this.amount});

  final DateTime date;
  final double amount;

  @override
  List<Object?> get props => [date, amount];
}

class ReportSummary extends Equatable {
  const ReportSummary({
    required this.period,
    required this.from,
    required this.to,
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
    required this.dailySpending,
    required this.transactions,
  });

  final ReportPeriod period;
  final DateTime from;
  final DateTime to;
  final double totalIncome;
  final double totalExpense;
  final List<CategorySpend> categoryBreakdown;
  final List<DailySpend> dailySpending;
  final List<TransactionItem> transactions;

  double get savings => totalIncome - totalExpense;

  @override
  List<Object?> get props => [
        period,
        from,
        to,
        totalIncome,
        totalExpense,
        categoryBreakdown,
        dailySpending,
        transactions,
      ];
}

class GetReportSummaryUseCase {
  GetReportSummaryUseCase({
    required ExpenseRepository expenseRepository,
    required IncomeRepository incomeRepository,
    required TransactionRepository transactionRepository,
  })  : _expenses = expenseRepository,
        _incomes = incomeRepository,
        _transactions = transactionRepository;

  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final TransactionRepository _transactions;

  Future<Result<ReportSummary>> call({
    required ReportPeriod period,
    DateTime? anchor,
    DateTime? fromOverride,
    DateTime? toOverride,
  }) async {
    final now = anchor ?? DateTime.now();
    late DateTime from;
    late DateTime to;

    switch (period) {
      case ReportPeriod.daily:
        from = DateTime(now.year, now.month, now.day);
        to = from;
      case ReportPeriod.weekly:
        final weekday = now.weekday;
        from = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        to = from.add(const Duration(days: 6));
      case ReportPeriod.monthly:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0);
      case ReportPeriod.custom:
        final start = fromOverride ?? DateTime(now.year, now.month, 1);
        final end = toOverride ?? DateTime(now.year, now.month, now.day);
        from = DateTime(start.year, start.month, start.day);
        to = DateTime(end.year, end.month, end.day);
        if (to.isBefore(from)) {
          final tmp = from;
          from = to;
          to = tmp;
        }
    }

    final incomeResult = await _incomes.getTotalForPeriod(from: from, to: to);
    if (incomeResult.isFailure) {
      return Error(incomeResult.failureOrNull!);
    }

    final expenseResult = await _expenses.getTotalForPeriod(from: from, to: to);
    if (expenseResult.isFailure) {
      return Error(expenseResult.failureOrNull!);
    }

    final expenseList = await _expenses.getExpenses(from: from, to: to);
    if (expenseList.isFailure) {
      return Error(expenseList.failureOrNull!);
    }

    final categoryMap = <String, CategorySpend>{};
    final dailyMap = <String, double>{};

    for (final e in expenseList.dataOrNull!) {
      final key = e.categoryId;
      final existing = categoryMap[key];
      categoryMap[key] = CategorySpend(
        categoryId: key,
        name: e.categoryName ?? 'Other',
        amount: (existing?.amount ?? 0) + e.amount,
        icon: e.categoryIcon,
      );
      final dayKey = e.date.toIso8601String().split('T').first;
      dailyMap[dayKey] = (dailyMap[dayKey] ?? 0) + e.amount;
    }

    final categories = categoryMap.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final daily = dailyMap.entries
        .map(
          (e) => DailySpend(
            date: DateTime.parse('${e.key}T00:00:00'),
            amount: e.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final txResult = await _transactions.getTransactions(from: from, to: to);
    if (txResult.isFailure) {
      return Error(txResult.failureOrNull!);
    }

    return Success(
      ReportSummary(
        period: period,
        from: from,
        to: to,
        totalIncome: incomeResult.dataOrNull!,
        totalExpense: expenseResult.dataOrNull!,
        categoryBreakdown: categories,
        dailySpending: daily,
        transactions: txResult.dataOrNull!,
      ),
    );
  }
}
