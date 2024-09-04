import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "mfa_config.g.dart";

/// Response DTO of a single collection mfa auth config.
@JsonSerializable(explicitToJson: true)
class MFAConfig implements Jsonable {
  num duration;
  bool enabled;

  MFAConfig({
    this.duration = 0,
    this.enabled = false,
  });

  static MFAConfig fromJson(Map<String, dynamic> json) =>
      _$MFAConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MFAConfigToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
