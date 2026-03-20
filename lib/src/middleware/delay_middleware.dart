import '../model/mock_request_context.dart';
import '../model/mock_response.dart';
import 'mock_middleware.dart';

class DelayMiddleware extends MockMiddleware {
  const DelayMiddleware(this.delay);

  final Duration delay;

  @override
  Future<MockResponse?> onRequest(MockRequestContext context) async {
    await Future<void>.delayed(delay);
    return null;
  }
}
