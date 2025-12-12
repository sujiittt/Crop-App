// lib/presentation/tasks_screen/widgets/task_detail_sheet.dart
import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../data/task_storage.dart';
import '../../../models/task_types.dart';
import '../add_task/add_task_sheet.dart';

class TaskDetailSheet extends StatefulWidget {
  final TaskModel task;

  const TaskDetailSheet({super.key, required this.task});

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  bool _saving = false;

  Future<void> _deleteTask() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task'),
        content: const Text('Delete this task? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(_, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _saving = true);
    final deleted = await TaskStorage.instance.deleteTask(widget.task.id);
    setState(() => _saving = false);

    if (deleted) {
      Navigator.of(context).pop({'action': 'deleted'});
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not delete task')));
    }
  }

  Future<void> _toggleComplete() async {
    setState(() => _saving = true);

    final newStatus = widget.task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    final ok = await TaskStorage.instance.setStatus(widget.task.id, newStatus);
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop({'action': 'status_changed'});
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not update task status')));
    }
  }

  Future<void> _editTask() async {
    // Opens the AddTaskSheet again but blank (you can add pre-filled version later)
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => AddTaskSheet(
        prefillFieldId: widget.task.fieldId,
        prefillCropLabel: widget.task.cropLabel,
      ),
    );

    if (saved == true) {
      Navigator.of(context).pop({'action': 'updated'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final type = taskTypeFromString(t.type);
    final when = t.dateTime;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Task details',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            ListTile(
              leading: CircleAvatar(child: Icon(type.icon)),
              title: Text(t.title),
              subtitle: Text(
                '${t.cropLabel ?? ''} ${t.fieldId != null ? '• Field ${t.fieldId}' : ''}',
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Scheduled: ${when.day}-${when.month}-${when.year} at '
                    '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}',
              ),
            ),

            if (t.notes != null && t.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Notes:', style: Theme.of(context).textTheme.labelLarge),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(t.notes ?? ''),
              ),
            ],

            const SizedBox(height: 16),

            // ACTION BUTTONS (Material 2: ElevatedButton, OutlinedButton, TextButton)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _toggleComplete,
                    icon: Icon(
                      widget.task.status == TaskStatus.completed
                          ? Icons.undo
                          : Icons.check,
                    ),
                    label: Text(widget.task.status == TaskStatus.completed
                        ? 'Mark Pending'
                        : 'Mark Complete'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _editTask,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _saving ? null : _deleteTask,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
