import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:easy_mock_server/easy_mock_server.dart';
import 'package:test/test.dart';

void main() {
  group('Middleware', () {
    late Directory tempDir;
    late EasyMockServer server;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('easy_mock_server_mw_test');
      final file = File('${tempDir.path}/users.json');
      await file.writeAsString(jsonEncode([
        {'id': 1, 'name': 'Alice'}
      ]));
    });

    tearDown(() async {
      await server.stop();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('delay middleware delays requests', () async {
      server = EasyMockServer(
        config: EasyMockServerConfig(
          port: 0,
          contentLoader: FileSystemMockContentLoader(basePath: tempDir.path),
          middlewares: const <MockMiddleware>[
            DelayMiddleware(Duration(milliseconds: 120)),
          ],
        ),
      );

      final baseUri = await server.start();
      final watch = Stopwatch()..start();
      final response = await _get(baseUri.replace(path: '/users'));
      watch.stop();

      expect(response.statusCode, HttpStatus.ok);
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });

    test('random failure middleware can short-circuit', () async {
      server = EasyMockServer(
        config: EasyMockServerConfig(
          port: 0,
          contentLoader: FileSystemMockContentLoader(basePath: tempDir.path),
          middlewares: <MockMiddleware>[
            RandomFailureMiddleware(
              failureRate: 1,
              statusCode: HttpStatus.serviceUnavailable,
              random: Random(1),
            ),
          ],
        ),
      );

      final baseUri = await server.start();
      final response = await _get(baseUri.replace(path: '/users'));

      expect(response.statusCode, HttpStatus.serviceUnavailable);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      expect(decoded['error'], contains('Simulated'));
    });

    test('response middleware can mutate outgoing response', () async {
      server = EasyMockServer(
        config: EasyMockServerConfig(
          port: 0,
          contentLoader: FileSystemMockContentLoader(basePath: tempDir.path),
          middlewares: <MockMiddleware>[
            _AppendHeaderMiddleware(),
          ],
        ),
      );

      final baseUri = await server.start();
      final response = await _get(baseUri.replace(path: '/users'));

      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers.value('x-mock-server'), 'easy');
    });
  });
}

class _AppendHeaderMiddleware extends MockMiddleware {
  @override
  Future<MockResponse> onResponse(
    MockRequestContext context,
    MockResponse response,
  ) async {
    return response.copyWith(
      headers: <String, String>{
        ...response.headers,
        'x-mock-server': 'easy',
      },
    );
  }
}

Future<_HttpResult> _get(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    return _HttpResult(response.statusCode, response.headers, body);
  } finally {
    client.close(force: true);
  }
}

class _HttpResult {
  _HttpResult(this.statusCode, this.headers, this.body);

  final int statusCode;
  final HttpHeaders headers;
  final String body;
}
