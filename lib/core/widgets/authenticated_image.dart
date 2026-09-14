import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/network/dio_client.dart';
import 'package:little_heroes_mobile/core/widgets/image_cache_store.dart';

class AuthenticatedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // ✅ Instant hit from cache — no async, no flicker.
    final cached = ImageCacheStore.get(widget.imageUrl);
    if (cached != null) {
      _imageBytes = cached;
      _isLoading = false;
      return;
    }

    _loadImage();
  }

  @override
  void didUpdateWidget(AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      final cached = ImageCacheStore.get(widget.imageUrl);
      if (cached != null) {
        setState(() {
          _imageBytes = cached;
          _isLoading = false;
          _hasError = false;
        });
        return;
      }
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      // ✅ ImageCacheStore.fetch dedupes concurrent requests for same URL
      final bytes = await ImageCacheStore.fetch(widget.imageUrl, () async {
        final dioClient = await DioClient.create();
        final dio = dioClient.dio;

        final response = await dio.get(
          widget.imageUrl,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'Accept': 'image/*'},
            followRedirects: true,
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          return Uint8List.fromList(response.data as List<int>);
        }
        throw Exception('Image load failed: status ${response.statusCode}');
      });

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Authenticated image error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget imageWidget;

    if (_isLoading) {
      imageWidget =
          widget.placeholder ??
          Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    } else if (_hasError || _imageBytes == null) {
      imageWidget =
          widget.errorWidget ??
          Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
    } else {
      imageWidget = Image.memory(
        _imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ??
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
        },
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: imageWidget,
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: imageWidget,
    );
  }
}
