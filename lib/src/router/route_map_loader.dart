import 'dart:convert';

/// Reads simple route map JSON into `Map<String, String>`.
///
/// Expected format:
/// {
///   "/users": "users.json",
///   "/api/v1/profile": "profile_custom.json"
/// }
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
