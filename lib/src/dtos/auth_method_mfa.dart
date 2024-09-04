import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "auth_method_mfa.g.dart";

/// Response DTO of mfa auth method option.
@JsonSerializable(explicitToJson: true)
class AuthMethodMFA implements Jsonable {
  num duration;
  bool enabled;

  AuthMethodMFA({
    this.duration = 0,
    this.enabled = false,
  });

  static AuthMethodMFA fromJson(Map<String, dynamic> json) =>
      _$AuthMethodMFAFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthMethodMFAToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
