import 'dart:io';

import 'package:easy_mock_server/easy_mock_server.dart';

Future<void> main() async {
  final routesJson = await File('assets/route_map.json').readAsString();
  final routeMap = parseRouteMapJson(routesJson);

  final server = EasyMockServer(
    config: EasyMockServerConfig(
      port: 8081,
      basePath: 'assets/mocks',
      routeResolver: MappedRouteResolver(routeMap: routeMap),
      middlewares: <MockMiddleware>[LoggingMiddleware(log: stdout.writeln)],
      log: stdout.writeln,
    ),
  );

  final uri = await server.start();
  stdout.writeln('Mapped mock server running at $uri');
}
