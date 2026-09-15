import 'dart:convert';

class QrCardPayload {
  final String card; // ← "SIDC-2026-00004" — used as student_id
  final String token;
  final int version;

  const QrCardPayload({
    required this.card,
    required this.token,
    required this.version,
  });
}

class QrPayloadDecoder {
  QrPayloadDecoder._();

  /// QR format: `<base64url(json)>.<signature>`.
  /// We decode only the first segment; the signature is verified server-side.
  static QrCardPayload? tryDecode(String raw) {
    try {
      final parts = raw.split('.');
      if (parts.isEmpty) return null;

      var encoded = parts.first;
      final pad = (4 - encoded.length % 4) % 4;
      encoded = encoded + ('=' * pad);

      final decoded = utf8.decode(base64Url.decode(encoded));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final card = json['card']?.toString() ?? '';
      if (card.isEmpty) return null;

      return QrCardPayload(
        card: card,
        token: json['token']?.toString() ?? '',
        version: (json['v'] as num?)?.toInt() ?? 1,
      );
    } catch (_) {
      return null;
    }
  }
}
