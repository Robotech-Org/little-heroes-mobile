import 'dart:convert';

class QrCard {
  final String card;
  final String token;
  final int version;

  const QrCard({
    required this.card,
    required this.token,
    required this.version,
  });
}

class QrDecoder {
  QrDecoder._();

  static QrCard? tryDecode(String raw) {
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

      return QrCard(
        card: card,
        token: json['token']?.toString() ?? '',
        version: (json['v'] as num?)?.toInt() ?? 1,
      );
    } catch (_) {
      return null;
    }
  }
}
