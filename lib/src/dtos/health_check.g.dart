// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthCheck _$HealthCheckFromJson(Map<String, dynamic> json) => HealthCheck(
      code: (json['code'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? "",
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$HealthCheckToJson(HealthCheck instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
