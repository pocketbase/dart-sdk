// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchResult _$BatchResultFromJson(Map<String, dynamic> json) => BatchResult(
      status: json['status'] as num? ?? 0,
      body: json['body'],
    );

Map<String, dynamic> _$BatchResultToJson(BatchResult instance) =>
    <String, dynamic>{
      'status': instance.status,
      'body': instance.body,
    };
