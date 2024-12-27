import "../client.dart";
import "../dtos/cron_job.dart";
import "base_service.dart";

/// The service that handles the **Cron APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.backups] should be used.
class CronService extends BaseService {
  CronService(super.client);

  /// Returns list with all registered app cron jobs.
  Future<List<CronJob>> getFullList({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send<List<dynamic>>(
          "/api/crons",
          query: query,
          headers: headers,
        )
        .then((data) => data
            .map(
                (item) => CronJob.fromJson(item as Map<String, dynamic>? ?? {}))
            .toList());
  }

  /// Runs the specified cron job.
  Future<void> run(
    String jobId, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client.send(
      "/api/crons/${Uri.encodeComponent(jobId)}",
      method: "POST",
      body: body,
      query: query,
      headers: headers,
    );
  }
}
