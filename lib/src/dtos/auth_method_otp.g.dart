// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_method_otp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthMethodOTP _$AuthMethodOTPFromJson(Map<String, dynamic> json) =>
    AuthMethodOTP(
      duration: json['duration'] as num? ?? 0,
      enabled: json['enabled'] as bool? ?? false,
    );

Map<String, dynamic> _$AuthMethodOTPToJson(AuthMethodOTP instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'enabled': instance.enabled,
    };
