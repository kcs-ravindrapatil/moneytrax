import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../transactions/domain/entities/transaction_item.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class DashboardData extends Equatable {
  const DashboardData({
    required this.userName,
    required this.monthLabel,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
    required this.currencyCode,
  });

  final String userName;
  final String monthLabel;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionItem> recentTransactions;
  final String currencyCode;

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [
        userName,
        monthLabel,
        totalIncome,
        totalExpense,
        recentTransactions,
        currencyCode,
      ];
}

class GetDashboardDataUseCase {
  GetDashboardDataUseCase({
    required ProfileRepository profileRepository,
    required ExpenseRepository expenseRepository,
    required IncomeRepository incomeRepository,
    required TransactionRepository transactionRepository,
    required Future<String> Function() getCurrencyCode,
  })  : _profile = profileRepository,
        _expenses = expenseRepository,
        _incomes = incomeRepository,
        _transactions = transactionRepository,
        _getCurrencyCode = getCurrencyCode;

  final ProfileRepository _profile;
  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final TransactionRepository _transactions;
  final Future<String> Function() _getCurrencyCode;

  Future<Result<DashboardData>> call() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);

    final profileResult = await _profile.getProfile();
    if (profileResult.isFailure) {
      return Error(profileResult.failureOrNull!);
    }

    final incomeResult = await _incomes.getTotalForPeriod(from: from, to: to);
    if (incomeResult.isFailure) {
      return Error(incomeResult.failureOrNull!);
    }

    final expenseResult = await _expenses.getTotalForPeriod(from: from, to: to);
    if (expenseResult.isFailure) {
      return Error(expenseResult.failureOrNull!);
    }

    final txResult = await _transactions.getTransactions();
    if (txResult.isFailure) {
      return Error(txResult.failureOrNull!);
    }

    final currency = await _getCurrencyCode();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Success(
      DashboardData(
        userName: profileResult.dataOrNull?.fullName ?? 'there',
        monthLabel: '${months[now.month - 1]} ${now.year}',
        totalIncome: incomeResult.dataOrNull!,
        totalExpense: expenseResult.dataOrNull!,
        recentTransactions: txResult.dataOrNull!.take(5).toList(),
        currencyCode: currency,
      ),
    );
  }
}
