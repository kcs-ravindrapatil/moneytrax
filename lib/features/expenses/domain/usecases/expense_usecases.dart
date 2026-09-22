import '../../../../core/result/result.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  GetExpensesUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<List<Expense>>> call({
    String? search,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  }) {
    return _repository.getExpenses(
      search: search,
      categoryId: categoryId,
      from: from,
      to: to,
      sortBy: sortBy,
      ascending: ascending,
    );
  }
}

class GetExpenseByIdUseCase {
  GetExpenseByIdUseCase(this._repository);
  final ExpenseRepository _repository;
  Future<Result<Expense>> call(String id) => _repository.getExpenseById(id);
}

class AddExpenseUseCase {
  AddExpenseUseCase(this._repository);
  final ExpenseRepository _repository;
  Future<Result<Expense>> call(Expense expense) =>
      _repository.addExpense(expense);
}

class UpdateExpenseUseCase {
  UpdateExpenseUseCase(this._repository);
  final ExpenseRepository _repository;
  Future<Result<Expense>> call(Expense expense) =>
      _repository.updateExpense(expense);
}

class DeleteExpenseUseCase {
  DeleteExpenseUseCase(this._repository);
  final ExpenseRepository _repository;
  Future<Result<void>> call(String id) => _repository.deleteExpense(id);
}
