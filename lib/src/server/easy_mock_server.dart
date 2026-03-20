import 'dart:io';

import '../model/mock_request_context.dart';
import '../model/mock_response.dart';
import 'easy_mock_server_config.dart';

class EasyMockServer {
  EasyMockServer({required this.config});

  final EasyMockServerConfig config;
  HttpServer? _server;

  bool get isRunning => _server != null;

  Uri? get baseUri {
    final server = _server;
    if (server == null) {
      return null;
    }
    return Uri(scheme: 'http', host: server.address.host, port: server.port);
  }

  Future<Uri> start() async {
    if (_server != null) {
      return baseUri!;
    }

    _server = await HttpServer.bind(config.host, config.port);
    _server!.listen(_handleRequest);

    final uri = baseUri!;
    config.log?.call('EasyMockServer started at $uri');
    return uri;
  }

  Future<void> stop({bool force = true}) async {
    final server = _server;
    if (server == null) {
      return;
    }

    await server.close(force: force);
    _server = null;
    config.log?.call('EasyMockServer stopped');
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final context = MockRequestContext(
      request: request,
      startedAt: DateTime.now(),
    );

    MockResponse response;

    try {
      response = await _process(context);
    } catch (error, stackTrace) {
      config.log?.call('Unhandled error: $error\n$stackTrace');
      response = MockResponse.error();
    }

    await _writeResponse(request.response, response);
  }

  Future<MockResponse> _process(MockRequestContext context) async {
    for (final middleware in config.middlewares) {
      final maybeResponse = await middleware.onRequest(context);
      if (maybeResponse != null) {
        return _runResponseMiddleware(context, maybeResponse);
      }
    }

    final requestPath = context.request.uri.path;
    final candidates = config.routeResolver.resolveCandidates(requestPath);

    String? payload;
    for (final candidate in candidates) {
      payload = await config.contentLoader.loadText(candidate);
      if (payload != null) {
        break;
      }
    }

    final response = payload != null
        ? MockResponse.okJson(payload)
        : MockResponse.error(
            statusCode: HttpStatus.notFound,
            message: 'No mock JSON found for ${context.request.uri.path}',
          );

    return _runResponseMiddleware(context, response);
  }

  Future<MockResponse> _runResponseMiddleware(
    MockRequestContext context,
    MockResponse response,
  ) async {
    var current = response;
    for (final middleware in config.middlewares) {
      current = await middleware.onResponse(context, current);
    }
    return current;
  }

  Future<void> _writeResponse(
      HttpResponse output, MockResponse response) async {
    output.statusCode = response.statusCode;

    response.headers.forEach(output.headers.set);

    output.write(response.body);
    await output.close();
  }
}
