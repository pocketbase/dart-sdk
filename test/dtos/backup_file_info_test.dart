import "package:pocketbase/pocketbase.dart";
import "package:test/test.dart";

void main() {
  group("BackupFileInfo", () {
    test("fromJson() and toJson()", () {
      final json = {
        "key": "test_key",
        "size": 100,
        "modified": "test_modified",
      };

      final model = BackupFileInfo.fromJson(json);

      expect(model.toJson(), json);
    });
  });
}
