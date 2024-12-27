import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "cron_job.g.dart";

/// Response DTO of a cron job item.
@JsonSerializable(explicitToJson: true)
class CronJob implements Jsonable {
  String id;
  String expression;

  CronJob({
    this.id = "",
    this.expression = "",
  });

  static CronJob fromJson(Map<String, dynamic> json) => _$CronJobFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CronJobToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
