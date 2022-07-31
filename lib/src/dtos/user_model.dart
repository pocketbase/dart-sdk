import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";
import "record_model.dart";

part "user_model.g.dart";

/// Response DTO of a single user model.
@JsonSerializable(explicitToJson: true)
class UserModel implements Jsonable {
  String id;
  String created;
  String updated;
  bool verified;
  String email;
  String lastResetSentAt;
  String lastVerificationSentAt;
  RecordModel? profile;

  UserModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.verified = false,
    this.email = "",
    this.lastResetSentAt = "",
    this.lastVerificationSentAt = "",
    this.profile,
  });

  static UserModel fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
