import '../../core/network/json.dart';

enum TaskStatus { todo, inProgress, done, cancelled, unknown }

TaskStatus taskStatusFromInt(int v) => switch (v) {
      1 => TaskStatus.todo,
      2 => TaskStatus.inProgress,
      3 => TaskStatus.done,
      4 => TaskStatus.cancelled,
      _ => TaskStatus.unknown,
    };

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'To do',
        TaskStatus.inProgress => 'In progress',
        TaskStatus.done => 'Done',
        TaskStatus.cancelled => 'Cancelled',
        TaskStatus.unknown => 'Unknown',
      };
  bool get isOpen => this == TaskStatus.todo || this == TaskStatus.inProgress;
}

enum TaskPriority { low, medium, high, unknown }

TaskPriority taskPriorityFromInt(int v) => switch (v) {
      1 => TaskPriority.low,
      2 => TaskPriority.medium,
      3 => TaskPriority.high,
      _ => TaskPriority.unknown,
    };

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
        TaskPriority.unknown => '',
      };
}

class CrmTask {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? assignedToUserName;
  final String? dealTitle;

  const CrmTask({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.description,
    this.dueDate,
    this.assignedToUserName,
    this.dealTitle,
  });

  factory CrmTask.fromJson(Map<String, dynamic> j) => CrmTask(
        id: str(j, 'id') ?? '',
        title: str(j, 'title') ?? 'Task',
        description: str(j, 'description'),
        status: taskStatusFromInt(intOr(j, 'status', 1)),
        priority: taskPriorityFromInt(intOr(j, 'priority', 2)),
        dueDate: dateOrNull(j, 'dueDate'),
        assignedToUserName: str(j, 'assignedToUserName'),
        dealTitle: str(j, 'dealTitle'),
      );
}
