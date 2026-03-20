import '../model/mock_request_context.dart';
import '../model/mock_response.dart';

/// Middleware lifecycle for request/response interception.
///
/// [onRequest] can return a response to short-circuit downstream processing.
/// [onResponse] can mutate/replace the response before it is written.
abstract class MockMiddleware {
  const MockMiddleware();

  Future<MockResponse?> onRequest(MockRequestContext context) async => null;

  Future<MockResponse> onResponse(
    MockRequestContext context,
    MockResponse response,
  ) async {
    return response;
  }
}
