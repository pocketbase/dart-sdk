import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("OTPResponse", () {
    test("fromJson() and toJson()", () {
      final json = {
        "otpId": "test",
      };

      final model = OTPResponse.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
