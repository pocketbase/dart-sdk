import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "admin_model.dart";
import "jsonable.dart";

part "admin_auth.g.dart";

/// Response DTO of the admin authentication data.
@JsonSerializable(explicitToJson: true)
class AdminAuth implements Jsonable {
  String token;
  AdminModel? admin;

  AdminAuth({
    this.token = "",
    this.admin,
  });

  static AdminAuth fromJson(Map<String, dynamic> json) =>
      _$AdminAuthFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AdminAuthToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
