// lib/data/task_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class TaskStorage {
  TaskStorage._privateConstructor();

  static final TaskStorage instance = TaskStorage._privateConstructor();

  static const _prefsKey = 'cropwise_tasks_v1';
  final _uuid = const Uuid();

  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<TaskModel>> loadAll() async {
    await _ensurePrefs();
    final raw = _prefs!.getString(_prefsKey);
    return TaskModel.listFromJsonString(raw);
  }

  Future<void> saveAll(List<TaskModel> tasks) async {
    await _ensurePrefs();
    final raw = TaskModel.listToJsonString(tasks);
    await _prefs!.setString(_prefsKey, raw);
  }

  Future<TaskModel> addTask({
    required String title,
    required String type,
    required DateTime dateTime,
    String? fieldId,
    String? cropLabel,
    String? notes,
  }) async {
    await _ensurePrefs();
    final tasks = await loadAll();
    final id = _uuid.v4();
    final model = TaskModel(
      id: id,
      title: title,
      type: type,
      dateTime: dateTime,
      fieldId: fieldId,
      cropLabel: cropLabel,
      notes: notes,
    );
    tasks.add(model);
    await saveAll(tasks);
    return model;
  }

  Future<bool> updateTask(TaskModel updated) async {
    await _ensurePrefs();
    final tasks = await loadAll();
    final idx = tasks.indexWhere((t) => t.id == updated.id);
    if (idx < 0) return false;
    tasks[idx] = updated;
    await saveAll(tasks);
    return true;
  }

  Future<bool> deleteTask(String id) async {
    await _ensurePrefs();
    final tasks = await loadAll();
    final newList = tasks.where((t) => t.id != id).toList();
    if (newList.length == tasks.length) return false;
    await saveAll(newList);
    return true;
  }

  Future<bool> setStatus(String id, TaskStatus status) async {
    await _ensurePrefs();
    final tasks = await loadAll();
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return false;
    tasks[idx] = tasks[idx].copyWith(status: status);
    await saveAll(tasks);
    return true;
  }

  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    await _ensurePrefs();
    final tasks = await loadAll();
    final yyyy = date.year;
    final mm = date.month;
    final dd = date.day;
    return tasks.where((t) {
      final d = t.dateTime;
      return d.year == yyyy && d.month == mm && d.day == dd;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<List<TaskModel>> getUpcoming({int limit = 20}) async {
    await _ensurePrefs();
    final tasks = await loadAll();
    final now = DateTime.now();
    final upcoming = tasks.where((t) => t.dateTime.isAfter(now) && t.status == TaskStatus.pending).toList();
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    if (upcoming.length <= limit) return upcoming;
    return upcoming.sublist(0, limit);
  }
}
