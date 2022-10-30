import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "admin_model.g.dart";

/// Response DTO of a single admin model.
@JsonSerializable(explicitToJson: true)
class AdminModel implements Jsonable {
  String id;
  String created;
  String updated;
  int avatar;
  String email;

  AdminModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.avatar = 0,
    this.email = "",
  });

  static AdminModel fromJson(Map<String, dynamic> json) =>
      _$AdminModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AdminModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
