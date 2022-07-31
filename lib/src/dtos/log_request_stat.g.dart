// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_request_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogRequestStat _$LogRequestStatFromJson(Map<String, dynamic> json) =>
    LogRequestStat(
      total: json['total'] as int? ?? 0,
      date: json['date'] as String? ?? "",
    );

Map<String, dynamic> _$LogRequestStatToJson(LogRequestStat instance) =>
    <String, dynamic>{
      'total': instance.total,
      'date': instance.date,
    };
