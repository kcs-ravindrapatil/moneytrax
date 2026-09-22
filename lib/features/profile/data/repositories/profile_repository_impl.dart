import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../../../integrations/consent/consent_integration.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource localDataSource,
    required AppDatabase appDatabase,
    required PreferencesDataSource preferences,
    required ConsentIntegration consentIntegration,
  })  : _local = localDataSource,
        _appDatabase = appDatabase,
        _preferences = preferences,
        _consent = consentIntegration;

  final ProfileLocalDataSource _local;
  final AppDatabase _appDatabase;
  final PreferencesDataSource _preferences;
  final ConsentIntegration _consent;

  @override
  Future<Result<UserProfile?>> getProfile() async {
    try {
      final model = await _local.getProfile();
      return Success(model?.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    try {
      final saved = await _local.saveProfile(
        UserProfileModel.fromEntity(profile),
      );
      return Success(saved.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final existing = await _local.getProfile();
      final merged = existing == null
          ? profile
          : profile.copyWith(
              passwordHash: profile.passwordHash ?? existing.passwordHash,
              passwordSalt: profile.passwordSalt ?? existing.passwordSalt,
            );
      final updated = await _local.updateProfile(
        UserProfileModel.fromEntity(merged),
      );
      return Success(updated.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<UserProfile>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final model = await _local.getProfile();
      if (model == null) {
        return const Error(AuthFailure('No account found on this device.'));
      }
      final profile = model.toEntity();
      final id = identifier.trim().toLowerCase();
      final email = profile.email.trim().toLowerCase();
      final mobileDigits =
          profile.mobileNumber.replaceAll(RegExp(r'\D'), '');
      final inputDigits = identifier.replaceAll(RegExp(r'\D'), '');
      final matchesEmail = email == id;
      final matchesMobile =
          inputDigits.isNotEmpty && mobileDigits == inputDigits;
      if (!matchesEmail && !matchesMobile) {
        return const Error(
          AuthFailure('Email or mobile number does not match this account.'),
        );
      }
      if (!profile.hasPassword) {
        return const Error(
          AuthFailure(
            'No password is set for this account. Use Forgot password to create one.',
          ),
        );
      }
      final ok = PasswordHasher.verify(
        password: password,
        salt: profile.passwordSalt!,
        expectedHash: profile.passwordHash!,
      );
      if (!ok) {
        return const Error(AuthFailure('Incorrect password.'));
      }
      await _preferences.setSessionActive(true);
      return Success(profile);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final model = await _local.getProfile();
      if (model == null) {
        return const Error(AuthFailure('No account found on this device.'));
      }
      final profile = model.toEntity();
      if (!profile.hasPassword) {
        return const Error(
          AuthFailure('No password is set. Use Forgot password first.'),
        );
      }
      final ok = PasswordHasher.verify(
        password: currentPassword,
        salt: profile.passwordSalt!,
        expectedHash: profile.passwordHash!,
      );
      if (!ok) {
        return const Error(AuthFailure('Current password is incorrect.'));
      }
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash(newPassword, salt);
      await _local.updateProfile(
        UserProfileModel.fromEntity(
          profile.copyWith(
            passwordHash: hash,
            passwordSalt: salt,
            updatedAt: DateTime.now(),
          ),
        ),
      );
      return const Success(null);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String mobileNumber,
    required String newPassword,
  }) async {
    try {
      final model = await _local.getProfile();
      if (model == null) {
        return const Error(AuthFailure('No account found on this device.'));
      }
      final profile = model.toEntity();
      final emailOk =
          profile.email.trim().toLowerCase() == email.trim().toLowerCase();
      final profileMobile =
          profile.mobileNumber.replaceAll(RegExp(r'\D'), '');
      final inputMobile = mobileNumber.replaceAll(RegExp(r'\D'), '');
      final mobileOk =
          inputMobile.isNotEmpty && profileMobile == inputMobile;
      if (!emailOk || !mobileOk) {
        return const Error(
          AuthFailure(
            'Email and mobile number must both match your registered profile.',
          ),
        );
      }
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash(newPassword, salt);
      await _local.updateProfile(
        UserProfileModel.fromEntity(
          profile.copyWith(
            passwordHash: hash,
            passwordSalt: salt,
            updatedAt: DateTime.now(),
          ),
        ),
      );
      return const Success(null);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> deleteAllUserData() async {
    try {
      await _consent.revokeConsent();
      await _appDatabase.clearAllData();
      await _preferences.clearAll();
      return const Success(null);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }
}
