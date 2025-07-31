import "dart:async";

/// A token that can be used to signal cancellation to HTTP requests.
/// 
/// Similar to JavaScript's AbortController, this allows cancelling
/// ongoing HTTP requests.
class CancelToken {
  final Completer<void> _completer = Completer<void>();
  bool _isCancelled = false;
  String? _reason;

  /// Creates a new [CancelToken].
  CancelToken();

  /// Whether this token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// The reason for cancellation, if any.
  String? get reason => _reason;

  /// A future that completes when this token is cancelled.
  Future<void> get whenCancelled => _completer.future;

  /// Cancels this token with an optional reason.
  /// 
  /// Once cancelled, this token cannot be reused.
  void cancel([String? reason]) {
    if (_isCancelled) {
      return;
    }

    _isCancelled = true;
    _reason = reason ?? "Request was cancelled";

    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  /// Throws a [CancellationException] if this token is cancelled.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancellationException(_reason ?? "Request was cancelled");
    }
  }

  /// Returns a new [CancelToken] that will be cancelled when either
  /// this token or the [other] token is cancelled.
  CancelToken combine(CancelToken other) {
    final combined = CancelToken();

    void cancelCombined(String? reason) {
      if (!combined.isCancelled) {
        combined.cancel(reason);
      }
    }

    if (isCancelled) {
      cancelCombined(_reason);
    } else if (other.isCancelled) {
      cancelCombined(other._reason);
    } else {
      whenCancelled.then((_) => cancelCombined(_reason));
      other.whenCancelled.then((_) => cancelCombined(other._reason));
    }

    return combined;
  }
}

/// Exception thrown when a request is cancelled.
class CancellationException implements Exception {
  /// The reason for cancellation.
  final String message;

  const CancellationException(this.message);

  @override
  String toString() => "CancellationException: $message";
}
