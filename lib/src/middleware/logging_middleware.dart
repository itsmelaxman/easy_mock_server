import '../model/mock_request_context.dart';
import '../model/mock_response.dart';
import 'mock_middleware.dart';

/// Callback function type for writing log messages.
typedef LogWriter = void Function(String message);

/// Logs all requests and responses.
class LoggingMiddleware extends MockMiddleware {
  /// Creates a logging middleware.
  ///
  /// [log] is the callback function to write log messages (default: print).
  const LoggingMiddleware({this.log = print});

  /// The callback function for writing log messages.
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
