// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_method_mfa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthMethodMFA _$AuthMethodMFAFromJson(Map<String, dynamic> json) =>
    AuthMethodMFA(
      duration: json['duration'] as num? ?? 0,
      enabled: json['enabled'] as bool? ?? false,
    );

Map<String, dynamic> _$AuthMethodMFAToJson(AuthMethodMFA instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'enabled': instance.enabled,
    };
