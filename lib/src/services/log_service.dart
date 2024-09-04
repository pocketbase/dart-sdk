import "../client.dart";
import "../client_exception.dart";
import "../dtos/log_model.dart";
import "../dtos/log_stat.dart";
import "../dtos/result_list.dart";
import "base_service.dart";

/// The service that handles the **Log APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.logs] should be used.
class LogService extends BaseService {
  LogService(super.client);

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
              assertAs(data, {}),
              LogModel.fromJson,
            ));
  }

  /// Returns a single log by its id.
  Future<LogModel> getOne(
    String id, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) async {
    if (id.isEmpty) {
      throw ClientException(
        url: client.buildUrl("/api/logs/"),
        statusCode: 404,
        response: <String, dynamic>{
          "code": 404,
          "message": "Missing required log id.",
          "data": <String, dynamic>{},
        },
      );
    }

    return client
        .send(
          "/api/logs/${Uri.encodeComponent(id)}",
          query: query,
          headers: headers,
        )
        .then((data) => LogModel.fromJson(assertAs(data, {})));
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
        .then((data) => assertAs<List<dynamic>>(data, [])
            .map((item) => LogStat.fromJson(assertAs(item, {})))
            .toList());
  }
}
