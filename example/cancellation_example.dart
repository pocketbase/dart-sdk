// Example demonstrating request cancellation/abort feature in PocketBase Dart SDK

import "package:pocketbase/pocketbase.dart";

void main() async {
  final pb = PocketBase("http://127.0.0.1:8090");

  // Example 1: Manual cancellation with CancelToken
  print("Example 1: Manual cancellation");
  final cancelToken = CancelToken();
  
  // Start a request
  final future = pb.collection("posts").getList(cancelToken: cancelToken);
  
  // Cancel it after 100ms
  Future.delayed(const Duration(milliseconds: 100), () {
    cancelToken.cancel("User cancelled the request");
  });
  
  try {
    await future;
    print("Request completed");
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      print("Request was cancelled: ${e.originalError}");
    }
  }

  // Example 2: Auto-cancellation of duplicate requests
  print("\nExample 2: Auto-cancellation");
  
  // These requests will auto-cancel each other
  final request1 = pb.collection("posts").getList(); // Will be cancelled
  final request2 = pb.collection("posts").getList(); // Will be cancelled  
  final request3 = pb.collection("posts").getList(); // Will execute
  
  try {
    await request1;
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      print("Request 1 was auto-cancelled");
    }
  }
  
  try {
    await request2;
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      print("Request 2 was auto-cancelled");
    }
  }
  
  try {
    final result = await request3;
    print("Request 3 completed with ${result.items.length} items");
  } catch (e) {
    print("Request 3 failed: $e");
  }

  // Example 3: Disable auto-cancellation
  print("\nExample 3: Disable auto-cancellation");
  
  // Disable auto-cancellation globally
  pb.autoCancellation(false);
  
  // These requests will all execute
  final req1 = pb.collection("posts").getList();
  final req2 = pb.collection("posts").getList();
  
  try {
    final results = await Future.wait([req1, req2]);
    print("Both requests completed: ${results.length} results");
  } catch (e) {
    print("Requests failed: $e");
  }

  // Example 4: Disable auto-cancellation per request
  print("\nExample 4: Disable auto-cancellation per request");
  
  // Re-enable auto-cancellation globally
  pb.autoCancellation(true);
  
  // Use requestKey: null to disable auto-cancellation for specific requests
  final reqA = pb.collection("posts").getList(requestKey: null);
  final reqB = pb.collection("posts").getList(requestKey: null);
  
  try {
    final results = await Future.wait([reqA, reqB]);
    print("Both requests completed without cancellation: "
        "${results.length} results");
  } catch (e) {
    print("Requests failed: $e");
  }

  // Example 5: Custom request keys
  print("\nExample 5: Custom request keys");
  
  // Use custom keys for different types of operations
  final searchReq1 = pb.collection("posts").getList(requestKey: "search");
  final searchReq2 = pb.collection("posts").getList(
      requestKey: "search"); // Will cancel searchReq1
  final loadReq = pb.collection("users").getList(
      requestKey: "load"); // Different key, won't be cancelled
  
  try {
    await searchReq1;
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      print("Search request 1 was cancelled");
    }
  }
  
  try {
    final results = await Future.wait([searchReq2, loadReq]);
    print("Search 2 and load completed: ${results.length} results");
  } catch (e) {
    print("Requests failed: $e");
  }

  // Example 6: Manual request cancellation
  print("\nExample 6: Manual request cancellation");
  
  // Start multiple requests with custom keys
  final task1 = pb.collection("posts").getList(requestKey: "task1");
  final task2 = pb.collection("users").getList(requestKey: "task2");
  
  // Cancel specific request
  pb.cancelRequest("task1");
  
  try {
    await task1;
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      print("Task 1 was manually cancelled");
    }
  }
  
  try {
    final result = await task2;
    print("Task 2 completed with ${result.items.length} items");
  } catch (e) {
    print("Task 2 failed: $e");
  }

  // Example 7: Cancel all requests
  print("\nExample 7: Cancel all requests");
  
  // Start multiple requests
  final batchReq1 = pb.collection("posts").getList(requestKey: "batch1");
  final batchReq2 = pb.collection("users").getList(requestKey: "batch2");
  final batchReq3 = pb.collection("categories").getList(requestKey: "batch3");
  
  // Cancel all pending requests
  pb.cancelAllRequests();
  
  // Check which requests were cancelled
  final results = <String>[];
  
  try {
    await batchReq1;
    results.add("batch1: completed");
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      results.add("batch1: cancelled");
    } else {
      results.add("batch1: failed");
    }
  }
  
  try {
    await batchReq2;
    results.add("batch2: completed");
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      results.add("batch2: cancelled");
    } else {
      results.add("batch2: failed");
    }
  }
  
  try {
    await batchReq3;
    results.add("batch3: completed");
  } catch (e) {
    if (e is ClientException && e.isAbort) {
      results.add("batch3: cancelled");
    } else {
      results.add("batch3: failed");
    }
  }
  
  print("Batch results: $results");
}
