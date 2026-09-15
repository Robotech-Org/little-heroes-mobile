import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/widgets/authenticated_image.dart';
import 'package:little_heroes_mobile/features/home/domain/entities/gallery_item.dart';

class GalleryPhotoViewPage extends StatefulWidget {
  final GalleryItem item;
  final int index;
  final int totalItems;

  const GalleryPhotoViewPage({
    super.key,
    required this.item,
    required this.index,
    required this.totalItems,
  });

  @override
  State<GalleryPhotoViewPage> createState() => _GalleryPhotoViewPageState();
}

class _GalleryPhotoViewPageState extends State<GalleryPhotoViewPage> {
  final _transformController = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.01;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  /// Double-tap toggles between 1x and 2.5x centered on the tap point.
  void _handleDoubleTap() {
    if (_isZoomed) {
      _resetZoom();
    } else {
      _transformController.value = Matrix4.identity()..scale(2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatDate(item.momentDate),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Show reset button only when zoomed
          if (_isZoomed)
            IconButton(
              tooltip: 'Reset zoom',
              icon: const Icon(Icons.zoom_out_map_rounded),
              onPressed: _resetZoom,
            ),
        ],
      ),
      body: Column(
        children: [
          // Image with pinch-to-zoom support
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                //   reduced from 20 → 8
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 1.0,
                  maxScale: 5.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: AuthenticatedImage(
                    imageUrl: item.photoUrl,
                    fit: BoxFit.contain,
                    //   no radius on the image itself — parent clips
                    borderRadius: BorderRadius.zero,
                    placeholder: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Loading image...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    errorWidget: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 80,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Unable to load image',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Details
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateFull(item.momentDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teacher: ${item.teacher}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Text(
                      item.notes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Photo ${widget.index + 1} of ${widget.totalItems}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateFull(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
