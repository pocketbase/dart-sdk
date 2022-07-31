import "package:pocketbase/pocketbase.dart";
import "package:pocketbase/src/services/collection_service.dart";
import "package:test/test.dart";

import "crud_suite.dart";

void main() {
  group("CollectionService", () {
    crudServiceTests<CollectionModel>(
      (client) => CollectionService(client),
      "collections",
    );
  });
}
