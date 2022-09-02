// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExternalAuthModel _$ExternalAuthModelFromJson(Map<String, dynamic> json) =>
    ExternalAuthModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      userId: json['userId'] as String? ?? "",
      provider: json['provider'] as String? ?? "",
      providerId: json['providerId'] as String? ?? "",
    );

Map<String, dynamic> _$ExternalAuthModelToJson(ExternalAuthModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'userId': instance.userId,
      'provider': instance.provider,
      'providerId': instance.providerId,
    };
