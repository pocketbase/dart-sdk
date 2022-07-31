// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordModel _$RecordModelFromJson(Map<String, dynamic> json) => RecordModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      collectionId: json['@collectionId'] as String? ?? "",
      collectionName: json['@collectionName'] as String? ?? "",
      expand: json['@expand'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$RecordModelToJson(RecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      '@collectionId': instance.collectionId,
      '@collectionName': instance.collectionName,
      '@expand': instance.expand,
    };
