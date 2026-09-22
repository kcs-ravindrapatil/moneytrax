import '../../../../core/result/result.dart';
import '../entities/transaction_item.dart';

enum TransactionFilterType { all, expense, income }

enum TransactionSortBy { date, amount }

abstract class TransactionRepository {
  Future<Result<List<TransactionItem>>> getTransactions({
    String? search,
    TransactionFilterType type = TransactionFilterType.all,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    TransactionSortBy sortBy = TransactionSortBy.date,
    bool ascending = false,
  });
}
