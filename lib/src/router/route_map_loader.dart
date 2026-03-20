import 'dart:convert';

/// Parses a JSON route map string into a `Map<String, String>`.
///
/// Expected format:
/// ```json
/// {
///   "/users": "users.json",
///   "/api/v1/profile": "profile_custom.json"
/// }
/// ```
///
/// Returns a map of request paths to their corresponding mock file paths.
///
/// Throws [FormatException] if the JSON is invalid or keys/values are not strings.
Map<String, String> parseRouteMapJson(String jsonString) {
  final decoded = jsonDecode(jsonString);

  if (decoded is! Map) {
    throw const FormatException('Route map JSON must be an object');
  }

  final result = <String, String>{};
  decoded.forEach((key, value) {
    if (key is! String || value is! String) {
      throw const FormatException('Route map keys and values must be strings');
    }
    result[key] = value;
  });

  return result;
}
