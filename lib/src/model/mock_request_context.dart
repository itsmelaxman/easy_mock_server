import 'dart:io';

/// Context object shared across the request lifecycle.
///
/// Middleware can use this to inspect request details and pass metadata through
/// the [metadata] map to downstream middleware.
class MockRequestContext {
  /// Creates a request context.
  ///
  /// [request] is the incoming HTTP request.
  /// [startedAt] is the timestamp when processing began.
  MockRequestContext({
    required this.request,
    required this.startedAt,
  });

  /// The incoming HTTP request object.
  final HttpRequest request;

  /// The timestamp when this request started processing.
  final DateTime startedAt;

  /// Metadata map for sharing data between middleware.
  final Map<String, Object?> metadata = <String, Object?>{};

  /// The elapsed time since [startedAt] to now.
  Duration get elapsed => DateTime.now().difference(startedAt);
}
