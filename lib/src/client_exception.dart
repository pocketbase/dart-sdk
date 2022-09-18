/// An exception caused by an error in the PocketBase client.
class ClientException implements Exception {
  /// The [Uri] of the failed request.
  final Uri? url;

  /// Indicates whether the error is a result from request cancellation/abort.
  final bool isAbort;

  /// The status code of the failed request.
  final int statusCode;

  /// Contains the JSON API error response.
  final Map<String, dynamic> response;

  /// The original response error (could be anything - String, Exception, etc.).
  final dynamic originalError;

  ClientException({
    this.url,
    this.isAbort = false,
    this.statusCode = 0,
    this.response = const {},
    this.originalError,
  });

  @override
  String toString() {
    final errorData = <String, dynamic>{
      "url": url,
      "isAbort": isAbort,
      "statusCode": statusCode,
      "response": response,
      "originalError": originalError,
    };

    return "ClientException: $errorData";
  }
}
