import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

import "crud_suite.dart";

void main() {
  group("AdminService", () {
    crudServiceTests<AdminModel>(
      (client) => AdminService(client),
      "admins",
    );

    test("update() with matching AuthStore model", () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({"id": "test123", "email": "test2@example.com"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        AdminModel(id: "test123", email: "test1@example.com"),
      );

      await client.admins.update("test123", body: {
        "email": "test2@example.com",
      });

      expect(client.authStore.model, isNotNull);
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.email, "test2@example.com");
    });

    test("update() with matched AuthStore model", () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({"id": "test123", "email": "test2@example.com"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        AdminModel(id: "test456", email: "test1@example.com"),
      );

      await client.admins.update("test123", body: {
        "email": "test2@example.com",
      });

      expect(client.authStore.model, isNotNull);
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.email, "test1@example.com");
    });

    test("delete() with matching AuthStore model", () async {
      final mock = MockClient((request) async {
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save("test_token", AdminModel(id: "test123"));

      await client.admins.delete("test123");

      expect(client.authStore.model, isNull);
    });

    test("delete() with mismatched AuthStore model", () async {
      final mock = MockClient((request) async {
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save("test_token", AdminModel(id: "test456"));

      await client.admins.delete("test123");

      expect(client.authStore.model, isNotNull);
    });

    test("authWithPassword()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/admins/auth-with-password?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "identity": "test_email",
            "password": "test_password",
          }),
        );
        expect(request.headers["test"], "789");
        expect(request.headers["Authorization"], "test");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "admin": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.admins.authWithPassword(
        "test_email",
        "test_password",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        headers: {
          "test": "789",
          "Authorization": "test",
        },
      );

      expect(result.token, "test_token");
      expect(result.admin?.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<AdminModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });

    test("refresh()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/admins/auth-refresh?a=1&a=2&b=%40demo",
        );
        expect(request.body, jsonEncode({"test_body": 123}));
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "admin": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.admins.refresh(
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

      expect(result.token, "test_token");
      expect(result.admin?.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<AdminModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });

    test("requestPasswordReset()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/admins/request-password-reset?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "email": "test_email",
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.admins.requestPasswordReset(
        "test_email",
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

    test("confirmPasswordReset()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/admins/confirm-password-reset?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "token": "test_token",
            "password": "test_password",
            "passwordConfirm": "test_password_confirm",
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.admins.confirmPasswordReset(
        "test_token",
        "test_password",
        "test_password_confirm",
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
