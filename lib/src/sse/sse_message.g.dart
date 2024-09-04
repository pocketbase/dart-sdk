// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SseMessage _$SseMessageFromJson(Map<String, dynamic> json) => SseMessage(
      id: json['id'] as String? ?? "",
      event: json['event'] as String? ?? "message",
      data: json['data'] as String? ?? "",
      retry: (json['retry'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SseMessageToJson(SseMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event': instance.event,
      'data': instance.data,
      'retry': instance.retry,
    };
