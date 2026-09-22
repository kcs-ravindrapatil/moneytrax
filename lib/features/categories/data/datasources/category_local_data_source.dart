import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this._appDatabase);

  final AppDatabase _appDatabase;
  final _uuid = const Uuid();

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        DatabaseConstants.tableCategories,
        orderBy: '${DatabaseConstants.colName} ASC',
      );
      return rows.map(CategoryModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        DatabaseConstants.tableCategories,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return CategoryModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      final db = await _appDatabase.database;
      final now = DateTime.now().toIso8601String();
      final model = CategoryModel(
        id: category.id.isEmpty ? _uuid.v4() : category.id,
        name: category.name,
        icon: category.icon,
        isDefault: 0,
        createdAt: now,
        updatedAt: now,
      );
      await db.insert(
        DatabaseConstants.tableCategories,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final db = await _appDatabase.database;
      final updated = CategoryModel(
        id: category.id,
        name: category.name,
        icon: category.icon,
        isDefault: category.isDefault,
        createdAt: category.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await db.update(
        DatabaseConstants.tableCategories,
        updated.toMap(),
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [category.id],
      );
      return updated;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final db = await _appDatabase.database;
      final existing = await getCategoryById(id);
      if (existing == null) return;
      if (existing.isDefault == 1) {
        throw const AppDatabaseException(
            'Default categories cannot be deleted.');
      }
      await db.delete(
        DatabaseConstants.tableCategories,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (e is AppDatabaseException) rethrow;
      throw AppDatabaseException(e.toString());
    }
  }
}
