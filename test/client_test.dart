// ignore_for_file: lines_longer_than_80_chars, cascade_invocations

import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

class DummyAuthStore extends AuthStore {}

void main() {
  group("PocketBase()", () {
    test("with defaults", () {
      final client = PocketBase("https://example.com");

      expect(client.baseURL, "https://example.com");
      expect(client.lang, "en-US");
      expect(client.authStore, isA<AuthStore>());

      // services
      expect(client.collections, isA<CollectionService>());
      expect(client.realtime, isA<RealtimeService>());
      expect(client.settings, isA<SettingsService>());
      expect(client.logs, isA<LogService>());
    });

    test("with opt fields", () {
      final client = PocketBase(
        "https://example.com",
        lang: "test_lang",
        authStore: DummyAuthStore(),
      );

      expect(client.baseURL, "https://example.com");
      expect(client.lang, "test_lang");
      expect(client.authStore, isA<DummyAuthStore>());
    });
  });

  group("PocketBase.collection()", () {
    test("initializing different RecordServices", () {
      final client = PocketBase("https://example.com/");

      final service1 = client.collection("test1");
      final service2 = client.collection("@test2");
      final service3 = client.collection("test1"); // same as service1

      expect(service1.baseCrudPath, "/api/collections/test1/records");
      expect(service2.baseCrudPath, "/api/collections/%40test2/records");
      expect(service3.baseCrudPath, "/api/collections/test1/records");
    });
  });

  group("PocketBase.filter()", () {
    test("filter expression without params", () {
      final client = PocketBase("https://example.com/");
      const expr = "a > {:test1} && b = {:test2} || c = {:test2}";

      expect(client.filter(expr), expr);
    });

    test("filter expression with partial missing placeholders", () {
      final client = PocketBase("https://example.com/");
      const expr = "a > {:test1} && b = {:test2} || c = {:test2}";

      expect(
        client.filter(expr, {"test2": "hello"}),
        "a > {:test1} && b = 'hello' || c = 'hello'",
      );
    });

    test("filter expression with all placeholder types", () {
      final client = PocketBase("https://example.com/");

      final params = {
        "test1": "a'b'c'",
        "test2": null,
        "test3": true,
        "test4": false,
        "test5": 123,
        "test6": -123.45,
        "test7": 123.45,
        "test8": DateTime.utc(2023, 10, 18, 10, 11, 12),
        "test9": [1, 2, 3, "test'123"],
        "test10": {"a": "test'123"},
      };

      var expr = "";
      params.forEach((key, value) {
        if (expr.isNotEmpty) {
          expr += " || ";
        }

        expr += "$key={:$key}";
      });

      expect(
        client.filter(expr, params),
        "test1='a\\'b\\'c\\'' || test2=null || test3=true || test4=false || test5=123 || test6=-123.45 || test7=123.45 || test8='2023-10-18 10:11:12.000Z' || test9='[1,2,3,\"test\\'123\"]' || test10='{\"a\":\"test\\'123\"}'",
      );
    });
  });

  group("PocketBase.getFileUrl()", () {
    test("retrieve encoded record file url", () {
      final client = PocketBase("/base/");
      // ignore: deprecated_member_use_from_same_package
      final result = client.getFileUrl(
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
  });

  group("PocketBase.buildURL()", () {
    test("baseURL with trailing slash", () {
      final client = PocketBase("https://example.com/");

      expect(client.buildURL("test").toString(), "https://example.com/test");
      expect(client.buildURL("/test").toString(), "https://example.com/test");
    });

    test("baseURL without trailing slash", () {
      final client = PocketBase("https://example.com");

      expect(client.buildURL("test").toString(), "https://example.com/test");
      expect(client.buildURL("/test").toString(), "https://example.com/test");
    });

    test("relative baseURL", () {
      final client = PocketBase("/api");

      expect(client.buildURL("test").toString(), "/api/test");
      expect(client.buildURL("/test").toString(), "/api/test");
    });

    test("with query parameters", () {
      final client = PocketBase("https://example.com/");

      final url = client.buildURL("/test", {
        "a": null,
        "b": 123,
        "c": "123",
        "d": ["1", 2, null],
        "@encodeA": "@encodeB",
      });

      expect(
        url.toString(),
        "https://example.com/test?b=123&c=123&d=1&d=2&%40encodeA=%40encodeB",
      );
    });
  });

  group("PocketBase.send()", () {
    test("check request data (json)", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(request.url.toString(), "/base/test?a=1&a=2&c=3");
        expect(request.body, jsonEncode({"test": 123}));
        expect(request.headers, {
          "Accept-Language": "test_lang",
          "content-type": "application/json",
          "test": "123",
        });

        return http.Response("", 200);
      });

      final client = PocketBase(
        "/base",
        lang: "test_lang",
        httpClientFactory: () => mock,
      );

      await client.send(
        "/test",
        query: {
          "a": ["1", 2, null],
          "b": null,
          "c": 3,
        },
        body: {"test": 123},
        headers: {"test": "123"},
      );
    });

    test("check request data (multipart/form-data)", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(request.url.toString(), "/base/test?a=1&a=2&c=3");
        expect(request.body, contains("--dart-http-boundary"));
        expect(
          request.body,
          contains('content-disposition: form-data; name="@jsonPayload"\r\n'),
        );
        expect(
          request.body,
          contains(
            '{"a":123,"b1":["1","2"],"b2":[],"c1":[1,2],"c2":[],"d":null,"e":{"test":123}}\r\n',
          ),
        );
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_file"'),
        );
        expect(request.headers["Accept-Language"], "test_lang");
        expect(request.headers["test_header"], "123");
        expect(
          request.headers["content-type"],
          contains("multipart/form-data; boundary=dart-http-boundary-"),
        );

        return http.Response("", 200);
      });

      final client = PocketBase(
        "/base",
        lang: "test_lang",
        httpClientFactory: () => mock,
      );

      await client.send(
        "/test",
        method: "POST",
        query: {
          "a": ["1", 2, null],
          "b": null,
          "c": 3,
        },
        body: {
          "a": 123,
          "b1": ["1", "2"],
          "b2": <String>[],
          "c1": [1, 2],
          "c2": <dynamic>[],
          "d": null,
          "e": <String, dynamic>{"test": 123},
        },
        files: [http.MultipartFile.fromString("test_file", "123")],
        headers: {"test_header": "123"},
      );
    });

    test("response with status code > 400", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(request.url.toString(), "/base");
        expect(request.body, "");
        expect(request.headers, {
          "Accept-Language": "en-US",
          "content-type": "application/json",
        });

        return http.Response("", 400);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await expectLater(client.send(""), throwsA(isA<ClientException>()));
    });

    test("empty body response", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(request.url.toString(), "/base/test");
        expect(request.body, "");
        expect(request.headers, {
          "Accept-Language": "en-US",
          "Content-Type": "application/json",
        });

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      expect(await client.send("/test"), isNull);
    });

    test("json response", () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({"test": 123}),
          200,
          headers: {"content-type": "application/json"},
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.send("/test");

      expect(result, equals({"test": 123}));
    });

    test("non-json response", () async {
      final mock = MockClient((request) async {
        return http.Response(
          "test123",
          200,
          headers: {"content-type": "text/html"},
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.send("/test");

      expect(result, equals("test123"));
    });

    test("with valid record authStore model", () async {
      final mock = MockClient((request) async {
        expect(
          request.headers["Authorization"],
          contains("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."),
        );
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);
      client.authStore.save(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE4OTM0NTI0NjF9.yVr-4JxMz6qUf1MIlGx8iW2ktUrQaFecjY_TMm7Bo4o",
        RecordModel(),
      );

      await client.send("");
    });

    test("with invalid record authStore", () async {
      final mock = MockClient((request) async {
        expect(request.headers["Authorization"], isNull);
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);
      client.authStore.save(
        // expired
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDA5OTE2NjF9.TxZjXz_Ks665Hju0FkZSGqHFCYBbgBmMGOLnIzkg9Dg",
        RecordModel(),
      );

      await client.send("");
    });

    test("with custom Authorization header", () async {
      final mock = MockClient((request) async {
        expect(request.headers["Authorization"], "test_custom");
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);
      client.authStore.save(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE4OTM0NTI0NjF9.yVr-4JxMz6qUf1MIlGx8iW2ktUrQaFecjY_TMm7Bo4o",
        RecordModel(),
      );

      await client.send("", headers: {"Authorization": "test_custom"});
    });
  });

  group("HTTP client reuse", () {
    test("without reuseHTTPClient", () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({"test": 123}),
          200,
          headers: {"content-type": "application/json"},
        );
      });

      final client = PocketBase(
        "https://example.com/",
        httpClientFactory: () => mock,
      );

      expect(await client.send("/test"), equals({"test": 123}));

      // (should have no effect)
      // invoke twice to make sure that multiple calls don't throw
      client.close();
      client.close();

      expect(await client.send("/test"), equals({"test": 123}));
    });

    test("with reuseHTTPClient", () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({"test": 123}),
          200,
          headers: {"content-type": "application/json"},
        );
      });

      final client = PocketBase(
        "https://example.com/",
        httpClientFactory: () => mock,
        reuseHTTPClient: true,
      );

      expect(await client.send("/test"), equals({"test": 123}));

      // invoke twice to make sure that multiple calls don't throw
      client.close();
      client.close();

      await expectLater(client.send("/test"), throwsA(isA<ClientException>()));
    });
  });
}
