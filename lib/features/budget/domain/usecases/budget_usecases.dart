import '../../../../core/result/result.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgetsUseCase {
  GetBudgetsUseCase(this._repository);
  final BudgetRepository _repository;
  Future<Result<List<Budget>>> call({required int month, required int year}) =>
      _repository.getBudgets(month: month, year: year);
}

class UpsertBudgetUseCase {
  UpsertBudgetUseCase(this._repository);
  final BudgetRepository _repository;
  Future<Result<Budget>> call(Budget budget) =>
      _repository.upsertBudget(budget);
}

class DeleteBudgetUseCase {
  DeleteBudgetUseCase(this._repository);
  final BudgetRepository _repository;
  Future<Result<void>> call(String id) => _repository.deleteBudget(id);
}
