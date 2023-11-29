import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "log_model.g.dart";

/// Response DTO of a single log model.
@JsonSerializable(explicitToJson: true)
class LogModel implements Jsonable {
  String id;
  String created;
  String updated;
  int level;
  String message;
  Map<String, dynamic> data;

  LogModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.level = 0,
    this.message = "",
    this.data = const {},
  });

  static LogModel fromJson(Map<String, dynamic> json) =>
      _$LogModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LogModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
