// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionModel _$CollectionModelFromJson(Map<String, dynamic> json) =>
    CollectionModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      name: json['name'] as String? ?? "",
      schema: (json['schema'] as List<dynamic>?)
              ?.map((e) => SchemaField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      system: json['system'] as bool? ?? false,
      listRule: json['listRule'] as String?,
      viewRule: json['viewRule'] as String?,
      createRule: json['createRule'] as String?,
      updateRule: json['updateRule'] as String?,
      deleteRule: json['deleteRule'] as String?,
    );

Map<String, dynamic> _$CollectionModelToJson(CollectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'name': instance.name,
      'schema': instance.schema.map((e) => e.toJson()).toList(),
      'system': instance.system,
      'listRule': instance.listRule,
      'viewRule': instance.viewRule,
      'createRule': instance.createRule,
      'updateRule': instance.updateRule,
      'deleteRule': instance.deleteRule,
    };
