import '../model/mock_request_context.dart';
import '../model/mock_response.dart';
import 'mock_middleware.dart';

/// Adds a delay to each request for simulating network latency.
class DelayMiddleware extends MockMiddleware {
  /// Creates a delay middleware.
  ///
  /// [delay] is the duration to wait before processing the request.
  const DelayMiddleware(this.delay);

  /// The duration to delay each request by.
  final Duration delay;

  @override
  Future<MockResponse?> onRequest(MockRequestContext context) async {
    await Future<void>.delayed(delay);
    return null;
  }
}
