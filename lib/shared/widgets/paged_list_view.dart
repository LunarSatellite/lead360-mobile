import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../paged_list.dart';
import 'empty_state.dart';
import 'fade_in.dart';
import 'skeleton.dart';

/// Infinite-scroll list bound to a [PagedState]: pull-to-refresh, skeleton on
/// first load, trailing loader while paging, empty + error states.
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    this.emptyText = 'Nothing here yet',
    this.emptyIcon = Icons.inbox_outlined,
  });

  final PagedState<T> state;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onLoadMore;
  final Future<void> Function() onRefresh;
  final String emptyText;
  final IconData emptyIcon;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  final _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 300) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    if (s.initialLoading) return const SkeletonList();

    if (s.error != null && s.items.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Something went wrong',
        subtitle: 'Pull to refresh or try again.',
        actionLabel: 'Retry',
        onAction: widget.onRefresh,
      );
    }

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: widget.onRefresh,
      child: s.items.isEmpty
          ? ListView(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.5,
                  child: EmptyState(icon: widget.emptyIcon, title: widget.emptyText)),
            ])
          : ListView.separated(
              controller: _ctrl,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: s.items.length + (s.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (i >= s.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand))),
                  );
                }
                // Entrance animation only for the first screenful — avoids re-animating on every scroll.
                final card = widget.itemBuilder(context, s.items[i]);
                return i < 8 ? FadeInSlide(child: card) : card;
              },
            ),
    );
  }
}
