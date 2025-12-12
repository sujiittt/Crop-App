// lib/presentation/tasks_screen/widgets/task_item.dart
import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../models/task_types.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
  });

  String _timeLabel(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final type = taskTypeFromString(task.type);
    final when = task.dateTime;
    final dateLabel = '${when.day}-${when.month}-${when.year}';
    final timeLabel = _timeLabel(when);
    final subtitle = (task.cropLabel != null ? '${task.cropLabel!} • ' : '') + '${type.label} • ${dateLabel} ${timeLabel}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(type.icon, color: Colors.black87, size: 20),
      ),
      title: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: task.status == TaskStatus.completed
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: onTap,
    );
  }
}
