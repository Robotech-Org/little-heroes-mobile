import 'dart:typed_data';

/// Simple in-memory byte cache for authenticated images.
///
/// Keyed by image URL. Kept static so every [AuthenticatedImage] instance
/// shares the same cache across the whole app lifetime.
class ImageCacheStore {
  ImageCacheStore._();

  static final Map<String, Uint8List> _cache = {};
  static final Map<String, Future<Uint8List>> _inFlight = {};

  /// Max number of images to keep in memory (LRU eviction).
  static const int _maxEntries = 100;

  static Uint8List? get(String url) => _cache[url];

  static bool contains(String url) => _cache.containsKey(url);

  static void put(String url, Uint8List bytes) {
    if (_cache.length >= _maxEntries) {
      // Simple FIFO-ish eviction: drop the oldest key
      _cache.remove(_cache.keys.first);
    }
    _cache[url] = bytes;
  }

  /// Deduplicates concurrent requests for the same URL.
  /// If a fetch is already in flight, returns the same future.
  static Future<Uint8List> fetch(
    String url,
    Future<Uint8List> Function() loader,
  ) {
    final cached = _cache[url];
    if (cached != null) return Future.value(cached);

    final existing = _inFlight[url];
    if (existing != null) return existing;

    final future = loader()
        .then((bytes) {
          put(url, bytes);
          return bytes;
        })
        .whenComplete(() {
          _inFlight.remove(url);
        });

    _inFlight[url] = future;
    return future;
  }

  static void clear() {
    _cache.clear();
    _inFlight.clear();
  }
}
