// import 'dart:typed_data';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// import 'package:little_heroes_mobile/core/network/dio_client.dart';

// import 'document_type.dart';
// import 'document_viewer_utils.dart';

// class DocumentViewerPage extends StatefulWidget {
//   final String url;
//   final String? title;

//   const DocumentViewerPage({super.key, required this.url, this.title});

//   @override
//   State<DocumentViewerPage> createState() => _DocumentViewerPageState();
// }

// class _DocumentViewerPageState extends State<DocumentViewerPage> {
//   Uint8List? _pdfBytes;
//   bool _isLoadingPdf = false;
//   String? _pdfError;

//   Uint8List? _imageBytes;
//   bool _isLoadingImage = false;
//   String? _imageError;

//   @override
//   void initState() {
//     super.initState();
//     final type = DocumentViewerUtils.getDocumentType(widget.url);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       switch (type) {
//         case DocumentType.pdf:
//           _loadPdf();
//           break;
//         case DocumentType.image:
//           _loadImage();
//           break;
//         case DocumentType.word:
//         case DocumentType.excel:
//         case DocumentType.powerpoint:
//         case DocumentType.unknown:
//           // Non-PDF/non-image → download + hand to OS via share intent.
//           // If you don't need this, just show an error.
//           _showError('Unsupported preview — open externally is disabled.');
//           break;
//       }
//     });
//   }

//   // ═════════════════════════════════════════════════════════════
//   // PDF — download with cookies, render from memory
//   // ═════════════════════════════════════════════════════════════
//   Future<void> _loadPdf() async {
//     if (mounted) {
//       setState(() {
//         _isLoadingPdf = true;
//         _pdfError = null;
//       });
//     }

//     try {
//       final dioClient = await DioClient.create();
//       final response = await dioClient.dio.get<List<int>>(
//         widget.url,
//         options: Options(
//           responseType: ResponseType.bytes,
//           followRedirects: true,
//           validateStatus: (status) => status != null && status < 500,
//         ),
//       );

//       debugPrint(
//         'PDF fetch → status=${response.statusCode} '
//         'content-type=${response.headers.value('content-type')} '
//         'length=${response.data?.length}',
//       );

//       if (response.statusCode != 200 || response.data == null) {
//         throw Exception('HTTP ${response.statusCode}');
//       }

//       final bytes = Uint8List.fromList(response.data!);
//       if (bytes.isEmpty) throw Exception('Empty PDF');

//       // Sanity check: real PDFs start with "%PDF"
//       if (bytes.length < 5 ||
//           bytes[0] != 0x25 || // %
//           bytes[1] != 0x50 || // P
//           bytes[2] != 0x44 || // D
//           bytes[3] != 0x46) {
//         // Not a PDF — backend probably returned an HTML login page.
//         final head = String.fromCharCodes(bytes.take(200))
//             .replaceAll('\n', ' ');
//         debugPrint('Non-PDF response head: $head');
//         throw Exception(
//           'Server did not return a PDF. Check your session / permissions.',
//         );
//       }

//       if (!mounted) return;
//       setState(() {
//         _pdfBytes = bytes;
//         _isLoadingPdf = false;
//       });
//     } catch (e) {
//       debugPrint('PDF load failed: $e');
//       if (!mounted) return;
//       setState(() {
//         _isLoadingPdf = false;
//         _pdfError = _cleanError(e);
//       });
//     }
//   }

//   // ═════════════════════════════════════════════════════════════
//   // Image — same approach
//   // ═════════════════════════════════════════════════════════════
//   Future<void> _loadImage() async {
//     if (mounted) {
//       setState(() {
//         _isLoadingImage = true;
//         _imageError = null;
//       });
//     }

//     try {
//       final dioClient = await DioClient.create();
//       final response = await dioClient.dio.get<List<int>>(
//         widget.url,
//         options: Options(
//           responseType: ResponseType.bytes,
//           followRedirects: true,
//           validateStatus: (status) => status != null && status < 500,
//         ),
//       );

//       if (response.statusCode != 200 || response.data == null) {
//         throw Exception('HTTP ${response.statusCode}');
//       }

//       final bytes = Uint8List.fromList(response.data!);

//       if (!mounted) return;
//       setState(() {
//         _imageBytes = bytes;
//         _isLoadingImage = false;
//       });
//     } catch (e) {
//       debugPrint('Image load failed: $e');
//       if (!mounted) return;
//       setState(() {
//         _isLoadingImage = false;
//         _imageError = _cleanError(e);
//       });
//     }
//   }

//   String _cleanError(Object e) {
//     return e
//         .toString()
//         .replaceFirst('Exception: ', '')
//         .replaceFirst('DioException [bad response]: ', '');
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//     Navigator.pop(context);
//   }

//   // ═════════════════════════════════════════════════════════════
//   // BUILD
//   // ═════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final type = DocumentViewerUtils.getDocumentType(widget.url);

//     switch (type) {
//       case DocumentType.image:
//         return _buildImageViewer();
//       case DocumentType.pdf:
//         return _buildPdfViewer();
//       case DocumentType.word:
//       case DocumentType.excel:
//       case DocumentType.powerpoint:
//       case DocumentType.unknown:
//         return Scaffold(
//           appBar: AppBar(title: Text(widget.title ?? 'Document')),
//           body: const Center(child: CircularProgressIndicator()),
//         );
//     }
//   }

//   Widget _buildImageViewer() {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title ?? 'Image')),
//       body: _buildImageBody(),
//     );
//   }

