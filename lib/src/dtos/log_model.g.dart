// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogModel _$LogModelFromJson(Map<String, dynamic> json) => LogModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      level: (json['level'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? "",
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LogModelToJson(LogModel instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'level': instance.level,
      'message': instance.message,
      'data': instance.data,
    };
