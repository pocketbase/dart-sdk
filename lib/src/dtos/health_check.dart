import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "health_check.g.dart";

/// Response DTO of a health check.
@JsonSerializable(explicitToJson: true)
class HealthCheck implements Jsonable {
  int code;
  String message;

  HealthCheck({
    this.code = 0,
    this.message = "",
  });

  static HealthCheck fromJson(Map<String, dynamic> json) =>
      _$HealthCheckFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HealthCheckToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
