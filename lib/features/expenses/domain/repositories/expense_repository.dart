import '../../../../core/result/result.dart';
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Result<List<Expense>>> getExpenses({
    String? search,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  });
  Future<Result<Expense>> getExpenseById(String id);
  Future<Result<Expense>> addExpense(Expense expense);
  Future<Result<Expense>> updateExpense(Expense expense);
  Future<Result<void>> deleteExpense(String id);
  Future<Result<double>> getTotalForPeriod({
    required DateTime from,
    required DateTime to,
    String? categoryId,
  });
}
