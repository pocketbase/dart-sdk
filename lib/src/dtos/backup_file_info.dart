import "dart:convert";

import "package:json_annotation/json_annotation.dart";

import "jsonable.dart";

part "backup_file_info.g.dart";

/// Response DTO of a backup file info entry.
@JsonSerializable(explicitToJson: true)
class BackupFileInfo implements Jsonable {
  String key;
  int size;
  String modified;

  BackupFileInfo({
    this.key = "",
    this.size = 0,
    this.modified = "",
  });

  static BackupFileInfo fromJson(Map<String, dynamic> json) =>
      _$BackupFileInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BackupFileInfoToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
