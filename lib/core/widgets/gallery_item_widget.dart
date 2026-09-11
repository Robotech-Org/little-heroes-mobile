// // lib/core/widgets/gallery_item_widget.dart
// import 'package:flutter/material.dart';

// import '../../features/home/domain/entities/gallery_item.dart';

// class GalleryItemWidget extends StatelessWidget {
//   final GalleryItem item;
//   final int index;
//   final int totalItems;
//   final VoidCallback onTap;

//   const GalleryItemWidget({
//     super.key,
//     required this.item,
//     required this.index,
//     required this.totalItems,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(16),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: Ink(
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surfaceContainerHighest,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Stack(
//             children: [
//               // Image or placeholder
//               if (item.photoUrl.isNotEmpty)
//                 Image.network(
//                   item.photoUrl,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Center(
//                       child: Icon(
//                         Icons.image_outlined,
//                         size: 42,
//                         color: theme.colorScheme.primary,
//                       ),
//                     );
//                   },
//                 )
//               else
//                 Center(
//                   child: Icon(
//                     Icons.image_outlined,
//                     size: 42,
//                     color: theme.colorScheme.primary,
//                   ),
//                 ),

//               // Date badge
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withValues(alpha: 0.6),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     _formatDate(item.momentDate),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),

//               // Notes overlay (bottom)
//               if (item.notes != null && item.notes!.isNotEmpty)
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withValues(alpha: 0.7),
//                         ],
//                       ),
//                     ),
//                     child: Text(
//                       item.notes!,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${months[date.month - 1]} ${date.day}';
//   }
// }

// lib/core/widgets/gallery_item_widget.dart

import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/widgets/authenticated_image.dart';
import 'package:little_heroes_mobile/features/home/domain/entities/gallery_item.dart';

class GalleryItemWidget extends StatelessWidget {
  final GalleryItem item;
  final int index;
  final int totalItems;
  final VoidCallback onTap;

  const GalleryItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.totalItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            //   Loads image with session cookies
            AuthenticatedImage(
              imageUrl: item.photoUrl,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(16),
              placeholder: Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: Container(
                color: colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 36,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            // Gradient overlay + caption
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(item.momentDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty)
                      Text(
                        item.notes!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
}
