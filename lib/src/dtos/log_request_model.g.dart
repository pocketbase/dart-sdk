// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogRequestModel _$LogRequestModelFromJson(Map<String, dynamic> json) =>
    LogRequestModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      url: json['url'] as String? ?? "",
      method: json['method'] as String? ?? "",
      status: json['status'] as int? ?? 0,
      auth: json['auth'] as String? ?? "",
      ip: json['ip'] as String? ?? "",
      referer: json['referer'] as String? ?? "",
      userAgent: json['userAgent'] as String? ?? "",
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LogRequestModelToJson(LogRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'url': instance.url,
      'method': instance.method,
      'status': instance.status,
      'auth': instance.auth,
      'ip': instance.ip,
      'referer': instance.referer,
      'userAgent': instance.userAgent,
      'meta': instance.meta,
    };
