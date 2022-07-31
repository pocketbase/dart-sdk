// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      verified: json['verified'] as bool? ?? false,
      email: json['email'] as String? ?? "",
      lastResetSentAt: json['lastResetSentAt'] as String? ?? "",
      lastVerificationSentAt: json['lastVerificationSentAt'] as String? ?? "",
      profile: json['profile'] == null
          ? null
          : RecordModel.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'verified': instance.verified,
      'email': instance.email,
      'lastResetSentAt': instance.lastResetSentAt,
      'lastVerificationSentAt': instance.lastVerificationSentAt,
      'profile': instance.profile?.toJson(),
    };
