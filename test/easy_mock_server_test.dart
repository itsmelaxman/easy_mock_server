import 'dart:convert';
import 'dart:io';

import 'package:easy_mock_server/easy_mock_server.dart';
import 'package:test/test.dart';

void main() {
  group('EasyMockServer', () {
    late Directory tempDir;
    late EasyMockServer server;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('easy_mock_server_test');
      await _writeJson(tempDir, 'users.json', [
        {'id': 1, 'name': 'Alice'},
      ]);
      await _writeJson(tempDir, 'profile.json', {
        'id': 42,
        'name': 'fallback-profile',
      });
      await _writeJson(tempDir, 'api/v1/profile.json', {
        'id': 99,
        'name': 'nested-profile',
      });
    });

    tearDown(() async {
      await server.stop();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('serves json file for direct route and ignores query params',
        () async {
      server = EasyMockServer(
        config: EasyMockServerConfig(
          port: 0,
          contentLoader: FileSystemMockContentLoader(basePath: tempDir.path),
        ),
      );

      final baseUri = await server.start();
      final response = await _get(
          baseUri.replace(path: '/users', queryParameters: {'q': '1'}));

      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers.contentType?.mimeType, 'application/json');
      final decoded = jsonDecode(response.body) as List<dynamic>;
      expect(decoded.first['name'], 'Alice');
    });

    test('supports nested route lookup', () async {
      server = EasyMockServer(
        config: EasyMockServerConfig(
          port: 0,
          contentLoader: FileSystemMockContentLoader(basePath: tempDir.path),
        ),
      );

      final baseUri = await server.start();
      final response = await _get(baseUri.replace(path: '/api/v1/profile'));

      expect(response.statusCode, HttpStatus.ok);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      expect(decoded['name'], 'nested-profile');
    });

    test('returns 404 when file is missing', () async {
      server = EasyMockServer(
        config: EasyMockServerConfig(
          port: 0,
          contentLoader: FileSystemMockContentLoader(basePath: tempDir.path),
        ),
      );

      final baseUri = await server.start();
      final response = await _get(baseUri.replace(path: '/unknown'));

      expect(response.statusCode, HttpStatus.notFound);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      expect(decoded['status'], HttpStatus.notFound);
    });
  });
}

Future<void> _writeJson(
    Directory root, String relativePath, Object value) async {
  final file = File('${root.path}/$relativePath');
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(value));
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
