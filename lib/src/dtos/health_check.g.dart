// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthCheck _$HealthCheckFromJson(Map<String, dynamic> json) => HealthCheck(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? "",
    );

Map<String, dynamic> _$HealthCheckToJson(HealthCheck instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };
