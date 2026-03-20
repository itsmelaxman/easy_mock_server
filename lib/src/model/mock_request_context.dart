import 'dart:io';

/// Context object shared across the request lifecycle.
///
/// Middleware can use this to inspect request details and pass metadata through
/// the [metadata] map to downstream middleware.
class MockRequestContext {
  MockRequestContext({
    required this.request,
    required this.startedAt,
  });

  final HttpRequest request;
  final DateTime startedAt;

  final Map<String, Object?> metadata = <String, Object?>{};

  Duration get elapsed => DateTime.now().difference(startedAt);
}
