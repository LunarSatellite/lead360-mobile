import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../paged_list.dart';
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
  });

  final PagedState<T> state;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onLoadMore;
  final Future<void> Function() onRefresh;
  final String emptyText;

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
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 34),
          const SizedBox(height: 10),
          const Text('Something went wrong.', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 14),
          FilledButton(onPressed: widget.onRefresh, child: const Text('Retry')),
        ]),
      );
    }

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: widget.onRefresh,
      child: s.items.isEmpty
          ? ListView(children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(child: Text(widget.emptyText, style: const TextStyle(color: AppColors.textMuted))),
              ),
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
                return widget.itemBuilder(context, s.items[i]);
              },
            ),
    );
  }
}
