import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';
import 'database_migrations.dart';

class AppDatabase {
  AppDatabase();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DatabaseConstants.databaseName);

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(DatabaseConstants.tableBudgets);
    await db.delete(DatabaseConstants.tableExpenses);
    await db.delete(DatabaseConstants.tableIncomes);
    await db.delete(DatabaseConstants.tableUsers);
    await db.delete(DatabaseConstants.tableCategories);
    await DatabaseMigrations.seedDefaultCategories(db);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
