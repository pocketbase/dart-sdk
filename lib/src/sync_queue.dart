typedef AsyncOperation = Future<void> Function();

/// SyncQueue is a very rudimentary queue of async operations
/// that will be processed sequential/synchronous.
class SyncQueue {
  SyncQueue({this.onComplete});

  /// Callback function that is triggered after all of the async
  /// operations are processed.
  late final void Function()? onComplete;

  // List of async operations.
  final List<AsyncOperation> _operations = [];

  /// Enqueue appends an async operation to the queue and
  /// execute it it is the only one.
  void enqueue(AsyncOperation op) {
    _operations.add(op);

    if (_operations.length == 1) {
      // start processing
      dequeue();
    }
  }

  /// Dequeue starts the queue processing.
  ///
  /// Each processed operation is removed from the queue once the
  /// it completes.
  void dequeue() {
    if (_operations.isEmpty) {
      return;
    }

    _operations.first().whenComplete(() {
      _operations.removeAt(0);

      if (_operations.isEmpty) {
        onComplete?.call();

        return; // no more operations
      }

      // proceed with the next operation from the queue
      dequeue();
    });
  }
}
