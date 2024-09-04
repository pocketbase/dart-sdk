// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchemaField _$SchemaFieldFromJson(Map<String, dynamic> json) => SchemaField(
      json['data'] as Map<String, dynamic>?,
    )
      ..id = json['id'] as String
      ..name = json['name'] as String
      ..type = json['type'] as String
      ..system = json['system'] as bool
      ..required = json['required'] as bool
      ..presentable = json['presentable'] as bool
      ..hidden = json['hidden'] as bool;

Map<String, dynamic> _$SchemaFieldToJson(SchemaField instance) =>
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
