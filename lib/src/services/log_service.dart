import "../client.dart";
import "../dtos/log_model.dart";
import "../dtos/log_stat.dart";
import "../dtos/result_list.dart";
import "base_service.dart";

/// The service that handles the **Log APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.logs] should be used.
class LogService extends BaseService {
  LogService(PocketBase client) : super(client);

  /// Returns paginated logs list.
  Future<ResultList<LogModel>> getList({
    int page = 1,
    int perPage = 30,
    String? filter,
    String? sort,
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    final params = Map<String, dynamic>.of(query);
    params["page"] = page;
    params["perPage"] = perPage;
    params["filter"] ??= filter;
    params["sort"] ??= sort;

    return client
        .send(
          "/api/logs",
          query: params,
          headers: headers,
        )
        .then((data) => ResultList<LogModel>.fromJson(
              data as Map<String, dynamic>? ?? {},
              LogModel.fromJson,
            ));
  }

  /// Returns a single log by its id.
  Future<LogModel> getOne(
    String id, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/logs/${Uri.encodeComponent(id)}",
          query: query,
          headers: headers,
        )
        .then((data) => LogModel.fromJson(data as Map<String, dynamic>? ?? {}));
  }

  /// Returns request logs statistics.
  Future<List<LogStat>> getStats({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/logs/stats",
          query: query,
          headers: headers,
        )
        .then((data) =>
            (data as List<dynamic>?)
                ?.map((item) => LogStat.fromJson(item as Map<String, dynamic>))
                .toList() ??
            []);
  }
}
