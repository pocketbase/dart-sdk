import "../client.dart";
import "base_service.dart";

/// The service that handles the **Settings APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.settings] should be used.
class SettingsService extends BaseService {
  SettingsService(PocketBase client) : super(client);

  /// Fetch all available app settings.
  Future<Map<String, dynamic>> getAll({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/settings",
          query: query,
          headers: headers,
        )
        .then((data) => data as Map<String, dynamic>? ?? {});
  }

  /// Bulk updates app settings.
  Future<Map<String, dynamic>> update({
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/settings",
          method: "PATCH",
          body: body,
          query: query,
          headers: headers,
        )
        .then((data) => data as Map<String, dynamic>? ?? {});
  }
}
