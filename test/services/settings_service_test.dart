import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("SettingsService", () {
    test("getAll()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/settings?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({"a": 1, "b": false, "c": "test"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.settings.getAll(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(
        result,
        equals({"a": 1, "b": false, "c": "test"}),
      );
    });

    test("update()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "PATCH");
        expect(request.body, jsonEncode({"test_body": 123}));
        expect(
          request.url.toString(),
          "/base/api/settings?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({"a": 1, "b": false, "c": "test"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.settings.update(
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

      expect(
        result,
        equals({"a": 1, "b": false, "c": "test"}),
      );
    });
  });
}
