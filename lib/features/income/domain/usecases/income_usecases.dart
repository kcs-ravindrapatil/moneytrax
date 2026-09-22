import '../../../../core/result/result.dart';
import '../entities/income.dart';
import '../repositories/income_repository.dart';

class GetIncomesUseCase {
  GetIncomesUseCase(this._repository);
  final IncomeRepository _repository;
  Future<Result<List<Income>>> call({
    String? search,
    DateTime? from,
    DateTime? to,
  }) =>
      _repository.getIncomes(search: search, from: from, to: to);
}

class GetIncomeByIdUseCase {
  GetIncomeByIdUseCase(this._repository);
  final IncomeRepository _repository;
  Future<Result<Income>> call(String id) => _repository.getIncomeById(id);
}

class AddIncomeUseCase {
  AddIncomeUseCase(this._repository);
  final IncomeRepository _repository;
  Future<Result<Income>> call(Income income) => _repository.addIncome(income);
}

class UpdateIncomeUseCase {
  UpdateIncomeUseCase(this._repository);
  final IncomeRepository _repository;
  Future<Result<Income>> call(Income income) =>
      _repository.updateIncome(income);
}

class DeleteIncomeUseCase {
  DeleteIncomeUseCase(this._repository);
  final IncomeRepository _repository;
  Future<Result<void>> call(String id) => _repository.deleteIncome(id);
}
