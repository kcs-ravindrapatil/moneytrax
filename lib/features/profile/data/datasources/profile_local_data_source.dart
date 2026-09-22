import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getProfile();
  Future<UserProfileModel> saveProfile(UserProfileModel profile);
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<void> deleteProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<UserProfileModel?> getProfile() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        DatabaseConstants.tableUsers,
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return UserProfileModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<UserProfileModel> saveProfile(UserProfileModel profile) async {
    try {
      final db = await _appDatabase.database;
      await db.insert(
        DatabaseConstants.tableUsers,
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return profile;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    try {
      final db = await _appDatabase.database;
      await db.update(
        DatabaseConstants.tableUsers,
        profile.toMap(),
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [profile.id],
      );
      return profile;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      final db = await _appDatabase.database;
      await db.delete(DatabaseConstants.tableUsers);
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}
