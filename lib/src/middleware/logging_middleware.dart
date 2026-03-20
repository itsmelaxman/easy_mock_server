import '../model/mock_request_context.dart';
import '../model/mock_response.dart';
import 'mock_middleware.dart';

typedef LogWriter = void Function(String message);

class LoggingMiddleware extends MockMiddleware {
  const LoggingMiddleware({this.log = print});

  final LogWriter log;

  @override
  Future<MockResponse> onResponse(
    MockRequestContext context,
    MockResponse response,
  ) async {
    log(
      '[EasyMockServer] '
      '${context.request.method} '
      '${context.request.uri.path} '
      '-> ${response.statusCode} '
      '(${context.elapsed.inMilliseconds}ms)',
    );

    return response;
  }
}
