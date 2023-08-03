import "package:pocketbase/src/sync_queue.dart";
import "package:test/test.dart";

void main() {
  group("SyncQueue()", () {
    test("async operations order", () async {
      var output = "";

      final queue = SyncQueue(onComplete: () {
        expect(output, "abc");
      });

      // ignore: cascade_invocations
      queue
        ..enqueue(() async {
          // ignore: inference_failure_on_instance_creation
          await Future.delayed(const Duration(milliseconds: 5));

          output += "a";
        })
        ..enqueue(() async {
          output += "b";
        })
        ..enqueue(() async {
          output += "c";
        });
    });
  });
}
