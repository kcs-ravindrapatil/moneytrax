import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel {
  const UserProfileModel({
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

  @JsonKey(name: 'full_name')
  final String fullName;

  final String email;

  @JsonKey(name: 'mobile_number')
  final String mobileNumber;

  @JsonKey(name: 'password_hash')
  final String? passwordHash;

  @JsonKey(name: 'password_salt')
  final String? passwordSalt;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      mobileNumber: map['mobile_number'] as String,
      passwordHash: map['password_hash'] as String?,
      passwordSalt: map['password_salt'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
        'password_hash': passwordHash,
        'password_salt': passwordSalt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  UserProfile toEntity() => UserProfile(
        id: id,
        fullName: fullName,
        email: email,
        mobileNumber: mobileNumber,
        passwordHash: passwordHash,
        passwordSalt: passwordSalt,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );

  factory UserProfileModel.fromEntity(UserProfile entity) => UserProfileModel(
        id: entity.id,
        fullName: entity.fullName,
        email: entity.email,
        mobileNumber: entity.mobileNumber,
        passwordHash: entity.passwordHash,
        passwordSalt: entity.passwordSalt,
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
      );
}
