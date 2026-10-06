import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:little_heroes_mobile/core/network/dio_client.dart';

/// Local disk cache for documents (PDFs, images) fetched over HTTP.
///
/// Files are stored by hashing their URL, so lookups are O(1).
/// Layout:
///   <appDocsDir>/lh_docs/<sha1-of-url>.pdf
///   <appDocsDir>/lh_docs/<sha1-of-url>.img
class DocumentCacheService {
  DocumentCacheService._();
  static final DocumentCacheService instance = DocumentCacheService._();

  static const String _folder = 'lh_docs';

  Directory? _dir;

  // ══════════════════════════════════════════════════
  // INIT
  // ══════════════════════════════════════════════════

  Future<Directory> _ensureDir() async {
    if (_dir != null) return _dir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_folder');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  String _keyFor(String url, {required bool isPdf}) {
    final bytes = utf8Bytes(url);
    final hash = sha1.convert(bytes).toString();
    return isPdf ? '$hash.pdf' : '$hash.img';
  }

  // ══════════════════════════════════════════════════
  // READ FROM CACHE
  // ══════════════════════════════════════════════════

  /// Returns the cached file for the URL, or null if not cached.
  Future<File?> getCached(String url, {required bool isPdf}) async {
    try {
      final dir = await _ensureDir();
      final file = File('${dir.path}/${_keyFor(url, isPdf: isPdf)}');
      if (await file.exists() && (await file.length()) > 0) {
        return file;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('DocumentCache getCached error: $e');
      return null;
    }
  }

  /// Returns cached bytes, or null.
  Future<Uint8List?> getCachedBytes(String url, {required bool isPdf}) async {
    final file = await getCached(url, isPdf: isPdf);
    if (file == null) return null;
    try {
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════
  // FETCH + CACHE
  // ══════════════════════════════════════════════════

  /// Downloads the file (with cookies) and stores it.
  /// If the download fails and a cache exists, returns the cache.
  /// If both fail, throws.
  Future<File> fetchAndCache(
    String url, {
    required bool isPdf,
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = await _ensureDir();
    final target = File('${dir.path}/${_keyFor(url, isPdf: isPdf)}');

    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get<List<int>>(
        url,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final bytes = Uint8List.fromList(response.data!);
      if (bytes.isEmpty) throw Exception('Empty response');

      // Write atomically: temp file, then rename.
      final tmp = File('${target.path}.tmp');
      await tmp.writeAsBytes(bytes, flush: true);
      if (await target.exists()) await target.delete();
      await tmp.rename(target.path);

      return target;
    } on DioException catch (e) {
      // Network failure → fall back to cache if available
      final cached = await getCached(url, isPdf: isPdf);
      if (cached != null) {
        if (kDebugMode) {
          debugPrint(
            'DocumentCache: offline fallback → ${cached.path} '
            '(reason: ${e.message})',
          );
        }
        return cached;
      }
      rethrow;
    } catch (e) {
      // Non-Dio error (HTTP code, empty file, etc.)
      final cached = await getCached(url, isPdf: isPdf);
      if (cached != null) return cached;
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════
  // ADMIN
  // ══════════════════════════════════════════════════

  Future<void> clear() async {
    try {
      final dir = await _ensureDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      _dir = null;
    } catch (_) {}
  }

  Future<int> cacheSizeBytes() async {
    try {
      final dir = await _ensureDir();
      if (!await dir.exists()) return 0;
      int total = 0;
      await for (final f in dir.list(recursive: true)) {
        if (f is File) total += await f.length();
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}

/// sha1 needs raw bytes
List<int> utf8Bytes(String s) => s.codeUnits;
