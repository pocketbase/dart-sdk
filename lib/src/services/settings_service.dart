import "../client.dart";
import "../dtos/apple_client_secret.dart";
import "base_service.dart";

/// The service that handles the **Settings APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.settings] should be used.
class SettingsService extends BaseService {
  SettingsService(super.client);

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

  /// Performs a S3 storage connection test.
  Future<void> testS3({
    String filesystem = "storage", // "storage" or "backups"
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["filesystem"] ??= filesystem;

    return client.send(
      "/api/settings/test/s3",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Sends a test email.
  ///
  /// The possible `template` values are:
  /// - verification
  /// - password-reset
  /// - email-change
  Future<void> testEmail(
    String toEmail,
    String template, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["email"] ??= toEmail;
    enrichedBody["template"] ??= template;

    return client.send(
      "/api/settings/test/email",
      method: "POST",
      body: enrichedBody,
      query: query,
      headers: headers,
    );
  }

  /// Generates a new Apple OAuth2 client secret.
  Future<void> generateAppleClientSecret(
    String clientId,
    String teamId,
    String keyId,
    String privateKey,
    int duration, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final enrichedBody = Map<String, dynamic>.of(body);
    enrichedBody["clientId"] ??= clientId;
    enrichedBody["teamId"] ??= teamId;
    enrichedBody["keyId"] ??= keyId;
    enrichedBody["privateKey"] ??= privateKey;
    enrichedBody["duration"] ??= duration;

    return client
        .send(
          "/api/settings/apple/generate-client-secret",
          method: "POST",
          body: enrichedBody,
          query: query,
          headers: headers,
        )
        .then((data) =>
            AppleClientSecret.fromJson(data as Map<String, dynamic>? ?? {}));
  }
}
