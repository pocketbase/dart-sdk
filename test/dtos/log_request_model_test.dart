import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("LogRequestModel", () {
    test("fromJson() and toJson()", () {
      final json = {
        "id": "test_id",
        "created": "test_created",
        "updated": "test_updated",
        "url": "test_url",
        "method": "test_method",
        "status": 123,
        "auth": "test_auth",
        "remoteIp": "test_ip",
        "userIp": "test_ip",
        "referer": "test_referer",
        "userAgent": "test_userAgent",
        "meta": {"a": 123},
      };

      final model = LogRequestModel.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
