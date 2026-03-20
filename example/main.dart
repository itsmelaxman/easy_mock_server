import 'dart:io';

import 'package:easy_mock_server/easy_mock_server.dart';

Future<void> main() async {
  final server = EasyMockServer(
    config: EasyMockServerConfig(
      port: 8080,
      basePath: 'assets/mocks',
      middlewares: <MockMiddleware>[
        const DelayMiddleware(Duration(milliseconds: 200)),
        LoggingMiddleware(log: stdout.writeln),
      ],
      log: stdout.writeln,
    ),
  );

  final uri = await server.start();
  stdout.writeln('Mock server running at $uri');
  stdout.writeln('Try: curl ${uri.replace(path: '/users')}');

  ProcessSignal.sigint.watch().listen((_) async {
    await server.stop();
    exit(0);
  });
}
