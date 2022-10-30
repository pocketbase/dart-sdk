// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_subscription_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordSubscriptionEvent _$RecordSubscriptionEventFromJson(
        Map<String, dynamic> json) =>
    RecordSubscriptionEvent(
      action: json['action'] as String? ?? "",
      record: json['record'] == null
          ? null
          : RecordModel.fromJson(json['record'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecordSubscriptionEventToJson(
        RecordSubscriptionEvent instance) =>
    <String, dynamic>{
      'action': instance.action,
      'record': instance.record?.toJson(),
    };
