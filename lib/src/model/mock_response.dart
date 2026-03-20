import 'dart:convert';
import 'dart:io';

/// Immutable HTTP response model used by `EasyMockServer` internals and middleware.
class MockResponse {
  const MockResponse({
    required this.statusCode,
    required this.body,
    Map<String, String>? headers,
  }) : headers = headers ??
            const {'content-type': 'application/json; charset=utf-8'};

  factory MockResponse.json({
    required int statusCode,
    required Object body,
    Map<String, String>? headers,
  }) {
    final mergedHeaders = <String, String>{
      'content-type': 'application/json; charset=utf-8',
      ...?headers,
    };

    return MockResponse(
      statusCode: statusCode,
      body: jsonEncode(body),
      headers: mergedHeaders,
    );
  }

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  static MockResponse okJson(String jsonString) {
    return MockResponse(
      statusCode: HttpStatus.ok,
      body: jsonString,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }

  static MockResponse error({
    int statusCode = HttpStatus.internalServerError,
    String message = 'Internal mock server error',
  }) {
    return MockResponse.json(
      statusCode: statusCode,
      body: <String, Object>{
        'error': message,
        'status': statusCode,
      },
    );
  }

  MockResponse copyWith({
    int? statusCode,
    String? body,
    Map<String, String>? headers,
  }) {
    return MockResponse(
      statusCode: statusCode ?? this.statusCode,
      body: body ?? this.body,
      headers: headers ?? this.headers,
    );
  }
}
