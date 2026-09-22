import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses({
    String? search,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  });
  Future<ExpenseModel?> getExpenseById(String id);
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<double> getTotalForPeriod({
    required DateTime from,
    required DateTime to,
    String? categoryId,
  });
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  ExpenseLocalDataSourceImpl(this._appDatabase);

  final AppDatabase _appDatabase;
  final _uuid = const Uuid();

  @override
  Future<List<ExpenseModel>> getExpenses({
    String? search,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  }) async {
    try {
      final db = await _appDatabase.database;
      final where = <String>[];
      final args = <Object?>[];

      if (search != null && search.trim().isNotEmpty) {
        where.add(
          '(e.${DatabaseConstants.colNote} LIKE ? OR c.${DatabaseConstants.colName} LIKE ? OR e.${DatabaseConstants.colPaymentMethod} LIKE ?)',
        );
        final q = '%${search.trim()}%';
        args.addAll([q, q, q]);
      }
      if (categoryId != null) {
        where.add('e.${DatabaseConstants.colCategoryId} = ?');
        args.add(categoryId);
      }
      if (from != null) {
        where.add('e.${DatabaseConstants.colDate} >= ?');
        args.add(from.toIso8601String().split('T').first);
      }
      if (to != null) {
        where.add('e.${DatabaseConstants.colDate} <= ?');
        args.add(to.toIso8601String().split('T').first);
      }

      final orderColumn = sortBy == 'amount'
          ? 'e.${DatabaseConstants.colAmount}'
          : 'e.${DatabaseConstants.colDate}';
      final order = ascending ? 'ASC' : 'DESC';

      final sql = '''
        SELECT e.*, c.${DatabaseConstants.colName} AS category_name,
               c.${DatabaseConstants.colIcon} AS category_icon
        FROM ${DatabaseConstants.tableExpenses} e
        LEFT JOIN ${DatabaseConstants.tableCategories} c
          ON e.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colId}
        ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
        ORDER BY $orderColumn $order
      ''';

      final rows = await db.rawQuery(sql, args);
      return rows.map(ExpenseModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.rawQuery(
        '''
        SELECT e.*, c.${DatabaseConstants.colName} AS category_name,
               c.${DatabaseConstants.colIcon} AS category_icon
        FROM ${DatabaseConstants.tableExpenses} e
        LEFT JOIN ${DatabaseConstants.tableCategories} c
          ON e.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colId}
        WHERE e.${DatabaseConstants.colId} = ?
        LIMIT 1
        ''',
        [id],
      );
      if (rows.isEmpty) return null;
      return ExpenseModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final db = await _appDatabase.database;
      final now = DateTime.now().toIso8601String();
      final model = ExpenseModel(
        id: expense.id.isEmpty ? _uuid.v4() : expense.id,
        amount: expense.amount,
        categoryId: expense.categoryId,
        date: expense.date,
        paymentMethod: expense.paymentMethod,
        note: expense.note,
        createdAt: now,
        updatedAt: now,
      );
      await db.insert(
        DatabaseConstants.tableExpenses,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return (await getExpenseById(model.id))!;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final db = await _appDatabase.database;
      final model = ExpenseModel(
        id: expense.id,
        amount: expense.amount,
        categoryId: expense.categoryId,
        date: expense.date,
        paymentMethod: expense.paymentMethod,
        note: expense.note,
        createdAt: expense.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await db.update(
        DatabaseConstants.tableExpenses,
        model.toMap(),
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [expense.id],
      );
      return (await getExpenseById(model.id))!;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      final db = await _appDatabase.database;
      await db.delete(
        DatabaseConstants.tableExpenses,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<double> getTotalForPeriod({
    required DateTime from,
    required DateTime to,
    String? categoryId,
  }) async {
    try {
      final db = await _appDatabase.database;
      final where = <String>[
        '${DatabaseConstants.colDate} >= ?',
        '${DatabaseConstants.colDate} <= ?',
      ];
      final args = <Object?>[
        from.toIso8601String().split('T').first,
        to.toIso8601String().split('T').first,
      ];
      if (categoryId != null) {
        where.add('${DatabaseConstants.colCategoryId} = ?');
        args.add(categoryId);
      }
      final result = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(${DatabaseConstants.colAmount}), 0) AS total
        FROM ${DatabaseConstants.tableExpenses}
        WHERE ${where.join(' AND ')}
        ''',
        args,
      );
      return (result.first['total'] as num).toDouble();
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}
