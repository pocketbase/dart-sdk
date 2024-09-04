import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "auth_method_otp.g.dart";

/// Response DTO of otp auth method option.
@JsonSerializable(explicitToJson: true)
class AuthMethodOTP implements Jsonable {
  num duration;
  bool enabled;

  AuthMethodOTP({
    this.duration = 0,
    this.enabled = false,
  });

  static AuthMethodOTP fromJson(Map<String, dynamic> json) =>
      _$AuthMethodOTPFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthMethodOTPToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
