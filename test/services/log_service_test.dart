import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("LogService", () {
    test("getList()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/logs?a=1&a=2&b=%40demo&page=2&perPage=15&filter=filter%3D123&sort=sort%3D456",
        );
        expect(request.headers["test"], "789");

        return http.Response(
            jsonEncode({
              "page": 2,
              "perPage": 15,
              "totalItems": 17,
              "totalPages": 2,
              "items": [
                {"id": "1"},
                {"id": "2"},
              ],
            }),
            200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.logs.getList(
        page: 2,
        perPage: 15,
        filter: "filter=123",
        sort: "sort=456",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result.page, 2);
      expect(result.perPage, 15);
      expect(result.totalItems, 17);
      expect(result.totalPages, 2);
      expect(result.items, isA<List<LogModel>>());
      expect(result.items.length, 2);
    });

    test("getOne()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/logs/%40id123?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"id": "@id123"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.logs.getOne(
        "@id123",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<LogModel>());
      expect(result.id, "@id123");
    });

    test("getOne() with empty id", () async {
      final client = PocketBase("/base");

      await expectLater(
          client.logs.getOne(""), throwsA(isA<ClientException>()));
    });

    test("getStats()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/logs/stats?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
            jsonEncode([
              {"total": 1, "date": "2022-01-01"},
              {"total": 2, "date": "2022-01-02"},
            ]),
            200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.logs.getStats(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result.length, 2);
      expect(result[0].total, 1);
      expect(result[1].total, 2);
    });
  });
}
