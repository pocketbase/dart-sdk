import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("FileService", () {
    test("blank uri on missing filename", () {
      final client = PocketBase("/base/");
      final result = client.files.getURL(
        RecordModel({"id": "@r123", "collectionId": "@c123"}),
        "",
        query: {
          "demo": [1, null, "@test"],
        },
      );

      expect(result.toString(), "");
    });

    test("retrieve encoded record file url", () {
      final client = PocketBase("/base/");
      final result = client.files.getURL(
        RecordModel({"id": "@r123", "collectionId": "@c123"}),
        "@f123.png",
        query: {
          "demo": [1, null, "@test"],
        },
      );

      expect(
        result.toString(),
        "/base/api/files/%40c123/%40r123/%40f123.png?demo=1&demo=%40test",
      );
    });

    test("getToken()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
            request.body,
            jsonEncode({
              "test_body": 123,
            }));
        expect(
          request.url.toString(),
          "/base/api/files/token?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({"token": "456"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.files.getToken(
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

      expect(result, "456");
    });
  });
}
