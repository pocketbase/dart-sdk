// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminModel _$AdminModelFromJson(Map<String, dynamic> json) => AdminModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      avatar: json['avatar'] as int? ?? 0,
      email: json['email'] as String? ?? "",
      lastResetSentAt: json['lastResetSentAt'] as String? ?? "",
    );

Map<String, dynamic> _$AdminModelToJson(AdminModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'avatar': instance.avatar,
      'email': instance.email,
      'lastResetSentAt': instance.lastResetSentAt,
    };
