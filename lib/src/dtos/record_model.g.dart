// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordModel _$RecordModelFromJson(Map<String, dynamic> json) => RecordModel(
      json['data'] as Map<String, dynamic>?,
    )
      ..id = json['id'] as String
      ..expand = (json['expand'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => RecordModel.fromJson(e as Map<String, dynamic>))
                .toList()),
      );

Map<String, dynamic> _$RecordModelToJson(RecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'expand': instance.expand,
    };
