import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._local);

  final ExpenseLocalDataSource _local;

  @override
  Future<Result<List<Expense>>> getExpenses({
    String? search,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  }) async {
    try {
      final models = await _local.getExpenses(
        search: search,
        categoryId: categoryId,
        from: from,
        to: to,
        sortBy: sortBy,
        ascending: ascending,
      );
      return Success(models.map((m) => m.toEntity()).toList());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Expense>> getExpenseById(String id) async {
    try {
      final model = await _local.getExpenseById(id);
      if (model == null) {
        return const Error(NotFoundFailure('Expense not found.'));
      }
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Expense>> addExpense(Expense expense) async {
    try {
      final model = await _local.addExpense(ExpenseModel.fromEntity(expense));
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Expense>> updateExpense(Expense expense) async {
    try {
      final model =
          await _local.updateExpense(ExpenseModel.fromEntity(expense));
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> deleteExpense(String id) async {
    try {
      await _local.deleteExpense(id);
      return const Success(null);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<double>> getTotalForPeriod({
    required DateTime from,
    required DateTime to,
    String? categoryId,
  }) async {
    try {
      final total = await _local.getTotalForPeriod(
        from: from,
        to: to,
        categoryId: categoryId,
      );
      return Success(total);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }
}
