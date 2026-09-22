import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/income_local_data_source.dart';
import '../models/income_model.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  IncomeRepositoryImpl(this._local);

  final IncomeLocalDataSource _local;

  @override
  Future<Result<List<Income>>> getIncomes({
    String? search,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  }) async {
    try {
      final models = await _local.getIncomes(
        search: search,
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
  Future<Result<Income>> getIncomeById(String id) async {
    try {
      final model = await _local.getIncomeById(id);
      if (model == null) {
        return const Error(NotFoundFailure('Income not found.'));
      }
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Income>> addIncome(Income income) async {
    try {
      final model = await _local.addIncome(IncomeModel.fromEntity(income));
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Income>> updateIncome(Income income) async {
    try {
      final model = await _local.updateIncome(IncomeModel.fromEntity(income));
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> deleteIncome(String id) async {
    try {
      await _local.deleteIncome(id);
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
  }) async {
    try {
      final total = await _local.getTotalForPeriod(from: from, to: to);
      return Success(total);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }
}
