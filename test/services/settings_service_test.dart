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

    test("testS3()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "filesystem": "@demo",
          }),
        );
        expect(
          request.url.toString(),
          "/base/api/settings/test/s3?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.settings.testS3(
        filesystem: "@demo",
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

    test("testEmail()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
            request.body,
            jsonEncode({
              "test_body": 123,
              "email": "test@example.com",
              "template": "test_template",
              "collection": "test_collection",
            }));
        expect(
          request.url.toString(),
          "/base/api/settings/test/email?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.settings.testEmail(
        "test@example.com",
        "test_template",
        collection: "test_collection",
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

    test("generateAppleClientSecret()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
            request.body,
            jsonEncode({
              "test_body": 123,
              "clientId": "1",
              "teamId": "2",
              "keyId": "3",
              "privateKey": "4",
              "duration": 5,
            }));
        expect(
          request.url.toString(),
          "/base/api/settings/apple/generate-client-secret?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({"secret": "test"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.settings.generateAppleClientSecret(
        "1",
        "2",
        "3",
        "4",
        5,
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
