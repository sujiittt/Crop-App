// lib/presentation/tasks_screen/tasks_screen.dart
import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../data/task_storage.dart';
import '../../models/task_types.dart';
import 'add_task/add_task_sheet.dart';
import 'widgets/task_item.dart';
import 'widgets/task_detail_sheet.dart';

class TasksScreen extends StatefulWidget {
  static const routeName = '/tasks-screen';
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<TaskModel> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final all = await TaskStorage.instance.loadAll();
      all.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      setState(() {
        _tasks = all;
      });
    } catch (_) {
      setState(() {
        _tasks = [];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TaskModel> _tasksForDate(DateTime date) {
    return _tasks.where((t) {
      final d = t.dateTime;
      return d.year == date.year && d.month == date.month && d.day == date.day && t.status == TaskStatus.pending;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<TaskModel> get _todayTasks {
    final today = DateTime.now();
    return _tasksForDate(DateTime(today.year, today.month, today.day));
  }

  List<TaskModel> get _upcomingTasks {
    final now = DateTime.now();
    return _tasks.where((t) => t.dateTime.isAfter(DateTime(now.year, now.month, now.day)) && t.status == TaskStatus.pending).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<TaskModel> get _completedTasks {
    return _tasks.where((t) => t.status == TaskStatus.completed).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> _openAddTask({String? fieldId, String? cropLabel, String? stageName}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => AddTaskSheet(
        prefillFieldId: fieldId,
        prefillCropLabel: cropLabel,
        prefillStageName: stageName,
      ),
    );
    if (saved == true) await _loadTasks();
  }

  Future<void> _openTaskDetail(TaskModel task) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => TaskDetailSheet(task: task),
    );
    // result can be {'action': 'deleted'} or {'action': 'updated'} etc.
    if (result != null) {
      await _loadTasks();
      final action = result['action'] as String?;
      if (action == 'deleted') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
      } else if (action == 'updated' || action == 'status_changed') {
        // optionally show brief feedback
      }
    }
  }

  Widget _section(String title, List<TaskModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        ...items.map((t) => TaskItem(
          task: t,
          onTap: () => _openTaskDetail(t),
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Add task',
            icon: const Icon(Icons.add),
            onPressed: () => _openAddTask(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_todayTasks.isNotEmpty) _section('Today', _todayTasks),
              if (_upcomingTasks.isNotEmpty) _section('Upcoming', _upcomingTasks),
              if (_completedTasks.isNotEmpty) _section('Completed', _completedTasks),
              if (_tasks.isEmpty && !_loading)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.event_note_outlined, size: 56, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('No tasks yet', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add first task'),
                          onPressed: () => _openAddTask(),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(),
        child: const Icon(Icons.add),
        tooltip: 'Add task',
      ),
    );
  }
}
