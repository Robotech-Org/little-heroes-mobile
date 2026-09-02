import 'package:path/path.dart' as path;

import 'document_type.dart';

class DocumentViewerUtils {
  static DocumentType getDocumentType(String url) {
    final cleanUrl = url.split('?').first;
    final extension = path.extension(cleanUrl).toLowerCase();

    switch (extension) {
      // Images
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
      case '.bmp':
        return DocumentType.image;

      // PDF
      case '.pdf':
        return DocumentType.pdf;

      // Word
      case '.doc':
      case '.docx':
        return DocumentType.word;

      // Excel
      case '.xls':
      case '.xlsx':
      case '.csv':
        return DocumentType.excel;

      // PowerPoint
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

  static bool isImage(String url) {
    return getDocumentType(url) == DocumentType.image;
  }

  static bool isPdf(String url) {
    return getDocumentType(url) == DocumentType.pdf;
  }

  static bool isOfficeDocument(String url) {
    final type = getDocumentType(url);

    return type == DocumentType.word ||
        type == DocumentType.excel ||
        type == DocumentType.powerpoint;
  }
}
