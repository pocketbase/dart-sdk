import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "email_template_config.g.dart";

/// Response DTO of a single collection email template config.
@JsonSerializable(explicitToJson: true)
class EmailTemplateConfig implements Jsonable {
  String subject;
  String body;

  EmailTemplateConfig({
    this.subject = "",
    this.body = "",
  });

  static EmailTemplateConfig fromJson(Map<String, dynamic> json) =>
      _$EmailTemplateConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmailTemplateConfigToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
