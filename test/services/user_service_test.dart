import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:pocketbase/src/services/user_service.dart";
import "package:test/test.dart";

import "crud_suite.dart";

void main() {
  group("AdminService", () {
    crudServiceTests<UserModel>(
      (client) => UserService(client),
      "users",
    );

    test("listAuthMethods()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/users/auth-methods?a=1&a=2&b=%40demo",
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({
            "emailPassword": true,
            "authProviders": [
              {"name": "p1"},
              {"name": "p2"},
            ],
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.users.listAuthMethods(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result.emailPassword, true);
      expect(result.authProviders.length, 2);
      expect(result.authProviders[0].name, "p1");
      expect(result.authProviders[1].name, "p2");
    });

    test("authViaEmail()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/auth-via-email?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "email": "test_email",
            "password": "test_password",
          }),
        );
        expect(request.headers["test"], "789");
        expect(request.headers["Authorization"], "");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "user": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.users.authViaEmail(
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
          "Authorization": "test", // should be ignored
        },
      );

      expect(result.token, "test_token");
      expect(result.user?.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<UserModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });

    test("authViaOAuth2()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/auth-via-oauth2?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "provider": "test_provider",
            "code": "test_code",
            "codeVerifier": "test_code_verifier",
            "redirectUrl": "test_redirect_url",
          }),
        );
        expect(request.headers["test"], "789");
        expect(request.headers["Authorization"], "");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "user": {"id": "test_id"},
            "meta": {"a": 123},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.users.authViaOAuth2(
        "test_provider",
        "test_code",
        "test_code_verifier",
        "test_redirect_url",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        headers: {
          "test": "789",
          "Authorization": "test", // should be ignored
        },
      );

      expect(result.token, "test_token");
      expect(result.user?.id, "test_id");
      expect(result.meta, equals({"a": 123}));
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<UserModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });

    test("refresh()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/refresh?a=1&a=2&b=%40demo",
        );
        expect(request.body, jsonEncode({"test_body": 123}));
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "user": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.users.refresh(
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
      expect(result.user?.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<UserModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });

    test("requestPasswordReset()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/request-password-reset?a=1&a=2&b=%40demo",
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

      await client.users.requestPasswordReset(
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
          "/base/api/users/confirm-password-reset?a=1&a=2&b=%40demo",
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

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "user": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.users.confirmPasswordReset(
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

      expect(result.token, "test_token");
      expect(result.user?.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<UserModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });

    test("requestVerification()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/request-verification?a=1&a=2&b=%40demo",
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

      await client.users.requestVerification(
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

    test("confirmVerification()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/confirm-verification?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "token": "test_token",
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "user": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.users.confirmVerification(
        "test_token",
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
      expect(result.user?.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<UserModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });

    test("requestEmailChange()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/request-email-change?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "newEmail": "test_email",
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      await client.users.requestEmailChange(
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

    test("confirmEmailChange()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/users/confirm-email-change?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "token": "test_token",
            "password": "test_password",
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "user": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.users.confirmEmailChange(
        "test_token",
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
        },
      );

      expect(result.token, "test_token");
      expect(result.user?.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.model, isA<UserModel>());
      // ignore: avoid_dynamic_calls
      expect(client.authStore.model.id, "test_id");
    });
  });
}
