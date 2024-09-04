// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_methods_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthMethodsList _$AuthMethodsListFromJson(Map<String, dynamic> json) =>
    AuthMethodsList(
      mfa: json['mfa'] == null
          ? null
          : AuthMethodMFA.fromJson(json['mfa'] as Map<String, dynamic>),
      otp: json['otp'] == null
          ? null
          : AuthMethodOTP.fromJson(json['otp'] as Map<String, dynamic>),
      password: json['password'] == null
          ? null
          : AuthMethodPassword.fromJson(
              json['password'] as Map<String, dynamic>),
      oauth2: json['oauth2'] == null
          ? null
          : AuthMethodOAuth2.fromJson(json['oauth2'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthMethodsListToJson(AuthMethodsList instance) =>
    <String, dynamic>{
      'mfa': instance.mfa.toJson(),
      'otp': instance.otp.toJson(),
      'password': instance.password.toJson(),
      'oauth2': instance.oauth2.toJson(),
    };
