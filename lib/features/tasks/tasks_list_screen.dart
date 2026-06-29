import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/skeleton.dart';
import 'task_model.dart';
import 'tasks_providers.dart';

class TasksListScreen extends ConsumerWidget {
  const TasksListScreen({super.key});

  static const _filters = [null, TaskStatus.todo, TaskStatus.inProgress, TaskStatus.done];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(tasksStatusProvider);
    final tasks = ref.watch(tasksListProvider);
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = _filters[i];
              final active = status == s;
              return ChoiceChip(
                label: Text(s?.label ?? 'All'),
                selected: active,
                onSelected: (_) => ref.read(tasksStatusProvider.notifier).state = s,
                showCheckmark: false,
                backgroundColor: AppColors.bgElevated,
                selectedColor: AppColors.brand.withOpacity(0.15),
                labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppColors.brand : AppColors.textSecondary),
                side: BorderSide(color: active ? AppColors.brand : AppColors.borderSubtle, width: 0.5),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () async => ref.invalidate(tasksListProvider),
            child: AsyncView(
              value: tasks,
              onRetry: () => ref.invalidate(tasksListProvider),
              loading: const SkeletonList(),
              data: (paged) => paged.items.isEmpty
                  ? ListView(children: const [Padding(padding: EdgeInsets.only(top: 80), child: Center(child: Text('No tasks', style: TextStyle(color: AppColors.textMuted))))])
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: paged.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _TaskCard(paged.items[i]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard(this.t);
  final CrmTask t;

  Color get _prioColor => switch (t.priority) {
        TaskPriority.high => AppColors.danger,
        TaskPriority.medium => AppColors.warning,
        _ => AppColors.textMuted,
      };

  bool get _overdue => t.status.isOpen && t.dueDate != null && t.dueDate!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glass1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Row(
        children: [
          if (t.status.isOpen)
            IconButton(
              icon: const Icon(Icons.radio_button_unchecked, color: AppColors.textMuted),
              onPressed: () => _complete(context, ref),
            )
          else
            const Icon(Icons.check_circle, color: AppColors.success),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        decoration: t.status.isOpen ? null : TextDecoration.lineThrough)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (t.priority != TaskPriority.unknown) ...[
                      Text(t.priority.label, style: TextStyle(color: _prioColor, fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                    ],
                    if (t.dueDate != null)
                      Text(DateFormat('MMM d').format(t.dueDate!.toLocal()),
                          style: TextStyle(color: _overdue ? AppColors.danger : AppColors.textMuted, fontSize: 11)),
                    if (t.dealTitle != null) ...[
                      const SizedBox(width: 8),
                      Expanded(child: Text(t.dealTitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(tasksRepositoryProvider).complete(t.id);
      ref.invalidate(tasksListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task completed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not complete: $e')));
      }
    }
  }
}
