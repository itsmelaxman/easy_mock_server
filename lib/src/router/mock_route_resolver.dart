/// Defines route resolution strategy from a request path to mock file candidates.
abstract class MockRouteResolver {
  const MockRouteResolver();

  /// Returns prioritized file candidates relative to the mock base path.
  ///
  /// The server will pick the first file that exists.
  List<String> resolveCandidates(String requestPath);
}

/// Default route resolver with a pragmatic fallback strategy.
///
/// Example: `/api/v1/profile?lang=en` ->
/// - `api/v1/profile.json`
/// - `profile.json`
/// - `api/v1/profile/index.json`
/// - `profile/index.json`
class DefaultMockRouteResolver extends MockRouteResolver {
  const DefaultMockRouteResolver();

  @override
  List<String> resolveCandidates(String requestPath) {
    final cleanedPath = _normalizePath(requestPath);
    final segments =
        cleanedPath.split('/').where((segment) => segment.isNotEmpty).toList();

    if (segments.isEmpty) {
      return const <String>['index.json'];
    }

    final joined = segments.join('/');
    final last = segments.last;

    final candidates = <String>[
      '$joined.json',
      '$last.json',
      '$joined/index.json',
      '$last/index.json',
    ];

    return _unique(candidates);
  }

  String _normalizePath(String rawPath) {
    final noQuery = rawPath.split('?').first;
    final trimmed = noQuery.trim();

    if (trimmed.isEmpty || trimmed == '/') {
      return '/';
    }

    final singleLeadingSlash = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return singleLeadingSlash.replaceAll(RegExp(r'/+'), '/');
  }

  List<String> _unique(List<String> values) {
    final seen = <String>{};
    final out = <String>[];

    for (final value in values) {
      if (seen.add(value)) {
        out.add(value);
      }
    }

    return out;
  }
}

/// Route resolver that allows explicit path-to-file mapping, then fallback logic.
///
/// Use this when you need custom path→file mappings before falling back to
/// the default resolution strategy.
class MappedRouteResolver extends MockRouteResolver {
  /// Creates a mapped route resolver.
  ///
  /// [routeMap] maps request paths to specific mock files.
  /// [fallback] is the resolver to use for paths not in the map (defaults to [DefaultMockRouteResolver]).
  MappedRouteResolver({
    required Map<String, String> routeMap,
    MockRouteResolver? fallback,
  })  : _routeMap =
            routeMap.map((key, value) => MapEntry(_normalizeKey(key), value)),
        _fallback = fallback ?? const DefaultMockRouteResolver();

  final Map<String, String> _routeMap;
  final MockRouteResolver _fallback;

  @override
  List<String> resolveCandidates(String requestPath) {
    final key = _normalizeKey(requestPath);
    final mapped = _routeMap[key];

    if (mapped != null && mapped.isNotEmpty) {
      return <String>[mapped, ..._fallback.resolveCandidates(requestPath)];
    }

    return _fallback.resolveCandidates(requestPath);
  }

  static String _normalizeKey(String path) {
    final noQuery = path.split('?').first;
    if (noQuery.isEmpty || noQuery == '/') {
      return '/';
    }
    final prefixed = noQuery.startsWith('/') ? noQuery : '/$noQuery';
    return prefixed.replaceAll(RegExp(r'/+'), '/');
  }
}
