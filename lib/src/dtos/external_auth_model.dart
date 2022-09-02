import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "external_auth_model.g.dart";

/// Response DTO of a single ExternalAuth model.
@JsonSerializable(explicitToJson: true)
class ExternalAuthModel implements Jsonable {
  String id;
  String created;
  String updated;
  String userId;
  String provider;
  String providerId;

  ExternalAuthModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.userId = "",
    this.provider = "",
    this.providerId = "",
  });

  static ExternalAuthModel fromJson(Map<String, dynamic> json) =>
      _$ExternalAuthModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ExternalAuthModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
