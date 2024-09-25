import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "auth_method_provider.g.dart";

/// Response DTO of a single OAuth2 provider.
@JsonSerializable(explicitToJson: true)
class AuthMethodProvider implements Jsonable {
  String name;
  String displayName;
  String state;
  String codeVerifier;
  String codeChallenge;
  String codeChallengeMethod;
  String authURL;
  bool? pkce;

  @Deprecated("use authURL")
  @JsonKey(includeToJson: false, includeFromJson: false)
  String get authUrl => authURL;

  @Deprecated("use authURL")
  set authUrl(String url) => authURL = url;

  AuthMethodProvider({
    this.name = "",
    this.displayName = "",
    this.state = "",
    this.codeVerifier = "",
    this.codeChallenge = "",
    this.codeChallengeMethod = "",
    this.authURL = "",
    this.pkce,
  });

  static AuthMethodProvider fromJson(Map<String, dynamic> json) =>
      _$AuthMethodProviderFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthMethodProviderToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
