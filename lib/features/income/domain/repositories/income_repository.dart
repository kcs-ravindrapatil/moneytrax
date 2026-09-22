import '../../../../core/result/result.dart';
import '../entities/income.dart';

abstract class IncomeRepository {
  Future<Result<List<Income>>> getIncomes({
    String? search,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  });
  Future<Result<Income>> getIncomeById(String id);
  Future<Result<Income>> addIncome(Income income);
  Future<Result<Income>> updateIncome(Income income);
  Future<Result<void>> deleteIncome(String id);
  Future<Result<double>> getTotalForPeriod({
    required DateTime from,
    required DateTime to,
  });
}
