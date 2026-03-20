/// A reusable local HTTP mock server for Dart and Flutter projects.
///
/// `EasyMockServer` provides a simple way to run a local HTTP server that serves
/// JSON mock responses from files. Ideal for development and testing before
/// backend APIs are ready.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:easy_mock_server/easy_mock_server.dart';
///
/// final server = EasyMockServer(
///   config: EasyMockServerConfig(
///     port: 8080,
///     basePath: 'assets/mocks',
///   ),
/// );
///
/// await server.start();
/// ```
///
/// ## Key Components
///
/// - [EasyMockServer]: Main server class to start/stop HTTP server
/// - [EasyMockServerConfig]: Configuration for server, routes, middleware, loaders
/// - [MockContentLoader]: Abstract interface for loading JSON from files or assets
/// - [MockRouteResolver]: Path resolution strategy (default or mapped)
/// - [MockMiddleware]: Composable request/response interceptors
library ;

export 'src/loader/mock_content_loader.dart';
export 'src/middleware/delay_middleware.dart';
export 'src/middleware/logging_middleware.dart';
export 'src/middleware/mock_middleware.dart';
export 'src/middleware/random_failure_middleware.dart';
export 'src/model/mock_request_context.dart';
export 'src/model/mock_response.dart';
export 'src/router/mock_route_resolver.dart';
export 'src/router/route_map_loader.dart';
export 'src/server/easy_mock_server.dart';
export 'src/server/easy_mock_server_config.dart';
