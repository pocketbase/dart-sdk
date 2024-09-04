// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_file_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupFileInfo _$BackupFileInfoFromJson(Map<String, dynamic> json) =>
    BackupFileInfo(
      key: json['key'] as String? ?? "",
      size: (json['size'] as num?)?.toInt() ?? 0,
      modified: json['modified'] as String? ?? "",
    );

Map<String, dynamic> _$BackupFileInfoToJson(BackupFileInfo instance) =>
    <String, dynamic>{
      'key': instance.key,
      'size': instance.size,
      'modified': instance.modified,
    };
