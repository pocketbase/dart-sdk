// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionField _$CollectionFieldFromJson(Map<String, dynamic> json) =>
    CollectionField(
      json['data'] as Map<String, dynamic>?,
    )
      ..id = json['id'] as String
      ..name = json['name'] as String
      ..type = json['type'] as String
      ..system = json['system'] as bool
      ..required = json['required'] as bool
      ..presentable = json['presentable'] as bool
      ..hidden = json['hidden'] as bool;

Map<String, dynamic> _$CollectionFieldToJson(CollectionField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'system': instance.system,
      'required': instance.required,
      'presentable': instance.presentable,
      'hidden': instance.hidden,
      'data': instance.data,
    };
