import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "auth_method_provider.dart";
import "jsonable.dart";

part "auth_methods_list.g.dart";

/// Response DTO of the allowed authentication methods.
@JsonSerializable(explicitToJson: true)
class AuthMethodsList implements Jsonable {
  bool usernamePassword;
  bool emailPassword;
  List<AuthMethodProvider> authProviders;

  AuthMethodsList({
    this.usernamePassword = false,
    this.emailPassword = false,
    this.authProviders = const [],
  });

  static AuthMethodsList fromJson(Map<String, dynamic> json) =>
      _$AuthMethodsListFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthMethodsListToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
