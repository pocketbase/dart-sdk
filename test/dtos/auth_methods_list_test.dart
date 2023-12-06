import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AuthMethodsList", () {
    test("fromJson() and toJson()", () {
      final json = {
        "usernamePassword": true,
        "emailPassword": true,
        "onlyVerified": true,
        "authProviders": [
          {
            "name": "test_name",
            "displayName": "test_displayName",
            "state": "test_state",
            "codeVerifier": "test_codeVerifier",
            "codeChallenge": "test_codeChallenge",
            "codeChallengeMethod": "test_codeChallengeMethod",
            "authUrl": "test_authUrl",
          },
        ],
      };

      final model = AuthMethodsList.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
