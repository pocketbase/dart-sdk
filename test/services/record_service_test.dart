import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

import "crud_suite.dart";

void main() {
  group("RecordService", () {
    crudServiceTests<RecordModel>(
      (client) => RecordService(client, "@test_collection"),
      "collections/%40test_collection/records",
    );

    test("update() with mismatched AuthStore model id", () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({"id": "test123", "test": "b"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        RecordModel({"id": "test456", "test": "a", "collectionId": "test"}),
      );

      await client.collection("test").update("test123");

      expect(client.authStore.record, isNotNull);
      expect(client.authStore.record?.data["test"], "a");
    });

    test("update() with matching AuthStore model id but mismatched collection",
        () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({"id": "test123", "test": "b"}),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        RecordModel({"id": "test123", "test": "a", "collectionId": "test2"}),
      );

      await client.collection("test").update("test123");

      expect(client.authStore.record, isNotNull);
      expect(client.authStore.record?.data["test"], "a");
    });

    test("update() with matching AuthStore model id and collection", () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "id": "test123",
            "test": "b",
            "expand": <String, dynamic>{"b": 3},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        RecordModel({
          "id": "test123",
          "collectionId": "test",
          "name": "abc",
          "expand": <String, dynamic>{"a": 1, "b": 2},
        }),
      );

      await client.collection("test").update("test123");

      expect(client.authStore.record, isNotNull);
      expect(client.authStore.record?.data["collectionId"], "test");
      expect(client.authStore.record?.data["test"], "b");
      expect(client.authStore.record?.data["expand"], {"a": 1, "b": 3});
    });

    test("delete() with matching AuthStore model id and collection", () async {
      final mock = MockClient((request) async {
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        RecordModel({"id": "test123", "collectionName": "test"}),
      );

      await client.collection("test").delete("test123");

      expect(client.authStore.record, isNull);
    });

    test("delete() with mismatched AuthStore model id", () async {
      final mock = MockClient((request) async {
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        RecordModel({"id": "test456", "collectionName": "test"}),
      );

      await client.collection("test").delete("test123");

      expect(client.authStore.record, isNotNull);
    });

    test("delete() with matching AuthStore model id but mismatched collection",
        () async {
      final mock = MockClient((request) async {
        return http.Response("", 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "test_token",
        RecordModel({"id": "test123", "collectionName": "test2"}),
      );

      await client.collection("test").delete("test123");

      expect(client.authStore.record, isNotNull);
    });

    test("listAuthMethods()", () async {
      final jsonResponse = {
        "mfa": {
          "duration": 10,
          "enabled": false,
        },
        "otp": {
          "duration": 20,
          "enabled": true,
        },
        "password": {
          "enabled": true,
          "identityFields": ["a", "b"],
        },
        "oauth2": {
          "enabled": true,
          "providers": [
            AuthMethodProvider(name: "test1").toJson(),
            AuthMethodProvider(name: "test2").toJson(),
          ],
        },
      };

      final mock = MockClient((request) async {
        expect(request.method, "GET");
        expect(
          request.url.toString(),
          "/base/api/collections/test/auth-methods?a=1&a=2&b=%40demo&fields=mfa%2Cotp%2Cpassword%2Coauth2",
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode(jsonResponse), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.collection("test").listAuthMethods(
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        headers: {
          "test": "789",
        },
      );

      expect(result.toJson(), jsonResponse);
    });

    test("authWithPassword()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/auth-with-password?a=1&a=2&b=%40demo&expand=rel&fields=a",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "identity": "test_identity",
            "password": "test_password",
          }),
        );
        expect(request.headers["test"], "789");
        expect(request.headers["Authorization"], "test");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "record": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.collection("test").authWithPassword(
        "test_identity",
        "test_password",
        expand: "rel",
        fields: "a",
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
      expect(result.record.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.record?.id, "test_id");
    });

    test("authWithOAuth2Code()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/auth-with-oauth2?a=1&a=2&b=%40demo&expand=rel&fields=a",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "codeVerifier": "customCodeVerifier",
            "provider": "test_provider",
            "code": "test_code",
            "redirectURL": "test_redirect_url",
            "createData": {"c": 456},
          }),
        );
        expect(request.headers["test"], "789");
        expect(request.headers["Authorization"], "test_auth");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "record": {"id": "test_id"},
            "meta": {"a": 123},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.collection("test").authWithOAuth2Code(
        "test_provider",
        "test_code",
        "test_code_verifier",
        "test_redirect_url",
        expand: "rel",
        fields: "a",
        createData: {"c": 456},
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
          "codeVerifier": "customCodeVerifier",
        },
        headers: {
          "test": "789",
          "Authorization": "test_auth",
        },
      );

      expect(result.token, "test_token");
      expect(result.record.id, "test_id");
      expect(result.meta, equals({"a": 123}));
      expect(client.authStore.token, "test_token");
      expect(client.authStore.record?.id, "test_id");
    });

    test("authRefresh()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/auth-refresh?a=1&a=2&b=%40demo&expand=rel&fields=a",
        );
        expect(request.body, jsonEncode({"test_body": 123}));
        expect(request.headers["test"], "789");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "record": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.collection("test").authRefresh(
        expand: "rel",
        fields: "a",
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
      expect(result.record.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.record?.id, "test_id");
    });

    test("requestPasswordReset()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/request-password-reset?a=1&a=2&b=%40demo",
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

      await client.collection("test").requestPasswordReset(
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
          "/base/api/collections/test/confirm-password-reset?a=1&a=2&b=%40demo",
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

      await client.collection("test").confirmPasswordReset(
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

    test("requestVerification()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/request-verification?a=1&a=2&b=%40demo",
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

      await client.collection("test").requestVerification(
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

    test("confirmVerification() with matching AuthStore model id", () async {
      const token =
          // ignore: lines_longer_than_80_chars
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsInR5cGUiOiJhdXRoUmVjb3JkIiwiY29sbGVjdGlvbklkIjoiNDU2In0.c9ZkXkC8rSqkKlpyx3kXt9ID3qYsIoy1Vz3a2m3ly0c";

      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/confirm-verification?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "token": token,
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "auth_token",
        RecordModel({"id": "123", "collectionId": "456"}),
      );

      await client.collection("test").confirmVerification(
        token,
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

      expect((client.authStore.record as RecordModel).data["verified"], true);
    });

    test("confirmVerification() with mismatched AuthStore model id", () async {
      const token =
          // ignore: lines_longer_than_80_chars
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsInR5cGUiOiJhdXRoUmVjb3JkIiwiY29sbGVjdGlvbklkIjoiNDU2In0.c9ZkXkC8rSqkKlpyx3kXt9ID3qYsIoy1Vz3a2m3ly0c";

      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/confirm-verification?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "token": token,
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "auth_token",
        RecordModel({"id": "123", "collectionId": "789"}),
      );

      await client.collection("test").confirmVerification(
        token,
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
      expect((client.authStore.record as RecordModel).data["verified"], null);
    });

    test("requestEmailChange()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/request-email-change?a=1&a=2&b=%40demo",
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

      await client.collection("test").requestEmailChange(
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

    test("confirmEmailChange() with matching AuthStore model id", () async {
      const token =
          // ignore: lines_longer_than_80_chars
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsInR5cGUiOiJhdXRoUmVjb3JkIiwiY29sbGVjdGlvbklkIjoiNDU2In0.c9ZkXkC8rSqkKlpyx3kXt9ID3qYsIoy1Vz3a2m3ly0c";

      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/confirm-email-change?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "token": token,
            "password": "test_password",
          }),
        );
        expect(request.headers["test"], "456");

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "auth_token",
        RecordModel({"id": "123", "collectionId": "456"}),
      );

      await client.collection("test").confirmEmailChange(
        token,
        "test_password",
        query: {
          "a": ["1", null, 2],
          "b": "@demo",
        },
        body: {
          "test_body": 123,
        },
        headers: {
          "test": "456",
        },
      );

      expect(client.authStore.token, "");
    });

    test("confirmEmailChange() with mismatched AuthStore model id", () async {
      const token =
          // ignore: lines_longer_than_80_chars
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsInR5cGUiOiJhdXRoUmVjb3JkIiwiY29sbGVjdGlvbklkIjoiNDU2In0.c9ZkXkC8rSqkKlpyx3kXt9ID3qYsIoy1Vz3a2m3ly0c";

      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/confirm-email-change",
        );
        expect(
          request.body,
          jsonEncode({
            "token": token,
            "password": "test_password",
          }),
        );

        return http.Response("", 204);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save(
        "auth_token",
        RecordModel({"id": "123", "collectionId": "789"}),
      );

      await client
          .collection("test")
          .confirmEmailChange(token, "test_password");

      expect(client.authStore.token, "auth_token");
    });

    test("requestOTP()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/request-otp?a=1&a=2&b=%40demo",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "email": "test_email",
          }),
        );
        expect(request.headers["test"], "789");

        return http.Response(jsonEncode({"otpId": "test_id"}), 200);
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.collection("test").requestOTP(
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

      expect(result.otpId, "test_id");
    });

    test("authWithOTP()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/auth-with-otp?a=1&a=2&b=%40demo&expand=rel&fields=a",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "otpId": "test_id",
            "password": "test_password",
          }),
        );
        expect(request.headers["test"], "789");
        expect(request.headers["Authorization"], "test");

        return http.Response(
          jsonEncode({
            "token": "test_token",
            "record": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      final result = await client.collection("test").authWithOTP(
        "test_id",
        "test_password",
        expand: "rel",
        fields: "a",
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
      expect(result.record.id, "test_id");
      expect(client.authStore.token, "test_token");
      expect(client.authStore.record?.id, "test_id");
    });

    test("impersonate()", () async {
      final mock = MockClient((request) async {
        expect(request.method, "POST");
        expect(
          request.url.toString(),
          "/base/api/collections/test/impersonate/%40test_record?a=1&a=2&b=%40demo&expand=rel&fields=a",
        );
        expect(
          request.body,
          jsonEncode({
            "test_body": 123,
            "duration": 456,
          }),
        );
        expect(request.headers["test"], "789");
        expect(request.headers["Authorization"], "test_token1");

        return http.Response(
          jsonEncode({
            "token": "test_token2",
            "record": {"id": "test_id"},
          }),
          200,
        );
      });

      final client = PocketBase("/base", httpClientFactory: () => mock);

      client.authStore.save("test_token1", null);

      final result = await client.collection("test").impersonate(
        "@test_record",
        456,
        expand: "rel",
        fields: "a",
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

      expect(client.authStore.token, "test_token1");
      expect(result.authStore.token, "test_token2");
      expect(result.authStore.record?.id, "test_id");
    });
  });
}
