import 'package:path/path.dart' as path;

import 'document_type.dart';

class DocumentViewerUtils {
  static DocumentType getDocumentType(String url) {
    final lower = url.toLowerCase();

    // ── 1) Known Frappe PDF endpoints ─────────────────
    if (lower.contains('/download_pdf') ||
        lower.contains('print_format') ||
        lower.contains('format=three%20month%20report')) {
      return DocumentType.pdf;
    }

    // ── 2) Fall back to file extension ────────────────
    final cleanUrl = url.split('?').first;
    final extension = path.extension(cleanUrl).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
      case '.bmp':
        return DocumentType.image;

      case '.pdf':
        return DocumentType.pdf;

      case '.doc':
      case '.docx':
        return DocumentType.word;

      case '.xls':
      case '.xlsx':
      case '.csv':
        return DocumentType.excel;

      case '.ppt':
      case '.pptx':
        return DocumentType.powerpoint;

      default:
        return DocumentType.unknown;
    }
  }

  static String getFileExtension(String url) {
    final cleanUrl = url.split('?').first;
    return path.extension(cleanUrl).toLowerCase();
  }

  static String getFileName(String url) {
    final cleanUrl = url.split('?').first;
    return path.basename(cleanUrl);
  }

  static bool isImage(String url) => getDocumentType(url) == DocumentType.image;

  static bool isPdf(String url) => getDocumentType(url) == DocumentType.pdf;

  static bool isOfficeDocument(String url) {
    final type = getDocumentType(url);
    return type == DocumentType.word ||
        type == DocumentType.excel ||
        type == DocumentType.powerpoint;
  }
}
