import "../client.dart";
import "../dtos/log_request_model.dart";
import "../dtos/log_request_stat.dart";
import "../dtos/result_list.dart";
import "base_service.dart";

/// The service that handles the **Log APIs**.
///
/// Usually shouldn't be initialized manually and instead
/// [PocketBase.logs] should be used.
class LogService extends BaseService {
  LogService(PocketBase client) : super(client);

  /// Returns paginated log requests list.
  Future<ResultList<LogRequestModel>> getRequestsList({
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
          "/api/logs/requests",
          query: params,
          headers: headers,
        )
        .then((data) => ResultList<LogRequestModel>.fromJson(
              data as Map<String, dynamic>? ?? {},
              LogRequestModel.fromJson,
            ));
  }

  /// Returns a single log request by its id.
  Future<LogRequestModel> getRequest(
    String id, {
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/logs/requests/${Uri.encodeComponent(id)}",
          query: query,
          headers: headers,
        )
        .then((data) =>
            LogRequestModel.fromJson(data as Map<String, dynamic>? ?? {}));
  }

  /// Returns request logs statistics.
  Future<List<LogRequestStat>> getRequestsStats({
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) {
    return client
        .send(
          "/api/logs/requests/stats",
          query: query,
          headers: headers,
        )
        .then((data) =>
            (data as List<dynamic>?)
                ?.map((item) =>
                    LogRequestStat.fromJson(item as Map<String, dynamic>))
                .toList() ??
            []);
  }
}
