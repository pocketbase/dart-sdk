import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "otp_response.g.dart";

/// Response DTO of a otp request response.
@JsonSerializable(explicitToJson: true)
class OTPResponse implements Jsonable {
  String otpId;

  OTPResponse({
    this.otpId = "",
  });

  static OTPResponse fromJson(Map<String, dynamic> json) =>
      _$OTPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OTPResponseToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
