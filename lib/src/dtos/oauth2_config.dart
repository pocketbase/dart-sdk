import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "oauth2_config.g.dart";

/// Response DTO of a single collection oauth2 auth config.
@JsonSerializable(explicitToJson: true)
class OAuth2Config implements Jsonable {
  bool enabled;
  Map<String, String> mappedFields;
  List<dynamic> providers;

  OAuth2Config({
    this.enabled = false,
    Map<String, String>? mappedFields,
    List<dynamic>? providers,
  })  : mappedFields = mappedFields ?? {},
        providers = providers ?? [];

  static OAuth2Config fromJson(Map<String, dynamic> json) =>
      _$OAuth2ConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OAuth2ConfigToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
