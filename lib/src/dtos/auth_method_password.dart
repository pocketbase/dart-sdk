import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "auth_method_password.g.dart";

/// Response DTO of password/identity auth method option.
@JsonSerializable(explicitToJson: true)
class AuthMethodPassword implements Jsonable {
  bool enabled;
  List<String> identityFields;

  AuthMethodPassword({
    this.enabled = false,
    List<String>? identityFields,
  }) : identityFields = identityFields ?? [];

  static AuthMethodPassword fromJson(Map<String, dynamic> json) =>
      _$AuthMethodPasswordFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthMethodPasswordToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
