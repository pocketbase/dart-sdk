// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_method_oauth2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthMethodOAuth2 _$AuthMethodOAuth2FromJson(Map<String, dynamic> json) =>
    AuthMethodOAuth2(
      enabled: json['enabled'] as bool? ?? false,
      providers: (json['providers'] as List<dynamic>?)
              ?.map(
                  (e) => AuthMethodProvider.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AuthMethodOAuth2ToJson(AuthMethodOAuth2 instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'providers': instance.providers.map((e) => e.toJson()).toList(),
    };
