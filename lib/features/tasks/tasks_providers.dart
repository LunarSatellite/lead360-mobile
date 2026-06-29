import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../../core/providers.dart';
import '../../shared/paged_list.dart';
import 'task_model.dart';

class TasksRepository {
  TasksRepository(this._api);
  final ApiClient _api;

  Future<Paged<CrmTask>> list({int page = 1, int pageSize = 30, String? search, TaskStatus? status}) async {
    final res = await _api.dio.get('/v1/crm/tasks', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status != TaskStatus.unknown) 'status': _statusRaw(status),
    });
    if (res.statusCode == 200 && res.data is Map) {
      return Paged.fromJson(Map<String, dynamic>.from(res.data), CrmTask.fromJson);
    }
    throw DioException(requestOptions: res.requestOptions, response: res, error: 'Failed to load tasks');
  }

  /// POST /v1/crm/tasks/{id}/complete
  Future<void> complete(String id) async {
    await _api.dio.post('/v1/crm/tasks/$id/complete', data: {'completionNotes': null});
  }

  static int _statusRaw(TaskStatus s) => switch (s) {
        TaskStatus.todo => 1,
        TaskStatus.inProgress => 2,
        TaskStatus.done => 3,
        TaskStatus.cancelled => 4,
        TaskStatus.unknown => 0,
      };
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) => TasksRepository(ref.read(apiClientProvider)));

/// null = all; otherwise filter.
final tasksStatusProvider = StateProvider<TaskStatus?>((ref) => null);

class TasksPaged extends PagedListNotifier<CrmTask> {
  @override
  PagedState<CrmTask> build() {
    ref.watch(tasksStatusProvider);
    return super.build();
  }

  @override
  Future<Paged<CrmTask>> fetch(int page, int pageSize) =>
      ref.read(tasksRepositoryProvider).list(page: page, pageSize: pageSize, status: ref.read(tasksStatusProvider));
}

final tasksPagedProvider = AutoDisposeNotifierProvider<TasksPaged, PagedState<CrmTask>>(TasksPaged.new);
