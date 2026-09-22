import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/income_model.dart';

abstract class IncomeLocalDataSource {
  Future<List<IncomeModel>> getIncomes({
    String? search,
    DateTime? from,
    DateTime? to,
    String sortBy = 'date',
    bool ascending = false,
  });
  Future<IncomeModel?> getIncomeById(String id);
  Future<IncomeModel> addIncome(IncomeModel income);
  Future<IncomeModel> updateIncome(IncomeModel income);
  Future<void> deleteIncome(String id);
  Future<double> getTotalForPeriod({
    required DateTime from,
    required DateTime to,
  });
}

class IncomeLocalDataSourceImpl implements IncomeLocalDataSource {
  IncomeLocalDataSourceImpl(this._appDatabase);

  final AppDatabase _appDatabase;
  final _uuid = const Uuid();

  @override
  Future<List<IncomeModel>> getIncomes({
    String? search,
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
          '(${DatabaseConstants.colSource} LIKE ? OR ${DatabaseConstants.colNote} LIKE ?)',
        );
        final q = '%${search.trim()}%';
        args.addAll([q, q]);
      }
      if (from != null) {
        where.add('${DatabaseConstants.colDate} >= ?');
        args.add(from.toIso8601String().split('T').first);
      }
      if (to != null) {
        where.add('${DatabaseConstants.colDate} <= ?');
        args.add(to.toIso8601String().split('T').first);
      }

      final orderColumn = sortBy == 'amount'
          ? DatabaseConstants.colAmount
          : DatabaseConstants.colDate;
      final order = ascending ? 'ASC' : 'DESC';

      final rows = await db.query(
        DatabaseConstants.tableIncomes,
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: '$orderColumn $order',
      );
      return rows.map(IncomeModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<IncomeModel?> getIncomeById(String id) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        DatabaseConstants.tableIncomes,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return IncomeModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<IncomeModel> addIncome(IncomeModel income) async {
    try {
      final db = await _appDatabase.database;
      final now = DateTime.now().toIso8601String();
      final model = IncomeModel(
        id: income.id.isEmpty ? _uuid.v4() : income.id,
        amount: income.amount,
        source: income.source,
        date: income.date,
        note: income.note,
        createdAt: now,
        updatedAt: now,
      );
      await db.insert(
        DatabaseConstants.tableIncomes,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<IncomeModel> updateIncome(IncomeModel income) async {
    try {
      final db = await _appDatabase.database;
      final model = IncomeModel(
        id: income.id,
        amount: income.amount,
        source: income.source,
        date: income.date,
        note: income.note,
        createdAt: income.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await db.update(
        DatabaseConstants.tableIncomes,
        model.toMap(),
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [income.id],
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    try {
      final db = await _appDatabase.database;
      await db.delete(
        DatabaseConstants.tableIncomes,
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
  }) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(${DatabaseConstants.colAmount}), 0) AS total
        FROM ${DatabaseConstants.tableIncomes}
        WHERE ${DatabaseConstants.colDate} >= ?
          AND ${DatabaseConstants.colDate} <= ?
        ''',
        [
          from.toIso8601String().split('T').first,
          to.toIso8601String().split('T').first,
        ],
      );
      return (result.first['total'] as num).toDouble();
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}
