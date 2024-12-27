// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cron_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CronJob _$CronJobFromJson(Map<String, dynamic> json) => CronJob(
      id: json['id'] as String? ?? "",
      expression: json['expression'] as String? ?? "",
    );

Map<String, dynamic> _$CronJobToJson(CronJob instance) => <String, dynamic>{
      'id': instance.id,
      'expression': instance.expression,
    };
