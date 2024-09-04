import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "otp_config.g.dart";

/// Response DTO of a single collection otp auth config.
@JsonSerializable(explicitToJson: true)
class OTPConfig implements Jsonable {
  num duration;
  num length;
  bool enabled;

  OTPConfig({
    this.duration = 0,
    this.length = 0,
    this.enabled = false,
  });

  static OTPConfig fromJson(Map<String, dynamic> json) =>
      _$OTPConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OTPConfigToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
