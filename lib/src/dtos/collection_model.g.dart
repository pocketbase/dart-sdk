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
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => CollectionField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      indexes: (json['indexes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      viewQuery: json['viewQuery'] as String?,
      authRule: json['authRule'] as String?,
      manageRule: json['manageRule'] as String?,
      authAlert: json['authAlert'] == null
          ? null
          : AuthAlertConfig.fromJson(json['authAlert'] as Map<String, dynamic>),
      oauth2: json['oauth2'] == null
          ? null
          : OAuth2Config.fromJson(json['oauth2'] as Map<String, dynamic>),
      passwordAuth: json['passwordAuth'] == null
          ? null
          : PasswordAuthConfig.fromJson(
              json['passwordAuth'] as Map<String, dynamic>),
      mfa: json['mfa'] == null
          ? null
          : MFAConfig.fromJson(json['mfa'] as Map<String, dynamic>),
      otp: json['otp'] == null
          ? null
          : OTPConfig.fromJson(json['otp'] as Map<String, dynamic>),
      authToken: json['authToken'] == null
          ? null
          : TokenConfig.fromJson(json['authToken'] as Map<String, dynamic>),
      passwordResetToken: json['passwordResetToken'] == null
          ? null
          : TokenConfig.fromJson(
              json['passwordResetToken'] as Map<String, dynamic>),
      emailChangeToken: json['emailChangeToken'] == null
          ? null
          : TokenConfig.fromJson(
              json['emailChangeToken'] as Map<String, dynamic>),
      verificationToken: json['verificationToken'] == null
          ? null
          : TokenConfig.fromJson(
              json['verificationToken'] as Map<String, dynamic>),
      fileToken: json['fileToken'] == null
          ? null
          : TokenConfig.fromJson(json['fileToken'] as Map<String, dynamic>),
      verificationTemplate: json['verificationTemplate'] == null
          ? null
          : EmailTemplateConfig.fromJson(
              json['verificationTemplate'] as Map<String, dynamic>),
      resetPasswordTemplate: json['resetPasswordTemplate'] == null
          ? null
          : EmailTemplateConfig.fromJson(
              json['resetPasswordTemplate'] as Map<String, dynamic>),
      confirmEmailChangeTemplate: json['confirmEmailChangeTemplate'] == null
          ? null
          : EmailTemplateConfig.fromJson(
              json['confirmEmailChangeTemplate'] as Map<String, dynamic>),
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
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'indexes': instance.indexes,
      'viewQuery': instance.viewQuery,
      'authRule': instance.authRule,
      'manageRule': instance.manageRule,
      'authAlert': instance.authAlert?.toJson(),
      'oauth2': instance.oauth2?.toJson(),
      'passwordAuth': instance.passwordAuth?.toJson(),
      'mfa': instance.mfa?.toJson(),
      'otp': instance.otp?.toJson(),
      'authToken': instance.authToken?.toJson(),
      'passwordResetToken': instance.passwordResetToken?.toJson(),
      'emailChangeToken': instance.emailChangeToken?.toJson(),
      'verificationToken': instance.verificationToken?.toJson(),
      'fileToken': instance.fileToken?.toJson(),
      'verificationTemplate': instance.verificationTemplate?.toJson(),
      'resetPasswordTemplate': instance.resetPasswordTemplate?.toJson(),
      'confirmEmailChangeTemplate':
          instance.confirmEmailChangeTemplate?.toJson(),
    };
