import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "log_stat.g.dart";

/// Response DTO of a single log statistic summary item.
@JsonSerializable(explicitToJson: true)
class LogStat implements Jsonable {
  int total;
  String date;

  LogStat({
    this.total = 0,
    this.date = "",
  });

  static LogStat fromJson(Map<String, dynamic> json) => _$LogStatFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LogStatToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
