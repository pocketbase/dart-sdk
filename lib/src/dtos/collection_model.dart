import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "auth_alert_config.dart";
import "collection_field.dart";
import "email_template_config.dart";
import "jsonable.dart";
import "mfa_config.dart";
import "oauth2_config.dart";
import "otp_config.dart";
import "password_auth_config.dart";
import "token_config.dart";

part "collection_model.g.dart";

/// Response DTO of a single collection model.
@JsonSerializable(explicitToJson: true)
class CollectionModel implements Jsonable {
  String id;
  String type;
  String created;
  String updated;
  String name;
  bool system;
  String? listRule;
  String? viewRule;
  String? createRule;
  String? updateRule;
  String? deleteRule;
  List<CollectionField> fields;
  List<String> indexes;

  // view fields
  // ---
  String? viewQuery;

  // auth fields
  // ---
  String? authRule;
  String? manageRule;
  AuthAlertConfig? authAlert;
  OAuth2Config? oauth2;
  PasswordAuthConfig? passwordAuth;
  MFAConfig? mfa;
  OTPConfig? otp;
  TokenConfig? authToken;
  TokenConfig? passwordResetToken;
  TokenConfig? emailChangeToken;
  TokenConfig? verificationToken;
  TokenConfig? fileToken;
  EmailTemplateConfig? verificationTemplate;
  EmailTemplateConfig? resetPasswordTemplate;
  EmailTemplateConfig? confirmEmailChangeTemplate;

  CollectionModel({
    this.id = "",
    this.type = "base",
    this.created = "",
    this.updated = "",
    this.name = "",
    this.system = false,
    this.listRule,
    this.viewRule,
    this.createRule,
    this.updateRule,
    this.deleteRule,
    this.fields = const [],
    this.indexes = const [],
    this.viewQuery,
    this.authRule,
    this.manageRule,
    this.authAlert,
    this.oauth2,
    this.passwordAuth,
    this.mfa,
    this.otp,
    this.authToken,
    this.passwordResetToken,
    this.emailChangeToken,
    this.verificationToken,
    this.fileToken,
    this.verificationTemplate,
    this.resetPasswordTemplate,
    this.confirmEmailChangeTemplate,
  });

  static CollectionModel fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CollectionModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
