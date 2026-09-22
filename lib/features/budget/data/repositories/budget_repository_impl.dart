import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._local);

  final BudgetLocalDataSource _local;

  @override
  Future<Result<List<Budget>>> getBudgets({
    required int month,
    required int year,
  }) async {
    try {
      final models = await _local.getBudgets(month: month, year: year);
      return Success(models.map((m) => m.toEntity()).toList());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Budget>> upsertBudget(Budget budget) async {
    try {
      final model = await _local.upsertBudget(BudgetModel.fromEntity(budget));
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> deleteBudget(String id) async {
    try {
      await _local.deleteBudget(id);
      return const Success(null);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }
}
