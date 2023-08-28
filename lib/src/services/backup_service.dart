import "package:http/http.dart" as http;

import "../client.dart";
import "../dtos/backup_file_info.dart";
import "base_service.dart";

/// The service that handles the **Backup and restore APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.backups] should be used.
class BackupService extends BaseService {
  BackupService(PocketBase client) : super(client);

  /// Fetch all available app settings.
  Future<List<BackupFileInfo>> getFullList({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/backups",
          query: query,
          headers: headers,
        )
        .then((data) =>
            (data as List<dynamic>?)
                ?.map((item) =>
                    BackupFileInfo.fromJson(item as Map<String, dynamic>))
                .toList() ??
            const []);
  }

  /// Initializes a new backup.
  Future<void> create(
    String basename, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["name"] ??= basename;

    return client.send(
      "/api/backups",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Uploads an existing backup file.
  ///
  /// The key of the MultipartFile file must be "file".
  ///
  /// Example:
  /// ```dart
  /// await pb.backups.upload(http.MultipartFile.fromBytes("file", ...))
  /// ```
  Future<void> upload(
    http.MultipartFile file, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      "/api/backups/upload",
      method: "POST",
      body: body,
      query: query,
      headers: headers,
      files: [file],
    );
  }

  /// Deletes a single backup file.
  Future<void> delete(
    String key, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      "/api/backups/${Uri.encodeComponent(key)}",
      method: "DELETE",
      body: body,
      query: query,
      headers: headers,
    );
  }

  /// Initializes an app data restore from an existing backup.
  Future<void> restore(
    String key, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      "/api/backups/${Uri.encodeComponent(key)}/restore",
      method: "POST",
      body: body,
      query: query,
      headers: headers,
    );
  }

  /// Builds a download url for a single existing backup using an
  /// admin file token and the backup file key.
  ///
  /// The file token can be generated via `pb.files.getToken()`.
  Uri getDownloadUrl(
    String token,
    String key, {
    Map<String, dynamic> query = const {},
  }) {
    final params = Map<String, dynamic>.of(query);
    params["token"] ??= token;

    return client.buildUrl(
      "/api/backups/${Uri.encodeComponent(key)}",
      params,
    );
  }
}
