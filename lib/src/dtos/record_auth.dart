import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";
import "record_model.dart";

part "record_auth.g.dart";

/// Response DTO of the record authentication data.
@JsonSerializable(explicitToJson: true)
class RecordAuth implements Jsonable {
  String token;
  RecordModel record;
  Map<String, dynamic> meta;

  RecordAuth({
    this.token = "",
    this.meta = const {},
    RecordModel? record,
  }) : record = record ?? RecordModel();

  static RecordAuth fromJson(Map<String, dynamic> json) =>
      _$RecordAuthFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecordAuthToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
