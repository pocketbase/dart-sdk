import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "auth_method_provider.dart";
import "jsonable.dart";

part "auth_method_oauth2.g.dart";

/// Response DTO of oauth2 auth method option.
@JsonSerializable(explicitToJson: true)
class AuthMethodOAuth2 implements Jsonable {
  bool enabled;
  List<AuthMethodProvider> providers;

  AuthMethodOAuth2({
    this.enabled = false,
    this.providers = const [],
  });

  static AuthMethodOAuth2 fromJson(Map<String, dynamic> json) =>
      _$AuthMethodOAuth2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthMethodOAuth2ToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
