// lib/features/home/presentation/bloc/gallery_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gallery_item.dart';
import '../../domain/usecases/get_gallery_items.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GetGalleryItems getGalleryItems;

  GalleryBloc({required this.getGalleryItems}) : super(GalleryInitial()) {
    on<LoadGalleryItems>(_onLoadGalleryItems);
    on<RefreshGalleryItems>(_onRefreshGalleryItems);
  }

  Future<void> _onLoadGalleryItems(
    LoadGalleryItems event,
    Emitter<GalleryState> emit,
  ) async {
    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
      if (!currentState.hasMore) return;
      emit(GalleryLoading());
    } else {
      emit(GalleryLoading());
    }

    try {
      final response = await getGalleryItems(
        page: event.page,
        pageSize: event.pageSize,
      );

      final items = response.items.map((model) {
        return GalleryItem(
          id: model.name,
          momentId: model.moment,
          studentId: model.taggedStudent,
          parentId: model.parentLink,
          teacher: model.teacher,
          photoUrl: model.galleryPhoto,
          momentDate: DateTime.tryParse(model.momentDate) ?? DateTime.now(),
          notes: model.galleryNotes,
          studentName: model.studentName,
        );
      }).toList();

      final hasMore = response.page * response.pageSize < response.total;

      if (state is GalleryLoaded) {
        final currentState = state as GalleryLoaded;
        final allItems = [...currentState.items, ...items];
        emit(
          GalleryLoaded(
            items: allItems,
            total: response.total,
            currentPage: response.page,
            hasMore: hasMore,
          ),
        );
      } else {
        emit(
          GalleryLoaded(
            items: items,
            total: response.total,
            currentPage: response.page,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      emit(GalleryError(e.toString()));
    }
  }

  Future<void> _onRefreshGalleryItems(
    RefreshGalleryItems event,
    Emitter<GalleryState> emit,
  ) async {
    add(LoadGalleryItems(page: 1));
  }
}
