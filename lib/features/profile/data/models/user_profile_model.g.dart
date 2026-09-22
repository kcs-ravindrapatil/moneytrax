// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobile_number'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      passwordHash: json['password_hash'] as String?,
      passwordSalt: json['password_salt'] as String?,
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'email': instance.email,
      'mobile_number': instance.mobileNumber,
      'password_hash': instance.passwordHash,
      'password_salt': instance.passwordSalt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
