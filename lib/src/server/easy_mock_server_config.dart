import '../loader/mock_content_loader.dart';
import '../middleware/mock_middleware.dart';
import '../router/mock_route_resolver.dart';

/// Configuration entry-point for `EasyMockServer`.
class EasyMockServerConfig {
  EasyMockServerConfig({
    this.host = '127.0.0.1',
    this.port = 8080,
    this.basePath = 'assets/mocks',
    this.routeResolver = const DefaultMockRouteResolver(),
    this.middlewares = const <MockMiddleware>[],
    this.log,
    MockContentLoader? contentLoader,
  }) : contentLoader =
            contentLoader ?? FileSystemMockContentLoader(basePath: basePath);

  final String host;
  final int port;

  /// Used by default file-system loader and asset loader helpers.
  final String basePath;

  final MockRouteResolver routeResolver;
  final List<MockMiddleware> middlewares;
  final MockContentLoader contentLoader;

  /// Optional server-level log writer for lifecycle and failures.
  final void Function(String message)? log;
}
