// ignore_for_file: lines_longer_than_80_chars

import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void crudServiceTests<M extends Jsonable>(
  CrudService<M> Function(PocketBase client) serviceFactory,
  String expectedPath,
) {
  group("CrudService", () {
    test("getFullList()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(request.headers["test"], "789");

        // page1
        if (request.url.queryParameters["page"] == "1") {
          expect(
            request.url.toString(),
            "/base/api/$expectedPath?a=1&a=2&b=%40demo&page=1&perPage=2&filter=filter%3D123&sort=sort%3D456",
          );

          return http.Response(
            jsonEncode({
              "page": 1,
              "perPage": 2,
              "totalItems": 3,
              "totalPages": 2,
              "items": [
                {"id": "1"},
                {"id": "2"},
              ],
            }),
            200,
          );
        }

        // page2
        expect(
          request.url.toString(),
          "/base/api/$expectedPath?a=1&a=2&b=%40demo&page=2&perPage=2&filter=filter%3D123&sort=sort%3D456",
        );

        return http.Response(
          jsonEncode({
            "page": 2,
            "perPage": 2,
            "totalItems": 3,
            "totalPages": 2,
            "items": [
              {"id": "3"},
            ],
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).getFullList(
        batch: 2,
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

      expect(result, isA<List<M>>());
      expect(result.length, 3);
    });

    test("getList()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/$expectedPath?a=1&a=2&b=%40demo&page=2&perPage=15&filter=filter%3D123&sort=sort%3D456",
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

      final result = await serviceFactory(client).getList(
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
      expect(result.items, isA<List<M>>());
      expect(result.items.length, 2);
    });

    test("getOne()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/$expectedPath/%40id123?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"id": "@id123"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).getOne(
        "@id123",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<M>());
      // ignore: avoid_dynamic_calls
      expect((result as dynamic).id, "@id123");
    });

    test("create()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(request.body, contains("--dart-http-boundar"));
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_body"'),
        );
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_file"'),
        );
        expect(
          request.url.toString(),
          "/base/api/$expectedPath?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"id": "@id123"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).create(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        files: [http.MultipartFile.fromString("test_file", "456")],
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<M>());
      // ignore: avoid_dynamic_calls
      expect((result as dynamic).id, "@id123");
    });

    test("update()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "PATCH");
        expect(request.body, contains("--dart-http-boundar"));
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_body"'),
        );
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_file"'),
        );
        expect(
          request.url.toString(),
          "/base/api/$expectedPath/%40id123?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"id": "@id123"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).update(
        "@id123",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        files: [http.MultipartFile.fromString("test_file", "456")],
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<M>());
      // ignore: avoid_dynamic_calls
      expect((result as dynamic).id, "@id123");
    });

    test("getOne()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "DELETE");
        expect(
          request.url.toString(),
          "/base/api/$expectedPath/%40id123?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");
        expect(request.headers["content-type"], "application/json");
        expect(request.body, jsonEncode({"test": 123}));

        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await serviceFactory(client).delete(
        "@id123",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test": 123,
        },
        headers: {
          "test": "789",
        },
      );
    });
  });
}

void subCrudServiceTests<M extends Jsonable>(
  SubCrudService<M> Function(PocketBase client) serviceFactory,
  String sub,
  String expectedPath,
) {
  group("SubCrudService", () {
    test("getFullList()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(request.headers["test"], "789");

        // page1
        if (request.url.queryParameters["page"] == "1") {
          expect(
            request.url.toString(),
            "/base/api/$expectedPath?a=1&a=2&b=%40demo&page=1&perPage=2&filter=filter%3D123&sort=sort%3D456",
          );

          return http.Response(
            jsonEncode({
              "page": 1,
              "perPage": 2,
              "totalItems": 3,
              "totalPages": 2,
              "items": [
                {"id": "1"},
                {"id": "2"},
              ],
            }),
            200,
          );
        }

        // page2
        expect(
          request.url.toString(),
          "/base/api/$expectedPath?a=1&a=2&b=%40demo&page=2&perPage=2&filter=filter%3D123&sort=sort%3D456",
        );

        return http.Response(
          jsonEncode({
            "page": 2,
            "perPage": 2,
            "totalItems": 3,
            "totalPages": 2,
            "items": [
              {"id": "3"},
            ],
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).getFullList(
        sub,
        batch: 2,
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

      expect(result, isA<List<M>>());
      expect(result.length, 3);
    });

    test("getList()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/$expectedPath?a=1&a=2&b=%40demo&page=2&perPage=15&filter=filter%3D123&sort=sort%3D456",
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

      final result = await serviceFactory(client).getList(
        sub,
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
      expect(result.items, isA<List<M>>());
      expect(result.items.length, 2);
    });

    test("getOne()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/$expectedPath/%40id123?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"id": "@id123"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).getOne(
        sub,
        "@id123",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<M>());
      // ignore: avoid_dynamic_calls
      expect((result as dynamic).id, "@id123");
    });

    test("create()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(request.body, contains("--dart-http-boundar"));
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_body"'),
        );
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_file"'),
        );
        expect(
          request.url.toString(),
          "/base/api/$expectedPath?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"id": "@id123"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).create(
        sub,
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        files: [http.MultipartFile.fromString("test_file", "456")],
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<M>());
      // ignore: avoid_dynamic_calls
      expect((result as dynamic).id, "@id123");
    });

    test("update()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "PATCH");
        expect(request.body, contains("--dart-http-boundar"));
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_body"'),
        );
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_file"'),
        );
        expect(
          request.url.toString(),
          "/base/api/$expectedPath/%40id123?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"id": "@id123"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await serviceFactory(client).update(
        sub,
        "@id123",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        files: [http.MultipartFile.fromString("test_file", "456")],
        headers: {
          "test": "789",
        },
      );

      expect(result, isA<M>());
      // ignore: avoid_dynamic_calls
      expect((result as dynamic).id, "@id123");
    });

    test("getOne()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "DELETE");
        expect(
          request.url.toString(),
          "/base/api/$expectedPath/%40id123?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");
        expect(request.headers["content-type"], "application/json");
        expect(request.body, jsonEncode({"test": 123}));

        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await serviceFactory(client).delete(
        sub,
        "@id123",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test": 123,
        },
        headers: {
          "test": "789",
        },
      );
    });
  });
}
