# EasyMockServer

[![pub package](https://img.shields.io/pub/v/easy_mock_server.svg)](https://pub.dev/packages/easy_mock_server)
[![license: MIT](https://img.shields.io/github/license/itsmelaxman/easy_mock_server.svg)](https://github.com/itsmelaxman/easy_mock_server/blob/main/LICENSE)
[![top language](https://img.shields.io/github/languages/top/itsmelaxman/easy_mock_server.svg)](https://github.com/itsmelaxman/easy_mock_server)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://dart.dev/effective-dart)

`EasyMockServer` is a reusable Dart package that runs a local HTTP mock server and serves JSON files as API responses.

It is designed for:

- Flutter apps (via asset callback loader)
- Dart CLI projects (via file-system loader)

## Features

- Start local HTTP server on configurable host/port
- Route incoming URLs to JSON files
- Ignores query parameters
- Supports nested routes with fallback behavior
- Middleware pipeline for request/response interception
- Built-in middleware for delay, random failures, and logging
- Optional route-map JSON support for custom endpoint mappings

## Install

```yaml
dependencies:
  easy_mock_server: ^0.1.0
```

If you are testing locally before publishing, use `path` temporarily in your app:

```yaml
dependencies:
  easy_mock_server:
    path: ../easy_mock_server
```

## Quick Start (Dart CLI)

```dart
import 'dart:io';
import 'package:easy_mock_server/easy_mock_server.dart';

Future<void> main() async {
  final server = EasyMockServer(
    config: EasyMockServerConfig(
      port: 8080,
      basePath: 'assets/mocks',
      middlewares: <MockMiddleware>[
        const DelayMiddleware(Duration(milliseconds: 150)),
        LoggingMiddleware(log: stdout.writeln),
      ],
      log: stdout.writeln,
    ),
  );

  final uri = await server.start();
  stdout.writeln('Mock server started at $uri');
}
```

## Folder Mapping Rules

Default resolver candidates for `GET /api/v1/profile?lang=en`:

1. `api/v1/profile.json`
2. `profile.json`
3. `api/v1/profile/index.json`
4. `profile/index.json`

The first existing file is returned as response body.

## JSON Formats (`[]` vs `{}`)

Both are fully supported.

- If your mock file contains a JSON array (for example, `[{"id":1}]`), the server returns that array as-is.
- If your mock file contains a JSON object (for example, `{"id":1}`), the server returns that object as-is.

In short: `EasyMockServer` does not force a wrapper format. Whatever valid JSON you place in the file is returned.

## Flutter Asset Loading

Pass a callback using `rootBundle.loadString`:

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_mock_server/easy_mock_server.dart';

final server = EasyMockServer(
  config: EasyMockServerConfig(
    port: 8080,
    contentLoader: AssetCallbackMockContentLoader(
      basePath: 'assets/mocks',
      readAsset: rootBundle.loadString,
    ),
  ),
);
```

Also ensure your `pubspec.yaml` includes assets:

```yaml
flutter:
  assets:
    - assets/mocks/
```

## Optional Route Map

Create a JSON file like `assets/route_map.json`:

```json
{
  "/legacy/users": "users.json",
  "/me": "profile.json"
}
```

Use it:

```dart
import 'dart:io';
import 'package:easy_mock_server/easy_mock_server.dart';

final routesJson = await File('assets/route_map.json').readAsString();
final routeMap = parseRouteMapJson(routesJson);

final server = EasyMockServer(
  config: EasyMockServerConfig(
    routeResolver: MappedRouteResolver(routeMap: routeMap),
  ),
);
```

## Middleware

Built-in middleware:

- `DelayMiddleware`: adds artificial latency
- `RandomFailureMiddleware`: randomly returns errors
- `LoggingMiddleware`: logs request and response information

You can create custom middleware by extending `MockMiddleware` and overriding:

- `onRequest` (short-circuit if needed)
- `onResponse` (modify outgoing response)

## Error Handling

- Missing file -> `404` with JSON error body
- Unexpected server exception -> `500` with JSON error body
- Responses use `application/json; charset=utf-8`

## Run Example

```bash
dart run example/main.dart
```

## Run Tests

```bash
dart test
```
