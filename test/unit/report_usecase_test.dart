import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:conveygrid_moneytracker/core/result/result.dart';
import 'package:conveygrid_moneytracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:conveygrid_moneytracker/features/income/domain/repositories/income_repository.dart';
import 'package:conveygrid_moneytracker/features/reports/domain/usecases/get_report_summary_usecase.dart';
import 'package:conveygrid_moneytracker/features/transactions/domain/repositories/transaction_repository.dart';

class _MockExpenses extends Mock implements ExpenseRepository {}

class _MockIncomes extends Mock implements IncomeRepository {}

class _MockTx extends Mock implements TransactionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(TransactionFilterType.all);
    registerFallbackValue(TransactionSortBy.date);
  });

  test('GetReportSummaryUseCase aggregates local totals', () async {
    final expenses = _MockExpenses();
    final incomes = _MockIncomes();
    final tx = _MockTx();

    when(
      () => incomes.getTotalForPeriod(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => const Success(60000));
    when(
      () => expenses.getTotalForPeriod(
        from: any(named: 'from'),
        to: any(named: 'to'),
        categoryId: any(named: 'categoryId'),
      ),
    ).thenAnswer((_) async => const Success(17500));
    when(
      () => expenses.getExpenses(
        search: any(named: 'search'),
        categoryId: any(named: 'categoryId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        sortBy: any(named: 'sortBy'),
        ascending: any(named: 'ascending'),
      ),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => tx.getTransactions(
        search: any(named: 'search'),
        type: any(named: 'type'),
        categoryId: any(named: 'categoryId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        sortBy: any(named: 'sortBy'),
        ascending: any(named: 'ascending'),
      ),
    ).thenAnswer((_) async => const Success([]));

    final useCase = GetReportSummaryUseCase(
      expenseRepository: expenses,
      incomeRepository: incomes,
      transactionRepository: tx,
    );

    final result = await useCase(
      period: ReportPeriod.monthly,
      anchor: DateTime(2026, 9, 15),
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.totalIncome, 60000);
    expect(result.dataOrNull!.totalExpense, 17500);
    expect(result.dataOrNull!.savings, 42500);
  });
}
