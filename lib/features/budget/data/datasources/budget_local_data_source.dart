import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets({required int month, required int year});
  Future<BudgetModel?> getBudgetById(String id);
  Future<BudgetModel> upsertBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  BudgetLocalDataSourceImpl(this._appDatabase);

  final AppDatabase _appDatabase;
  final _uuid = const Uuid();

  @override
  Future<List<BudgetModel>> getBudgets({
    required int month,
    required int year,
  }) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.rawQuery(
        '''
        SELECT b.*, c.${DatabaseConstants.colName} AS category_name,
          CASE
            WHEN b.${DatabaseConstants.colCategoryId} IS NULL THEN (
              SELECT COALESCE(SUM(e.${DatabaseConstants.colAmount}), 0)
              FROM ${DatabaseConstants.tableExpenses} e
              WHERE strftime('%m', e.${DatabaseConstants.colDate}) = printf('%02d', b.${DatabaseConstants.colMonth})
                AND strftime('%Y', e.${DatabaseConstants.colDate}) = CAST(b.${DatabaseConstants.colYear} AS TEXT)
            )
            ELSE (
              SELECT COALESCE(SUM(e.${DatabaseConstants.colAmount}), 0)
              FROM ${DatabaseConstants.tableExpenses} e
              WHERE e.${DatabaseConstants.colCategoryId} = b.${DatabaseConstants.colCategoryId}
                AND strftime('%m', e.${DatabaseConstants.colDate}) = printf('%02d', b.${DatabaseConstants.colMonth})
                AND strftime('%Y', e.${DatabaseConstants.colDate}) = CAST(b.${DatabaseConstants.colYear} AS TEXT)
            )
          END AS spent
        FROM ${DatabaseConstants.tableBudgets} b
        LEFT JOIN ${DatabaseConstants.tableCategories} c
          ON b.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colId}
        WHERE b.${DatabaseConstants.colMonth} = ? AND b.${DatabaseConstants.colYear} = ?
        ORDER BY b.${DatabaseConstants.colCategoryId} IS NOT NULL, c.${DatabaseConstants.colName}
        ''',
        [month, year],
      );
      return rows.map(BudgetModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<BudgetModel?> getBudgetById(String id) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        DatabaseConstants.tableBudgets,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return BudgetModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<BudgetModel> upsertBudget(BudgetModel budget) async {
    try {
      final db = await _appDatabase.database;
      final now = DateTime.now().toIso8601String();

      // Find existing matching monthly/category budget
      final existing = await db.query(
        DatabaseConstants.tableBudgets,
        where: budget.categoryId == null
            ? '${DatabaseConstants.colMonth} = ? AND ${DatabaseConstants.colYear} = ? AND ${DatabaseConstants.colCategoryId} IS NULL'
            : '${DatabaseConstants.colMonth} = ? AND ${DatabaseConstants.colYear} = ? AND ${DatabaseConstants.colCategoryId} = ?',
        whereArgs: budget.categoryId == null
            ? [budget.month, budget.year]
            : [budget.month, budget.year, budget.categoryId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final id = existing.first[DatabaseConstants.colId] as String;
        final model = BudgetModel(
          id: id,
          month: budget.month,
          year: budget.year,
          amount: budget.amount,
          categoryId: budget.categoryId,
          createdAt: existing.first[DatabaseConstants.colCreatedAt] as String,
          updatedAt: now,
        );
        await db.update(
          DatabaseConstants.tableBudgets,
          model.toMap(),
          where: '${DatabaseConstants.colId} = ?',
          whereArgs: [id],
        );
        return model;
      }

      final model = BudgetModel(
        id: budget.id.isEmpty ? _uuid.v4() : budget.id,
        month: budget.month,
        year: budget.year,
        amount: budget.amount,
        categoryId: budget.categoryId,
        createdAt: now,
        updatedAt: now,
      );
      await db.insert(
        DatabaseConstants.tableBudgets,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      final db = await _appDatabase.database;
      await db.delete(
        DatabaseConstants.tableBudgets,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}
