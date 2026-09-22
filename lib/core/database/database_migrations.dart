import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> onCreate(Database db, int version) async {
    await _createV1(db);
    await seedDefaultCategories(db);
  }

  static Future<void> seedDefaultCategories(Database db) =>
      _seedDefaultCategories(db);

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
  }

  static Future<void> _migrateToV2(Database db) async {
    await db.execute(
      'ALTER TABLE ${DatabaseConstants.tableUsers} '
      'ADD COLUMN ${DatabaseConstants.colPasswordHash} TEXT',
    );
    await db.execute(
      'ALTER TABLE ${DatabaseConstants.tableUsers} '
      'ADD COLUMN ${DatabaseConstants.colPasswordSalt} TEXT',
    );
  }

  static Future<void> _createV1(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableUsers} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colFullName} TEXT NOT NULL,
        ${DatabaseConstants.colEmail} TEXT NOT NULL,
        ${DatabaseConstants.colMobileNumber} TEXT NOT NULL,
        ${DatabaseConstants.colPasswordHash} TEXT,
        ${DatabaseConstants.colPasswordSalt} TEXT,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCategories} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colName} TEXT NOT NULL,
        ${DatabaseConstants.colIcon} TEXT NOT NULL,
        ${DatabaseConstants.colIsDefault} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableExpenses} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colAmount} REAL NOT NULL,
        ${DatabaseConstants.colCategoryId} TEXT NOT NULL,
        ${DatabaseConstants.colDate} TEXT NOT NULL,
        ${DatabaseConstants.colPaymentMethod} TEXT NOT NULL,
        ${DatabaseConstants.colNote} TEXT,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colCategoryId})
          REFERENCES ${DatabaseConstants.tableCategories}(${DatabaseConstants.colId})
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableIncomes} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colAmount} REAL NOT NULL,
        ${DatabaseConstants.colSource} TEXT NOT NULL,
        ${DatabaseConstants.colDate} TEXT NOT NULL,
        ${DatabaseConstants.colNote} TEXT,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBudgets} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colMonth} INTEGER NOT NULL,
        ${DatabaseConstants.colYear} INTEGER NOT NULL,
        ${DatabaseConstants.colAmount} REAL NOT NULL,
        ${DatabaseConstants.colCategoryId} TEXT,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colCategoryId})
          REFERENCES ${DatabaseConstants.tableCategories}(${DatabaseConstants.colId})
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_expenses_date ON ${DatabaseConstants.tableExpenses}(${DatabaseConstants.colDate})',
    );
    await db.execute(
      'CREATE INDEX idx_expenses_category ON ${DatabaseConstants.tableExpenses}(${DatabaseConstants.colCategoryId})',
    );
    await db.execute(
      'CREATE INDEX idx_incomes_date ON ${DatabaseConstants.tableIncomes}(${DatabaseConstants.colDate})',
    );
    await db.execute(
      'CREATE INDEX idx_budgets_period ON ${DatabaseConstants.tableBudgets}(${DatabaseConstants.colYear}, ${DatabaseConstants.colMonth})',
    );
  }

  static Future<void> _seedDefaultCategories(Database db) async {
    const defaults = [
      ('food', 'Food', 'restaurant'),
      ('groceries', 'Groceries', 'shopping_cart'),
      ('shopping', 'Shopping', 'shopping_bag'),
      ('fuel', 'Fuel', 'local_gas_station'),
      ('travel', 'Travel', 'flight'),
      ('rent', 'Rent', 'home'),
      ('utilities', 'Utilities', 'bolt'),
      ('entertainment', 'Entertainment', 'movie'),
      ('health', 'Health', 'favorite'),
      ('education', 'Education', 'school'),
      ('subscriptions', 'Subscriptions', 'subscriptions'),
      ('insurance', 'Insurance', 'security'),
      ('other', 'Other', 'more_horiz'),
    ];

    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final (id, name, icon) in defaults) {
      batch.insert(DatabaseConstants.tableCategories, {
        DatabaseConstants.colId: id,
        DatabaseConstants.colName: name,
        DatabaseConstants.colIcon: icon,
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      });
    }
    await batch.commit(noResult: true);
  }
}
