// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionEvent _$SubscriptionEventFromJson(Map<String, dynamic> json) =>
    SubscriptionEvent(
      action: json['action'] as String? ?? "",
      record: json['record'] == null
          ? null
          : RecordModel.fromJson(json['record'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscriptionEventToJson(SubscriptionEvent instance) =>
    <String, dynamic>{
      'action': instance.action,
      'record': instance.record?.toJson(),
    };
