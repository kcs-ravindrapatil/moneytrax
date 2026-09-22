import '../../../../core/result/result.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required ExpenseRepository expenseRepository,
    required IncomeRepository incomeRepository,
  })  : _expenses = expenseRepository,
        _incomes = incomeRepository;

  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;

  @override
  Future<Result<List<TransactionItem>>> getTransactions({
    String? search,
    TransactionFilterType type = TransactionFilterType.all,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    TransactionSortBy sortBy = TransactionSortBy.date,
    bool ascending = false,
  }) async {
    final items = <TransactionItem>[];

    if (type != TransactionFilterType.income) {
      final expenseResult = await _expenses.getExpenses(
        search: search,
        categoryId: categoryId,
        from: from,
        to: to,
        sortBy: sortBy == TransactionSortBy.amount ? 'amount' : 'date',
        ascending: ascending,
      );
      if (expenseResult.isFailure) {
        return Error(expenseResult.failureOrNull!);
      }
      for (final e in expenseResult.dataOrNull!) {
        items.add(
          TransactionItem(
            id: e.id,
            amount: e.amount,
            date: e.date,
            type: TransactionType.expense,
            title: e.categoryName ?? 'Expense',
            subtitle: e.paymentMethod,
            categoryId: e.categoryId,
            icon: e.categoryIcon,
            paymentMethod: e.paymentMethod,
            note: e.note,
          ),
        );
      }
    }

    if (type != TransactionFilterType.expense && categoryId == null) {
      final incomeResult = await _incomes.getIncomes(
        search: search,
        from: from,
        to: to,
        sortBy: sortBy == TransactionSortBy.amount ? 'amount' : 'date',
        ascending: ascending,
      );
      if (incomeResult.isFailure) {
        return Error(incomeResult.failureOrNull!);
      }
      for (final i in incomeResult.dataOrNull!) {
        items.add(
          TransactionItem(
            id: i.id,
            amount: i.amount,
            date: i.date,
            type: TransactionType.income,
            title: i.source,
            subtitle: i.note,
            icon: 'payments',
            note: i.note,
          ),
        );
      }
    }

    items.sort((a, b) {
      final cmp = sortBy == TransactionSortBy.amount
          ? a.amount.compareTo(b.amount)
          : a.date.compareTo(b.date);
      return ascending ? cmp : -cmp;
    });

    return Success(items);
  }
}
