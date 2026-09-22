import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.createdAt,
    required this.updatedAt,
    this.passwordHash,
    this.passwordSalt,
  });

  final String id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? passwordHash;
  final String? passwordSalt;

  bool get hasPassword =>
      passwordHash != null &&
      passwordHash!.isNotEmpty &&
      passwordSalt != null &&
      passwordSalt!.isNotEmpty;

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? mobileNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? passwordHash,
    String? passwordSalt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        mobileNumber,
        createdAt,
        updatedAt,
        passwordHash,
        passwordSalt,
      ];
}
