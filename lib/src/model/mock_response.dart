import 'dart:convert';
import 'dart:io';

/// Immutable HTTP response model used by `EasyMockServer` internals and middleware.
class MockResponse {
  /// Creates a mock response.
  ///
  /// [statusCode] is the HTTP status code (default: 200).
  /// [body] is the response body (typically JSON string).
  /// [headers] are HTTP headers (defaults to JSON content-type).
  const MockResponse({
    required this.statusCode,
    required this.body,
    Map<String, String>? headers,
  }) : headers = headers ??
            const {'content-type': 'application/json; charset=utf-8'};

  /// Creates a mock JSON response from a Dart object.
  ///
  /// The object is automatically JSON-encoded. Useful for returning
  /// structured data that will be serialized as JSON.
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

  /// The HTTP status code of the response.
  final int statusCode;

  /// The response body (typically a JSON string).
  final String body;

  /// HTTP headers for the response.
  final Map<String, String> headers;

  /// Creates a 200 OK response with the given JSON body.
  static MockResponse okJson(String jsonString) {
    return MockResponse(
      statusCode: HttpStatus.ok,
      body: jsonString,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }

  /// Creates an error response with the given status code and message.
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

  /// Creates a copy of this response with optionally updated fields.
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
