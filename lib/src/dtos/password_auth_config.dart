import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "password_auth_config.g.dart";

/// Response DTO of a single collection password auth config.
@JsonSerializable(explicitToJson: true)
class PasswordAuthConfig implements Jsonable {
  bool enabled;
  List<String> identityFields;

  PasswordAuthConfig({
    this.enabled = false,
    List<String>? identityFields,
  }) : identityFields = identityFields ?? [];

  static PasswordAuthConfig fromJson(Map<String, dynamic> json) =>
      _$PasswordAuthConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PasswordAuthConfigToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
