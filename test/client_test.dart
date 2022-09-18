// ignore_for_file: lines_longer_than_80_chars

import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:pocketbase/src/services/admin_service.dart";
import "package:pocketbase/src/services/collection_service.dart";
import "package:pocketbase/src/services/log_service.dart";
import "package:pocketbase/src/services/realtime_service.dart";
import "package:pocketbase/src/services/record_service.dart";
import "package:pocketbase/src/services/settings_service.dart";
import "package:pocketbase/src/services/user_service.dart";
import "package:test/test.dart";

class DummyAuthStore extends AuthStore {}

void main() {
  group("PocketBase()", () {
    test("with defaults", () {
      final client = PocketBase("https://example.com");

      expect(client.baseUrl, "https://example.com");
      expect(client.lang, "en-US");
      expect(client.authStore, isA<AuthStore>());

      // services
      expect(client.admins, isA<AdminService>());
      expect(client.users, isA<UserService>());
      expect(client.collections, isA<CollectionService>());
      expect(client.records, isA<RecordService>());
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

      expect(client.baseUrl, "https://example.com");
      expect(client.lang, "test_lang");
      expect(client.authStore, isA<DummyAuthStore>());
    });
  });

  group("PocketBase.buildUrl()", () {
    test("baseUrl with trailing slash", () {
      final client = PocketBase("https://example.com/");

      expect(client.buildUrl("test").toString(), "https://example.com/test");
      expect(client.buildUrl("/test").toString(), "https://example.com/test");
    });

    test("baseUrl without trailing slash", () {
      final client = PocketBase("https://example.com");

      expect(client.buildUrl("test").toString(), "https://example.com/test");
      expect(client.buildUrl("/test").toString(), "https://example.com/test");
    });

    test("relative baseUrl", () {
      final client = PocketBase("/api");

      expect(client.buildUrl("test").toString(), "/api/test");
      expect(client.buildUrl("/test").toString(), "/api/test");
    });

    test("with query parameters", () {
      final client = PocketBase("https://example.com/");

      final url = client.buildUrl("/test", {
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
        expect(request.body, contains("--dart-http-boundar"));
        expect(
          request.body,
          contains('content-disposition: form-data; name="test_body"'),
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
        body: {"test_body": 123},
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

    test("with valid user authStore model", () async {
      final mock = MockClient((request) async {
        expect(
          request.headers["Authorization"],
          contains("User eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."),
        );
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);
      client.authStore.save(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE4OTM0NTI0NjF9.yVr-4JxMz6qUf1MIlGx8iW2ktUrQaFecjY_TMm7Bo4o",
        UserModel(),
      );

      await client.send("");
    });

    test("with invalid user authStore", () async {
      final mock = MockClient((request) async {
        expect(request.headers["Authorization"], isNull);
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);
      client.authStore.save(
        // expired
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDA5OTE2NjF9.TxZjXz_Ks665Hju0FkZSGqHFCYBbgBmMGOLnIzkg9Dg",
        UserModel(),
      );

      await client.send("");
    });

    test("with valid admin authStore model", () async {
      final mock = MockClient((request) async {
        expect(
          request.headers["Authorization"],
          contains("Admin eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."),
        );
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);
      client.authStore.save(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE4OTM0NTI0NjF9.yVr-4JxMz6qUf1MIlGx8iW2ktUrQaFecjY_TMm7Bo4o",
        AdminModel(),
      );

      await client.send("");
    });

    test("with invalid admin authStore", () async {
      final mock = MockClient((request) async {
        expect(request.headers["Authorization"], isNull);
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);
      client.authStore.save(
        // expired
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDA5OTE2NjF9.TxZjXz_Ks665Hju0FkZSGqHFCYBbgBmMGOLnIzkg9Dg",
        AdminModel(),
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
        AdminModel(),
      );

      await client.send("", headers: {"Authorization": "test_custom"});
    });
  });
}
