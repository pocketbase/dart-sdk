import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "token_config.g.dart";

/// Response DTO of a single collection token config.
@JsonSerializable(explicitToJson: true)
class TokenConfig implements Jsonable {
  num duration;
  String? secret;

  TokenConfig({
    this.duration = 0,
    this.secret,
  });

  static TokenConfig fromJson(Map<String, dynamic> json) =>
      _$TokenConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TokenConfigToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
