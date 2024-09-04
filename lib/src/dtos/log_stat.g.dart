// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogStat _$LogStatFromJson(Map<String, dynamic> json) => LogStat(
      total: (json['total'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? "",
    );

Map<String, dynamic> _$LogStatToJson(LogStat instance) => <String, dynamic>{
      'total': instance.total,
      'date': instance.date,
    };
