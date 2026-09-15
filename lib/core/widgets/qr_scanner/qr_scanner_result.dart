class QrScannerResult {
  final String value;
  final DateTime scannedAt;

  const QrScannerResult({required this.value, required this.scannedAt});

  @override
  String toString() {
    return value;
  }
}
