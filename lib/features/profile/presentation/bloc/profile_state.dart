part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  editing,
  submitting,
  readyForConsent,
  consenting,
  success,
  failure,
}

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.fullName = '',
    this.email = '',
    this.mobileNumber = '',
    this.password = '',
    this.confirmPassword = '',
    this.isValid = false,
    this.errorMessage,
    this.existingId,
    this.createdAt,
    this.existingPasswordHash,
    this.existingPasswordSalt,
  });

  final ProfileStatus status;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String confirmPassword;
  final bool isValid;
  final String? errorMessage;
  final String? existingId;
  final DateTime? createdAt;
  final String? existingPasswordHash;
  final String? existingPasswordSalt;

  bool get isEditing => existingId != null;

  ProfileState copyWith({
    ProfileStatus? status,
    String? fullName,
    String? email,
    String? mobileNumber,
    String? password,
    String? confirmPassword,
    bool? isValid,
    String? errorMessage,
    String? existingId,
    DateTime? createdAt,
    String? existingPasswordHash,
    String? existingPasswordSalt,
  }) {
    return ProfileState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      existingId: existingId ?? this.existingId,
      createdAt: createdAt ?? this.createdAt,
      existingPasswordHash: existingPasswordHash ?? this.existingPasswordHash,
      existingPasswordSalt: existingPasswordSalt ?? this.existingPasswordSalt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        fullName,
        email,
        mobileNumber,
        password,
        confirmPassword,
        isValid,
        errorMessage,
        existingId,
        createdAt,
        existingPasswordHash,
        existingPasswordSalt,
      ];
}
