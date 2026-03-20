import 'dart:io';

/// Abstraction for loading mock content from different sources.
///
/// - Dart CLI: file-system based loading via [FileSystemMockContentLoader]
/// - Flutter: pass an asset callback via [AssetCallbackMockContentLoader]
abstract class MockContentLoader {
  const MockContentLoader();

  Future<String?> loadText(String relativePath);
}

/// Loads mock JSON content from the local file system.
///
/// Suitable for Dart CLI applications and server-side development.
class FileSystemMockContentLoader extends MockContentLoader {
  /// Creates a file-system loader.
  ///
  /// [basePath] is the root directory for mock files (e.g., 'assets/mocks').
  const FileSystemMockContentLoader({required this.basePath});

  /// The root directory where mock JSON files are stored.
  final String basePath;

  @override
  Future<String?> loadText(String relativePath) async {
    final normalizedRelative = _normalizeRelative(relativePath);
    final fullPath = _join(basePath, normalizedRelative);
    final file = File(fullPath);

    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }

  String _normalizeRelative(String path) {
    return path.replaceAll(RegExp(r'^/+'), '');
  }

  String _join(String left, String right) {
    final sanitizedLeft =
        left.endsWith('/') ? left.substring(0, left.length - 1) : left;
    return '$sanitizedLeft/$right';
  }
}

typedef AssetStringReader = Future<String> Function(String key);

/// Loads mock JSON content via a callback function (for Flutter assets).
///
/// Suitable for Flutter apps that need to load from bundled assets.
/// Pass [rootBundle.loadString] from `package:flutter/services.dart`.
class AssetCallbackMockContentLoader extends MockContentLoader {
  /// Creates an asset callback loader.
  ///
  /// [basePath] is the asset directory (e.g., 'assets/mocks').
  /// [readAsset] is a callback to load asset content (e.g., rootBundle.loadString).
  const AssetCallbackMockContentLoader({
    required this.basePath,
    required this.readAsset,
  });

  /// The base path within the asset bundle.
  final String basePath;

  /// Callback function to read asset content.
  final AssetStringReader readAsset;

  @override
  Future<String?> loadText(String relativePath) async {
    final normalizedRelative = relativePath.replaceAll(RegExp(r'^/+'), '');
    final key = _join(basePath, normalizedRelative);

    try {
      return await readAsset(key);
    } catch (_) {
      return null;
    }
  }

  String _join(String left, String right) {
    final sanitizedLeft =
        left.endsWith('/') ? left.substring(0, left.length - 1) : left;
    return '$sanitizedLeft/$right';
  }
}
