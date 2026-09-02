import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'document_type.dart';
import 'document_viewer_utils.dart';

class DocumentViewerPage extends StatefulWidget {
  final String url;
  final String? title;

  const DocumentViewerPage({super.key, required this.url, this.title});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDocument();
    });
  }

  Future<void> _handleDocument() async {
    final type = DocumentViewerUtils.getDocumentType(widget.url);

    switch (type) {
      case DocumentType.image:
      case DocumentType.pdf:
        // These are displayed inside Flutter.
        return;

      case DocumentType.word:
      case DocumentType.excel:
      case DocumentType.powerpoint:
      case DocumentType.unknown:
        await _openExternal();
        break;
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.url);

    if (uri == null) {
      _showError('Invalid file URL');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened) {
        _showError('Could not open the file');
      }
    } catch (e) {
      _showError('Could not open the file');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final type = DocumentViewerUtils.getDocumentType(widget.url);

    switch (type) {
      case DocumentType.image:
        return _buildImageViewer();

      case DocumentType.pdf:
        return _buildPdfViewer();

      case DocumentType.word:
      case DocumentType.excel:
      case DocumentType.powerpoint:
      case DocumentType.unknown:
        return _buildExternalOpeningScreen();
    }
  }

  Widget _buildImageViewer() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Image')),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Could not load image'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'PDF')),
      body: SfPdfViewer.network(widget.url),
    );
  }

  Widget _buildExternalOpeningScreen() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Document')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
