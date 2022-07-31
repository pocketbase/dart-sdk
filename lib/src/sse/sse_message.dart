import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "../dtos/jsonable.dart";

part "sse_message.g.dart";

/// A generic event stream message model.
@JsonSerializable(explicitToJson: true)
class SseMessage implements Jsonable {
  /// String identifier representing the last event ID value.
  String id;

  /// The name/type of the event message.
  String event;

  /// The raw data of the event message.
  String data;

  /// The reconnection time (in milliseconds).
  int retry;

  SseMessage({
    this.id = "",
    this.event = "message",
    this.data = "",
    this.retry = 0,
  });

  /// Decodes the event message data as json map.
  Map<String, dynamic> jsonData() {
    if (data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        return decoded is Map<String, dynamic> ? decoded : {"data": decoded};
      } catch (_) {}

      // normalize and wrap as object
      return {"data": data};
    }

    return {};
  }

  static SseMessage fromJson(Map<String, dynamic> json) =>
      _$SseMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SseMessageToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
