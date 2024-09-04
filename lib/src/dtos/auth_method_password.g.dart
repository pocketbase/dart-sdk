// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_method_password.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthMethodPassword _$AuthMethodPasswordFromJson(Map<String, dynamic> json) =>
    AuthMethodPassword(
      enabled: json['enabled'] as bool? ?? false,
      identityFields: (json['identityFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AuthMethodPasswordToJson(AuthMethodPassword instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'identityFields': instance.identityFields,
    };
