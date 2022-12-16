import "../client.dart";
import "../dtos/health_check.dart";
import "base_service.dart";

/// The service that handles the **Health APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.health] should be used.
class HealthService extends BaseService {
  HealthService(PocketBase client) : super(client);

  /// Checks the health status of the api.
  Future<HealthCheck> check({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/health",
          query: query,
          headers: headers,
        )
        .then((data) =>
            HealthCheck.fromJson(data as Map<String, dynamic>? ?? {}));
  }
}
