// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MFAConfig _$MFAConfigFromJson(Map<String, dynamic> json) => MFAConfig(
      duration: json['duration'] as num? ?? 0,
      enabled: json['enabled'] as bool? ?? false,
      rule: json['rule'] as String? ?? "",
    );

Map<String, dynamic> _$MFAConfigToJson(MFAConfig instance) => <String, dynamic>{
      'duration': instance.duration,
      'enabled': instance.enabled,
      'rule': instance.rule,
    };
