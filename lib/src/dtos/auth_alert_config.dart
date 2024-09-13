import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "email_template_config.dart";
import "jsonable.dart";

part "auth_alert_config.g.dart";

/// Response DTO of a single collection auth alert config.
@JsonSerializable(explicitToJson: true)
class AuthAlertConfig implements Jsonable {
  bool enabled;
  EmailTemplateConfig emailTemplate;

  AuthAlertConfig({
    this.enabled = false,
    EmailTemplateConfig? emailTemplate,
  }) : emailTemplate = emailTemplate ?? EmailTemplateConfig();

  static AuthAlertConfig fromJson(Map<String, dynamic> json) =>
      _$AuthAlertConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthAlertConfigToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
