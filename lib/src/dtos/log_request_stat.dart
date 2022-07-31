import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "log_request_stat.g.dart";

/// Response DTO of a single log request statistics summary item.
@JsonSerializable(explicitToJson: true)
class LogRequestStat implements Jsonable {
  int total;
  String date;

  LogRequestStat({
    this.total = 0,
    this.date = "",
  });

  static LogRequestStat fromJson(Map<String, dynamic> json) =>
      _$LogRequestStatFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LogRequestStatToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
