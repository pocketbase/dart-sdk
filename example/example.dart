// ignore_for_file: unnecessary_lambdas

import "dart:async";

import "package:pocketbase/pocketbase.dart";

void main() {
  final pb = PocketBase("http://127.0.0.1:8090");

  // fetch a paginated list with "example" records
  pb.collection("example").getList(page: 1, perPage: 50).then((result) {
    // success...
    print("Result: $result");
  }).catchError((dynamic error) {
    // error...
    print("Error: $error");
  });

  // subscribe to realtime changes in the "example" collection
  pb.collection("example").subscribe("*", (e) {
    print(e.action); // create, update, delete
    print(e.record); // the changed record
  });

  // unsubsribe from all "example" realtime subscriptions after 10 seconds
  Timer(const Duration(seconds: 300), () {
    pb.collection("example").unsubscribe();
  });
}
