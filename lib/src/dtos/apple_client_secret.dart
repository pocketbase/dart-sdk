import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "apple_client_secret.g.dart";

/// Response DTO of the Apple OAuth2 Client Secret response.
@JsonSerializable(explicitToJson: true)
class AppleClientSecret implements Jsonable {
  String secret;

  AppleClientSecret({
    this.secret = "",
  });

  static AppleClientSecret fromJson(Map<String, dynamic> json) =>
      _$AppleClientSecretFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppleClientSecretToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
