import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";
import "record_model.dart";

part "record_subscription_event.g.dart";

/// Response DTO of a single realtime subscription event.
@JsonSerializable(explicitToJson: true)
class RecordSubscriptionEvent implements Jsonable {
  String action;
  RecordModel? record;

  RecordSubscriptionEvent({
    this.action = "",
    this.record,
  });

  static RecordSubscriptionEvent fromJson(Map<String, dynamic> json) =>
      _$RecordSubscriptionEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecordSubscriptionEventToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
