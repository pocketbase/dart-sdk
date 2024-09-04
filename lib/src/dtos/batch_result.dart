import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "batch_result.g.dart";

/// Response DTO of a single batch request result.
@JsonSerializable(explicitToJson: true)
class BatchResult implements Jsonable {
  num status;

  // usually null, Map<string, dynamic> or List<Map<string, dynamic>>
  dynamic body;

  BatchResult({
    this.status = 0,
    this.body,
  });

  static BatchResult fromJson(Map<String, dynamic> json) =>
      _$BatchResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BatchResultToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
