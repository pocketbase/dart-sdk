import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("BackupService", () {
    test("getFullList()", () async {
      final expectedResult = [
        BackupFileInfo(key: "k1"),
        BackupFileInfo(key: "k2")
      ];

      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/backups?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode(expectedResult), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.backups.getFullList(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<List<BackupFileInfo>>());
      expect(result.length, expectedResult.length);
      expect(result[0].key, expectedResult[0].key);
      expect(result[1].key, expectedResult[1].key);
    });

    test("create()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
            request.body, jsonEncode({"test_body": 123, "name": "test_name"}));
        expect(
          request.url.toString(),
          "/base/api/backups?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.backups.create(
        "test_name",
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

    test("upload()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(request.body, contains("content-disposition: form-data;"));
        expect(request.body, contains('name="@jsonPayload"'));
        expect(request.body, contains('{"test_body":123}\r\n'));
        expect(request.body, contains('form-data; name="file"'));
        expect(
          request.url.toString(),
          "/base/api/backups/upload?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.backups.upload(
        http.MultipartFile.fromBytes("file", []),
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

    test("restore()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(request.body, jsonEncode({"test_body": 123}));
        expect(
          request.url.toString(),
          "/base/api/backups/%40test_name/restore?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.backups.restore(
        "@test_name",
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

    test("getDownloadURL()", () async {
      final client = PocketBase("/base");

      final url = client.backups.getDownloadURL(
        "@test_token",
        "@test_name",
        query: {
          "demo": [1, null, "@test"],
        },
      );

      expect(
        url.toString(),
        "/base/api/backups/%40test_name?demo=1&demo=%40test&token=%40test_token",
      );
    });
  });
}
