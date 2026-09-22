import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:conveygrid_moneytracker/core/database/app_database.dart';
import 'package:conveygrid_moneytracker/core/database/database_constants.dart';
import 'package:conveygrid_moneytracker/features/categories/data/datasources/category_local_data_source.dart';
import 'package:conveygrid_moneytracker/features/expenses/data/datasources/expense_local_data_source.dart';
import 'package:conveygrid_moneytracker/features/expenses/data/models/expense_model.dart';
import 'package:conveygrid_moneytracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:conveygrid_moneytracker/features/expenses/domain/entities/expense.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('expense repository add and fetch works offline', () async {
    final db = AppDatabase();
    final categories = CategoryLocalDataSourceImpl(db);
    final expenses = ExpenseLocalDataSourceImpl(db);
    final repo = ExpenseRepositoryImpl(expenses);

    final cats = await categories.getCategories();
    expect(cats, isNotEmpty);

    final now = DateTime.now();
    final result = await repo.addExpense(
      Expense(
        id: '',
        amount: 250,
        categoryId: cats.first.id,
        date: now,
        paymentMethod: 'UPI',
        note: 'Lunch',
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(result.isSuccess, isTrue);
    final list = await repo.getExpenses();
    expect(list.isSuccess, isTrue);
    expect(list.dataOrNull, isNotEmpty);
    expect(list.dataOrNull!.first.amount, 250);

    await db.close();
  });

  test('default categories are seeded', () async {
    final db = AppDatabase();
    final database = await db.database;
    final rows = await database.query(DatabaseConstants.tableCategories);
    expect(rows.length, greaterThanOrEqualTo(13));
    await db.close();
  });

  test('expense model round trip map', () {
    final model = ExpenseModel(
      id: 'e1',
      amount: 10,
      categoryId: 'food',
      date: '2026-09-21',
      paymentMethod: 'Cash',
      note: 'Tea',
      createdAt: '2026-09-21T10:00:00.000',
      updatedAt: '2026-09-21T10:00:00.000',
    );
    final entity = model.toEntity();
    expect(entity.amount, 10);
    expect(ExpenseModel.fromEntity(entity).toMap()['amount'], 10);
  });
}
