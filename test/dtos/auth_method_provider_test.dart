import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("AuthMethodProvider", () {
    test("fromJson() and toJson()", () {
      final json = {
        "name": "test_name",
        "displayName": "test_displayName",
        "state": "test_state",
        "codeVerifier": "test_codeVerifier",
        "codeChallenge": "test_codeChallenge",
        "codeChallengeMethod": "test_codeChallengeMethod",
        "authURL": "test_authUrl",
        "pkce": null,
      };

      final model = AuthMethodProvider.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
