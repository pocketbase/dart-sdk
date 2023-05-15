// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordModel _$RecordModelFromJson(Map<String, dynamic> json) => RecordModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      collectionId: json['collectionId'] as String? ?? "",
      collectionName: json['collectionName'] as String? ?? "",
    );

Map<String, dynamic> _$RecordModelToJson(RecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
    };

AdminModel _$AdminModelFromJson(Map<String, dynamic> json) => AdminModel(
      id: json['id'] as String? ?? "",
      created: json['created'] as String? ?? "",
      updated: json['updated'] as String? ?? "",
      avatar: json['avatar'] as int? ?? 0,
      email: json['email'] as String? ?? "",
    );

Map<String, dynamic> _$AdminModelToJson(AdminModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'avatar': instance.avatar,
      'email': instance.email,
    };