//   Widget _buildImageBody() {
//     if (_isLoadingImage) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_imageError != null || _imageBytes == null) {
//       return _buildErrorState(
//         message: _imageError ?? 'Could not load image',
//         onRetry: _loadImage,
//       );
//     }
//     return InteractiveViewer(
//       minScale: 0.5,
//       maxScale: 4,
//       child: Center(
//         child: Image.memory(
//           _imageBytes!,
//           fit: BoxFit.contain,
//           errorBuilder: (_, __, ___) =>
//               const Center(child: Text('Could not load image')),
//         ),
//       ),
//     );
//   }

//   Widget _buildPdfViewer() {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title ?? 'PDF')),
//       body: _buildPdfBody(),
//     );
//   }

//   Widget _buildPdfBody() {
//     if (_isLoadingPdf) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_pdfError != null || _pdfBytes == null) {
//       return _buildErrorState(
//         message: _pdfError ?? 'Could not load PDF',
//         onRetry: _loadPdf,
//       );
//     }

//     //    In-app rendering, no browser, no Frappe page.
//     return SfPdfViewer.memory(
//       _pdfBytes!,
//       canShowScrollHead: true,
//       canShowScrollStatus: true,
//     );
//   }

//   Widget _buildErrorState({
//     required String message,
//     required Future<void> Function() onRetry,
//   }) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline_rounded, size: 48),
//             const SizedBox(height: 12),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () => onRetry(),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:little_heroes_mobile/core/services/document_cache_service.dart';

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
  File? _pdfFile; // ← use file directly when available
  bool _isLoadingPdf = false;
  bool _isOfflinePdf = false; // ← show badge when loaded from cache
  String? _pdfError;

  Uint8List? _imageBytes;
  bool _isLoadingImage = false;
  bool _isOfflineImage = false;
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
          _showError('Unsupported preview type');
          break;
      }
    });
  }

  // ══════════════════════════════════════════════════
  // PDF
  // ══════════════════════════════════════════════════

  Future<void> _loadPdf() async {
    setState(() {
      _isLoadingPdf = true;
      _pdfError = null;
    });

    final cache = DocumentCacheService.instance;

    // 1️⃣ Try cache first — instant
    final cachedFile = await cache.getCached(widget.url, isPdf: true);
    if (cachedFile != null && mounted) {
      setState(() {
        _pdfFile = cachedFile;
        _isOfflinePdf = true;
        _isLoadingPdf = false;
      });
    }

    // 2️⃣ Fetch fresh (with cookies) — will fall back to cache if offline
    try {
      final file = await cache.fetchAndCache(widget.url, isPdf: true);
      if (!mounted) return;

      // Only flip offline flag off if this is a fresh download
      // (fetchAndCache returns the cache when the network failed)
      final wasFresh =
          DateTime.now().difference(await file.lastModified()).inSeconds < 5;

      setState(() {
        _pdfFile = file;
        _pdfBytes = null;
        _isLoadingPdf = false;
        _isOfflinePdf = !wasFresh;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPdf = false;
        _pdfError = _cleanError(e);
      });
    }
  }

  // ══════════════════════════════════════════════════
  // Image
  // ══════════════════════════════════════════════════

  Future<void> _loadImage() async {
    setState(() {
      _isLoadingImage = true;
      _imageError = null;
    });

    final cache = DocumentCacheService.instance;

    final cachedBytes = await cache.getCachedBytes(widget.url, isPdf: false);
    if (cachedBytes != null && mounted) {
      setState(() {
        _imageBytes = cachedBytes;
        _isOfflineImage = true;
        _isLoadingImage = false;
      });
    }

    try {
      final file = await cache.fetchAndCache(widget.url, isPdf: false);
      final bytes = await file.readAsBytes();
      if (!mounted) return;

      final wasFresh =
          DateTime.now().difference(await file.lastModified()).inSeconds < 5;

      setState(() {
        _imageBytes = bytes;
        _isLoadingImage = false;
        _isOfflineImage = !wasFresh;
      });
    } catch (e) {
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

  // ══════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final type = DocumentViewerUtils.getDocumentType(widget.url);

    switch (type) {
      case DocumentType.image:
        return _buildImageViewer();
      case DocumentType.pdf:
        return _buildPdfViewer();
      default:
        return Scaffold(
          appBar: AppBar(title: Text(widget.title ?? 'Document')),
          body: const Center(child: CircularProgressIndicator()),
        );
    }
  }

  Widget _buildImageViewer() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Image'),
        actions: [
          if (_isOfflineImage)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: _OfflineBadge()),
            ),
        ],
      ),
      body: _buildImageBody(),
    );
  }

  Widget _buildImageBody() {
    if (_isLoadingImage && _imageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_imageError != null && _imageBytes == null) {
      return _buildErrorState(message: _imageError!, onRetry: _loadImage);
    }
    if (_imageBytes == null) {
      return _buildErrorState(
        message: 'Could not load image',
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
      appBar: AppBar(
        title: Text(widget.title ?? 'PDF'),
        actions: [
          if (_isOfflinePdf)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: _OfflineBadge()),
            ),
        ],
      ),
      body: _buildPdfBody(),
    );
  }

  Widget _buildPdfBody() {
    if (_isLoadingPdf && _pdfFile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pdfError != null && _pdfFile == null) {
      return _buildErrorState(message: _pdfError!, onRetry: _loadPdf);
    }

    if (_pdfFile == null) {
      return _buildErrorState(message: 'Could not load PDF', onRetry: _loadPdf);
    }

    // File-based viewing → works offline, fast on re-open.
    return SfPdfViewer.file(
      _pdfFile!,
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

// ═══════════════════════════════════════════════════════════════
// Offline badge
// ═══════════════════════════════════════════════════════════════

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 12, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
