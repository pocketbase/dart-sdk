// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordAuth _$RecordAuthFromJson(Map<String, dynamic> json) => RecordAuth(
      token: json['token'] as String? ?? "",
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      record: json['record'] == null
          ? null
          : RecordModel.fromJson(json['record'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecordAuthToJson(RecordAuth instance) =>
    <String, dynamic>{
      'token': instance.token,
      'record': instance.record.toJson(),
      'meta': instance.meta,
    };
