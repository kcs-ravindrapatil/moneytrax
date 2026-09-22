import '../../../../core/result/result.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Result<List<Budget>>> getBudgets({
    required int month,
    required int year,
  });
  Future<Result<Budget>> upsertBudget(Budget budget);
  Future<Result<void>> deleteBudget(String id);
}
