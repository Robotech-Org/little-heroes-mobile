import 'dart:async';

import 'package:app_links/app_links.dart';

/// Listens for incoming deep links (iOS + Android) and broadcasts
/// the txRef when the app is opened via `littleheroes://payment/callback?...`.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  final _txRefController = StreamController<String>.broadcast();

  Stream<String> get txRefStream => _txRefController.stream;

  Future<void> init() async {
    // Cold start (app launched from a deep link)
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handle(initial);

    // Warm start (app already running)
    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
  }

  void _handle(Uri uri) {
    if (uri.scheme != 'littleheroes') return;
    if (!uri.path.contains('payment')) return;

    final txRef =
        uri.queryParameters['tx_ref'] ??
        uri.queryParameters['trx_ref'] ??
        uri.queryParameters['reference'];
    if (txRef != null && txRef.isNotEmpty) {
      _txRefController.add(txRef);
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _txRefController.close();
  }
}
