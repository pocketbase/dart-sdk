import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

import "crud_suite.dart";

void main() {
  group("CollectionService", () {
    crudServiceTests<CollectionModel>(
      CollectionService.new,
      "collections",
    );

    test("import()", () async {
      final collections = [
        CollectionModel(id: "id1"),
        CollectionModel(id: "id2"),
      ];

      final mock = MockClient((request) async {
        expect(request.method, "PUT");
        expect(
            request.body,
            jsonEncode({
              "test_body": 123,
              "collections": collections,
              "deleteMissing": true,
            }));
        expect(
          request.url.toString(),
          "/base/api/collections/import?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({"a": 1, "b": false, "c": "test"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.collections.import(
        collections,
        deleteMissing: true,
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

    test("getScaffolds()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(request.body, jsonEncode({"test_body": 123}));
        expect(
          request.url.toString(),
          "/base/api/collections/meta/scaffolds?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({
            "test1": CollectionModel(id: "id1").toJson(),
            "test2": CollectionModel(id: "id2").toJson(),
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.collections.getScaffolds(
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

      expect(result.length, 2);
      expect(result["test1"]?.id, "id1");
      expect(result["test2"]?.id, "id2");
    });
  });

  test("truncate()", () async {
    final mock = MockClient((request) async {
      expect(request.method, "DELETE");
      expect(request.body, jsonEncode({"test_body": 123}));
      expect(
        request.url.toString(),
        "/base/api/collections/test%3D/truncate?a=1&a=2&b=%40demo",
      );
      expect(request.headers["test"], "789");

      return http.Response(
        jsonEncode({"a": 1, "b": false, "c": "test"}),
        200,
      );
    });

    final client = PocketBase("/base", httpClientFactory: () => mock);

    await client.collections.truncate(
      "test=",
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
}
