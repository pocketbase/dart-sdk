// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_alert_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthAlertConfig _$AuthAlertConfigFromJson(Map<String, dynamic> json) =>
    AuthAlertConfig(
      enabled: json['enabled'] as bool? ?? false,
      emailTemplate: json['emailTemplate'] == null
          ? null
          : EmailTemplateConfig.fromJson(
              json['emailTemplate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthAlertConfigToJson(AuthAlertConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'emailTemplate': instance.emailTemplate.toJson(),
    };
