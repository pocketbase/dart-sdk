// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenConfig _$TokenConfigFromJson(Map<String, dynamic> json) => TokenConfig(
      duration: json['duration'] as num? ?? 0,
      secret: json['secret'] as String?,
    );

Map<String, dynamic> _$TokenConfigToJson(TokenConfig instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'secret': instance.secret,
    };
