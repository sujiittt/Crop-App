// lib/presentation/dashboard_screen/widgets/task_card_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class TaskCardWidget extends StatelessWidget {
  /// Expecting a list where each task at least has:
  ///  - title (String)
  ///  - description/subtitle (String? optional)
  ///  - priority (String) e.g. 'high', 'medium', 'low'
  /// Any other keys are ignored.
  final List<dynamic> tasks;

  const TaskCardWidget({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visible = tasks.take(3).toList(); // show up to 3 like the mock
    final total = tasks.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.task_alt,
                      size: 20, color: AppTheme.lightTheme.primaryColor),
                  SizedBox(width: 2.w),
                  Text(
                    "Today's Tasks",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Items
              ...visible.map((t) => _TaskRow(
                title: _readString(t, ['title', 'name']),
                subtitle: _readString(t, ['description', 'subtitle']),
                priority: _readString(t, ['priority'])?.toLowerCase() ?? 'low',
                onTap: () => _openTasks(context),
              )),

              // Bottom buttons
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openTasks(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Task'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.4.h),
                        side: BorderSide(
                          color: AppTheme.lightTheme.primaryColor,
                          width: 1.2,
                        ),
                        foregroundColor: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _openTasks(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        foregroundColor: AppTheme.lightTheme.primaryColor,
                      ),
                      child: Text('View All Tasks ($total)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _openTasks(BuildContext context) {
    Navigator.pushNamed(context, '/tasks-screen');
  }

  static String? _readString(dynamic obj, List<String> keys) {
    if (obj is Map) {
      for (final k in keys) {
        final v = obj[k];
        if (v is String && v.trim().isNotEmpty) return v;
      }
    }
    // add support for simple models if needed later
    return null;
  }
}

class _TaskRow extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String priority;
  final VoidCallback onTap;

  const _TaskRow({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.onTap,
  }) : super(key: key);

  Color get _barColor {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return AppTheme.getSuccessColor();
    }
  }

  String get _pillText {
    switch (priority) {
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MEDIUM';
      default:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.only(bottom: 1.6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // colored vertical bar
            Container(
              width: 3,
              height: 4.8.h,
              decoration: BoxDecoration(
                color: _barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 3.w),

            // text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Untitled Task',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    SizedBox(height: 0.4.h),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 2.w),

            // priority pill at right
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
              decoration: BoxDecoration(
                color: _barColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _barColor.withOpacity(0.4)),
              ),
              child: Text(
                _pillText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _barColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
