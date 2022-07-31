import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "log_request_model.g.dart";

/// Response DTO of a single log request model.
@JsonSerializable(explicitToJson: true)
class LogRequestModel implements Jsonable {
  String id;
  String created;
  String updated;
  String url;
  String method;
  int status;
  String auth;
  String ip;
  String referer;
  String userAgent;
  Map<String, dynamic> meta;

  LogRequestModel({
    this.id = "",
    this.created = "",
    this.updated = "",
    this.url = "",
    this.method = "",
    this.status = 0,
    this.auth = "",
    this.ip = "",
    this.referer = "",
    this.userAgent = "",
    this.meta = const {},
  });

  static LogRequestModel fromJson(Map<String, dynamic> json) =>
      _$LogRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LogRequestModelToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
