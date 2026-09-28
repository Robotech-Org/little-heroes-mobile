import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:little_heroes_mobile/core/network/dio_client.dart';

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
  Uint8List? _pdfBytes;
  bool _isLoadingPdf = false;
  String? _pdfError;

  Uint8List? _imageBytes;
  bool _isLoadingImage = false;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    final type = DocumentViewerUtils.getDocumentType(widget.url);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (type) {
        case DocumentType.pdf:
          _loadPdf();
          break;
        case DocumentType.image:
          _loadImage();
          break;
        case DocumentType.word:
        case DocumentType.excel:
        case DocumentType.powerpoint:
        case DocumentType.unknown:
          // Non-PDF/non-image → download + hand to OS via share intent.
          // If you don't need this, just show an error.
          _showError('Unsupported preview — open externally is disabled.');
          break;
      }
    });
  }

  // ═════════════════════════════════════════════════════════════
  // PDF — download with cookies, render from memory
  // ═════════════════════════════════════════════════════════════
  Future<void> _loadPdf() async {
    if (mounted) {
      setState(() {
        _isLoadingPdf = true;
        _pdfError = null;
      });
    }

    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get<List<int>>(
        widget.url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint(
        'PDF fetch → status=${response.statusCode} '
        'content-type=${response.headers.value('content-type')} '
        'length=${response.data?.length}',
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final bytes = Uint8List.fromList(response.data!);
      if (bytes.isEmpty) throw Exception('Empty PDF');

      // Sanity check: real PDFs start with "%PDF"
      if (bytes.length < 5 ||
          bytes[0] != 0x25 || // %
          bytes[1] != 0x50 || // P
          bytes[2] != 0x44 || // D
          bytes[3] != 0x46) {
        // Not a PDF — backend probably returned an HTML login page.
        final head = String.fromCharCodes(bytes.take(200))
            .replaceAll('\n', ' ');
        debugPrint('Non-PDF response head: $head');
        throw Exception(
          'Server did not return a PDF. Check your session / permissions.',
        );
      }

      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _isLoadingPdf = false;
      });
    } catch (e) {
      debugPrint('PDF load failed: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingPdf = false;
        _pdfError = _cleanError(e);
      });
    }
  }

  // ═════════════════════════════════════════════════════════════
  // Image — same approach
  // ═════════════════════════════════════════════════════════════
  Future<void> _loadImage() async {
    if (mounted) {
      setState(() {
        _isLoadingImage = true;
        _imageError = null;
      });
    }

    try {
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get<List<int>>(
        widget.url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final bytes = Uint8List.fromList(response.data!);

      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _isLoadingImage = false;
      });
    } catch (e) {
      debugPrint('Image load failed: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingImage = false;
        _imageError = _cleanError(e);
      });
    }
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('DioException [bad response]: ', '');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
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
        return Scaffold(
          appBar: AppBar(title: Text(widget.title ?? 'Document')),
          body: const Center(child: CircularProgressIndicator()),
        );
    }
  }

  Widget _buildImageViewer() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Image')),
      body: _buildImageBody(),
    );
  }

  Widget _buildImageBody() {
    if (_isLoadingImage) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_imageError != null || _imageBytes == null) {
      return _buildErrorState(
        message: _imageError ?? 'Could not load image',
        onRetry: _loadImage,
      );
    }
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      child: Center(
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Center(child: Text('Could not load image')),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'PDF')),
      body: _buildPdfBody(),
    );
  }

  Widget _buildPdfBody() {
    if (_isLoadingPdf) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pdfError != null || _pdfBytes == null) {
      return _buildErrorState(
        message: _pdfError ?? 'Could not load PDF',
        onRetry: _loadPdf,
      );
    }

    //    In-app rendering, no browser, no Frappe page.
    return SfPdfViewer.memory(
      _pdfBytes!,
      canShowScrollHead: true,
      canShowScrollStatus: true,
    );
  }

  Widget _buildErrorState({
    required String message,
    required Future<void> Function() onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
