import "package:pocketbase/pocketbase.dart";
import "package:pocketbase/src/services/record_service.dart";
import "package:test/test.dart";

import "crud_suite.dart";

void main() {
  group("RecordService", () {
    subCrudServiceTests<RecordModel>(
      (client) => RecordService(client),
      "@test_collection",
      "collections/%40test_collection/records",
    );

    test("getFileUrl()", () {
      final client = PocketBase("/base/");
      final result = client.records.getFileUrl(
        RecordModel(id: "@r123", collectionId: "@c123"),
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
}
