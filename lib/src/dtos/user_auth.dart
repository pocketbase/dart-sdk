import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";
import "user_model.dart";

part "user_auth.g.dart";

/// Response DTO of the user authentication data.
@JsonSerializable(explicitToJson: true)
class UserAuth implements Jsonable {
  String token;
  UserModel? user;
  Map<String, dynamic> meta;

  UserAuth({
    this.token = "",
    this.user,
    this.meta = const {},
  });

  static UserAuth fromJson(Map<String, dynamic> json) =>
      _$UserAuthFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserAuthToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
