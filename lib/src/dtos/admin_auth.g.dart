// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminAuth _$AdminAuthFromJson(Map<String, dynamic> json) => AdminAuth(
      token: json['token'] as String? ?? "",
      admin: json['admin'] == null
          ? null
          : AdminModel.fromJson(json['admin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminAuthToJson(AdminAuth instance) => <String, dynamic>{
      'token': instance.token,
      'admin': instance.admin?.toJson(),
    };
