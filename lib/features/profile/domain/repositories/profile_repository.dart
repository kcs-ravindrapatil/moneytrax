import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile?>> getProfile();
  Future<Result<UserProfile>> saveProfile(UserProfile profile);
  Future<Result<UserProfile>> updateProfile(UserProfile profile);
  Future<Result<UserProfile>> login({
    required String identifier,
    required String password,
  });
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Result<void>> resetPassword({
    required String email,
    required String mobileNumber,
    required String newPassword,
  });
  Future<Result<void>> deleteAllUserData();
}
