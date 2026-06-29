import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/json.dart';

/// Accumulating list state for infinite scroll.
class PagedState<T> {
  final List<T> items;
  final bool initialLoading;
  final bool loadingMore;
  final bool hasMore;
  final Object? error;

  const PagedState({
    this.items = const [],
    this.initialLoading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PagedState<T> copyWith({
    List<T>? items,
    bool? initialLoading,
    bool? loadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) =>
      PagedState<T>(
        items: items ?? this.items,
        initialLoading: initialLoading ?? this.initialLoading,
        loadingMore: loadingMore ?? this.loadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Base notifier for a filtered, page-accumulating list. Subclasses implement
/// [fetch] (reading their own filter providers via `ref`); changing a watched
/// filter inside [fetch]'s deps should be done in [build] so the list resets.
abstract class PagedListNotifier<T> extends AutoDisposeNotifier<PagedState<T>> {
  static const pageSize = 20;
  int _page = 1;

  /// Fetch one page. Implement in the subclass; read filters via `ref`.
  Future<Paged<T>> fetch(int page, int pageSize);

  @override
  PagedState<T> build() {
    // Kick off the first page after the provider is constructed.
    Future.microtask(refresh);
    return const PagedState(initialLoading: true);
  }

  Future<void> refresh() async {
    _page = 1;
    state = const PagedState(initialLoading: true);
    try {
      final res = await fetch(_page, pageSize);
      state = PagedState(items: res.items, hasMore: res.items.length >= pageSize);
    } catch (e) {
      state = PagedState(error: e, hasMore: false);
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s.loadingMore || !s.hasMore || s.initialLoading) return;
    state = s.copyWith(loadingMore: true);
    try {
      final next = _page + 1;
      final res = await fetch(next, pageSize);
      _page = next;
      state = state.copyWith(
        items: [...state.items, ...res.items],
        loadingMore: false,
        hasMore: res.items.length >= pageSize,
      );
    } catch (e) {
      // Keep what we have; stop paging on error.
      state = state.copyWith(loadingMore: false, hasMore: false);
    }
  }
}
