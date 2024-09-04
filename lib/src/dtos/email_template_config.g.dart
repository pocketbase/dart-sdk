// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_template_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailTemplateConfig _$EmailTemplateConfigFromJson(Map<String, dynamic> json) =>
    EmailTemplateConfig(
      subject: json['subject'] as String? ?? "",
      body: json['body'] as String? ?? "",
    );

Map<String, dynamic> _$EmailTemplateConfigToJson(
        EmailTemplateConfig instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'body': instance.body,
    };
