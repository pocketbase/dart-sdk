import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("CronService", () {
    test("getFullList()", () async {
      final expectedResult = [CronJob(id: "k1"), CronJob(id: "k2")];

      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/crons?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode(expectedResult), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.crons.getFullList(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<List<CronJob>>());
      expect(result.length, expectedResult.length);
      expect(result[0].id, expectedResult[0].id);
      expect(result[1].id, expectedResult[1].id);
    });

    test("run()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(request.body, jsonEncode({"test_body": 123}));
        expect(
          request.url.toString(),
          "/base/api/crons/%40test_id?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.crons.run(
        "@test_id",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        headers: {
          "test": "789",
        },
      );
    });
  });
}
