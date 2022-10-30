// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionModel _$CollectionModelFromJson(Map<String, dynamic> json) =>
    CollectionModel(
      id: json['id'] as String? ?? "",
      type: json['type'] as String? ?? "base",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      name: json['name'] as String? ?? "",
      system: json['system'] as bool? ?? false,
      listRule: json['listRule'] as String?,
      viewRule: json['viewRule'] as String?,
      createRule: json['createRule'] as String?,
      updateRule: json['updateRule'] as String?,
      deleteRule: json['deleteRule'] as String?,
      schema: (json['schema'] as List<dynamic>?)
              ?.map((e) => SchemaField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      options: json['options'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CollectionModelToJson(CollectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'created': instance.created,
      'updated': instance.updated,
      'name': instance.name,
      'system': instance.system,
      'listRule': instance.listRule,
      'viewRule': instance.viewRule,
      'createRule': instance.createRule,
      'updateRule': instance.updateRule,
      'deleteRule': instance.deleteRule,
      'schema': instance.schema.map((e) => e.toJson()).toList(),
      'options': instance.options,
    };
