import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "auth_method_mfa.dart";
import "auth_method_oauth2.dart";
import "auth_method_otp.dart";
import "auth_method_password.dart";
import "jsonable.dart";

part "auth_methods_list.g.dart";

/// Response DTO of the allowed authentication methods.
@JsonSerializable(explicitToJson: true)
class AuthMethodsList implements Jsonable {
  AuthMethodMFA mfa;
  AuthMethodOTP otp;
  AuthMethodPassword password;
  AuthMethodOAuth2 oauth2;

  AuthMethodsList({
    AuthMethodMFA? mfa,
    AuthMethodOTP? otp,
    AuthMethodPassword? password,
    AuthMethodOAuth2? oauth2,
  })  : mfa = mfa ?? AuthMethodMFA(),
        otp = otp ?? AuthMethodOTP(),
        password = password ?? AuthMethodPassword(),
        oauth2 = oauth2 ?? AuthMethodOAuth2();

  static AuthMethodsList fromJson(Map<String, dynamic> json) =>
      _$AuthMethodsListFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthMethodsListToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
