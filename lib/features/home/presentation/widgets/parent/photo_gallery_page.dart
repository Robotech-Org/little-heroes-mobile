import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/widgets/gallery_item_widget.dart';
import 'package:little_heroes_mobile/core/widgets/little_heroes_loading.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/gallery_photo_view_page.dart';

import '../../bloc/gallery_bloc.dart';
import '../../bloc/gallery_event.dart';
import '../../bloc/gallery_state.dart';

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<GalleryBloc>().state;
      if (state is GalleryLoaded && state.hasMore) {
        context.read<GalleryBloc>().add(
          LoadGalleryItems(page: state.currentPage + 1),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Photo Gallery',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        if (state is GalleryInitial) {
          context.read<GalleryBloc>().add(LoadGalleryItems());
          return const SliverToBoxAdapter(
            child: LittleHeroesLoading(message: 'Loading gallery...'),
          );
        }

        if (state is GalleryLoading) {
          // Check if we have a previous loaded state with items
          final previousState = context.read<GalleryBloc>().state;
          if (previousState is GalleryLoaded) {
            // If we already have items, show the grid with a loading indicator
            return _buildGalleryGridWithLoading(theme, previousState);
          }
          return const SliverToBoxAdapter(
            child: LittleHeroesLoading(message: 'Loading gallery...'),
          );
        }

        if (state is GalleryLoaded) {
          return _buildGalleryGrid(theme, state);
        }

        if (state is GalleryError) {
          return SliverToBoxAdapter(
            child: _buildErrorWidget(theme, state.message),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  // New method for grid with loading indicator at bottom
  Widget _buildGalleryGridWithLoading(ThemeData theme, GalleryLoaded state) {
    if (state.items.isEmpty) {
      return const SliverToBoxAdapter(
        child: LittleHeroesLoading(message: 'Loading gallery...'),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Grid of items
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            return GalleryItemWidget(
              item: item,
              index: index,
              totalItems: state.items.length,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GalleryPhotoViewPage(
                      item: item,
                      index: index,
                      totalItems: state.items.length,
                    ),
                  ),
                );
              },
            );
          },
        ),
        // Loading indicator at bottom
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildGalleryGrid(ThemeData theme, GalleryLoaded state) {
    if (state.items.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyWidget(theme));
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = state.items[index];
        return GalleryItemWidget(
          item: item,
          index: index,
          totalItems: state.items.length,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GalleryPhotoViewPage(
                  item: item,
                  index: index,
                  totalItems: state.items.length,
                ),
              ),
            );
          },
        );
      }, childCount: state.items.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load photos',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<GalleryBloc>().add(RefreshGalleryItems());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No Photos Yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Photos from your child\'s moments will appear here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
