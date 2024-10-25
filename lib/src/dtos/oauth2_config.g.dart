// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth2_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuth2Config _$OAuth2ConfigFromJson(Map<String, dynamic> json) => OAuth2Config(
      enabled: json['enabled'] as bool? ?? false,
      mappedFields: (json['mappedFields'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      providers: json['providers'] as List<dynamic>?,
    );

Map<String, dynamic> _$OAuth2ConfigToJson(OAuth2Config instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'mappedFields': instance.mappedFields,
      'providers': instance.providers,
    };
