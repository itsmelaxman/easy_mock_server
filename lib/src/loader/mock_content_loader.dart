import 'dart:io';

/// Abstraction for loading mock content from different sources.
///
/// - Dart CLI: file-system based loading via [FileSystemMockContentLoader]
/// - Flutter: pass an asset callback via [AssetCallbackMockContentLoader]
abstract class MockContentLoader {
  const MockContentLoader();

  Future<String?> loadText(String relativePath);
}

class FileSystemMockContentLoader extends MockContentLoader {
  const FileSystemMockContentLoader({required this.basePath});

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

class AssetCallbackMockContentLoader extends MockContentLoader {
  const AssetCallbackMockContentLoader({
    required this.basePath,
    required this.readAsset,
  });

  final String basePath;
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
