import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";
import "record_model.dart";

part "subscription_event.g.dart";

/// Response DTO of a single realtime subscription event.
@JsonSerializable(explicitToJson: true)
class SubscriptionEvent implements Jsonable {
  String action;
  RecordModel? record;

  SubscriptionEvent({
    this.action = "",
    this.record,
  });

  static SubscriptionEvent fromJson(Map<String, dynamic> json) =>
      _$SubscriptionEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionEventToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
