// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchemaField _$SchemaFieldFromJson(Map<String, dynamic> json) => SchemaField(
      id: json['id'] as String? ?? "",
      name: json['name'] as String? ?? "",
      type: json['type'] as String? ?? "",
      system: json['system'] as bool? ?? false,
      required: json['required'] as bool? ?? false,
      presentable: json['presentable'] as bool? ?? false,
      options: json['options'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SchemaFieldToJson(SchemaField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'system': instance.system,
      'required': instance.required,
      'presentable': instance.presentable,
      'options': instance.options,
    };
