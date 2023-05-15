import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "auth_model.dart" show RecordModel;
import "jsonable.dart";

part "record_auth.g.dart";

/// Response DTO of the record authentication data.
@JsonSerializable(explicitToJson: true)
class RecordAuth implements Jsonable {
  String token;
  RecordModel? record;
  Map<String, dynamic> meta;

  RecordAuth({
    this.token = "",
    this.record,
    this.meta = const {},
  });

  static RecordAuth fromJson(Map<String, dynamic> json) =>
      _$RecordAuthFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecordAuthToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
