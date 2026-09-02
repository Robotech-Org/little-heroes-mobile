import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'document_type.dart';
import 'document_viewer_utils.dart';

class DocumentViewerPage extends StatelessWidget {
  final String url;
  final String? title;

  const DocumentViewerPage({super.key, required this.url, this.title});

  @override
  Widget build(BuildContext context) {
    final documentType = DocumentViewerUtils.getDocumentType(url);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? DocumentViewerUtils.getFileName(url)),
        actions: [
          IconButton(
            onPressed: () => _openExternal(context),
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Open externally',
          ),
        ],
      ),
      body: _buildViewer(context, documentType),
    );
  }

  Widget _buildViewer(BuildContext context, DocumentType documentType) {
    switch (documentType) {
      case DocumentType.image:
        return _ImageViewer(url: url);

      case DocumentType.pdf:
        return _PdfViewer(url: url);

      case DocumentType.word:
      case DocumentType.excel:
      case DocumentType.powerpoint:
        return _OfficeViewer(url: url, documentType: documentType);

      case DocumentType.unknown:
        return _UnknownViewer(url: url, onOpen: () => _openExternal(context));
    }
  }

  Future<void> _openExternal(BuildContext context) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      _showError(context, 'Invalid document URL');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showError(context, 'Could not open this file');
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Could not open this file');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// ============================================================
// IMAGE VIEWER
// ============================================================

class _ImageViewer extends StatelessWidget {
  final String url;

  const _ImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const _ErrorContent(message: 'Unable to load image');
          },
        ),
      ),
    );
  }
}

// ============================================================
// PDF VIEWER
// ============================================================

class _PdfViewer extends StatelessWidget {
  final String url;

  const _PdfViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(url);
  }
}

// ============================================================
// WORD / EXCEL / POWERPOINT
// ============================================================

class _OfficeViewer extends StatelessWidget {
  final String url;
  final DocumentType documentType;

  const _OfficeViewer({required this.url, required this.documentType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    String title;
    IconData icon;

    switch (documentType) {
      case DocumentType.word:
        title = 'Word Document';
        icon = Icons.description_rounded;
        break;

      case DocumentType.excel:
        title = 'Excel Spreadsheet';
        icon = Icons.table_chart_rounded;
        break;

      case DocumentType.powerpoint:
        title = 'PowerPoint Presentation';
        icon = Icons.slideshow_rounded;
        break;

      default:
        title = 'Document';
        icon = Icons.insert_drive_file_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: colors.primary),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'This type of file will be opened using an available external application.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.65),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () async {
                final uri = Uri.tryParse(url);

                if (uri == null) {
                  return;
                }

                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open Document'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// UNKNOWN FILE
// ============================================================

class _UnknownViewer extends StatelessWidget {
  final String url;
  final VoidCallback onOpen;

  const _UnknownViewer({required this.url, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file_rounded,
              size: 80,
              color: colors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'File',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DocumentViewerUtils.getFileName(url),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open File'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorContent extends StatelessWidget {
  final String message;

  const _ErrorContent({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
