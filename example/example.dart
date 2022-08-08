// ignore_for_file: unnecessary_lambdas

import "dart:async";

import "package:pocketbase/pocketbase.dart";

void main() {
  final client = PocketBase("http://127.0.0.1:8090");

  final importData = [
    CollectionModel(
      name: "collection1",
      schema: [
        SchemaField(name: "status", type: "bool"),
      ],
    ),
    CollectionModel(
      name: "collection2",
      schema: [
        SchemaField(name: "title", type: "text"),
      ],
    ),
  ];

  // fetch a paginated list with "example" records
  client.records.getList("example", page: 1, perPage: 50).then((result) {
    // success...
    print("Result: $result");
  }).catchError((dynamic error) {
    // error...
    print("Error: $error");
  });

  // subscribe to realtime changes in the "example" collection
  client.realtime.subscribe("example", (e) {
    print(e.action); // create, update, delete
    print(e.record); // the changed record
  });

  // unsubsribe from all realtime subscriptions after 10 seconds
  Timer(const Duration(seconds: 10), () {
    client.realtime.unsubscribe();
  });
}
