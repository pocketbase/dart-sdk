// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_auth_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordAuthConfig _$PasswordAuthConfigFromJson(Map<String, dynamic> json) =>
    PasswordAuthConfig(
      enabled: json['enabled'] as bool? ?? false,
      identityFields: (json['identityFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PasswordAuthConfigToJson(PasswordAuthConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'identityFields': instance.identityFields,
    };
