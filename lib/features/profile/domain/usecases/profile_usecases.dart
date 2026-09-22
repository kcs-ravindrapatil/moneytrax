import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  GetProfileUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Result<UserProfile?>> call() => _repository.getProfile();
}

class SaveProfileUseCase {
  SaveProfileUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Result<UserProfile>> call(UserProfile profile) =>
      _repository.saveProfile(profile);
}

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Result<UserProfile>> call(UserProfile profile) =>
      _repository.updateProfile(profile);
}

class LoginUseCase {
  LoginUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Result<UserProfile>> call({
    required String identifier,
    required String password,
  }) =>
      _repository.login(identifier: identifier, password: password);
}

class UpdatePasswordUseCase {
  UpdatePasswordUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
  }) =>
      _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Result<void>> call({
    required String email,
    required String mobileNumber,
    required String newPassword,
  }) =>
      _repository.resetPassword(
        email: email,
        mobileNumber: mobileNumber,
        newPassword: newPassword,
      );
}

class DeleteProfileUseCase {
  DeleteProfileUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Result<void>> call() => _repository.deleteAllUserData();
}
