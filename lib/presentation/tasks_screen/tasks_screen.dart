import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../profile_screen/profile_screen.dart'; // for routeName to profile

class TasksScreen extends StatefulWidget {
  static const routeName = '/tasks-screen';

  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Mock data for now — replace with your real source when ready
  final List<Map<String, dynamic>> _today = const [
    {
      'title': 'Irrigate wheat plot',
      'time': '06:30 AM',
      'priority': 'High',
      'icon': 'water_drop',
      'description': 'Irrigate 0.8 acre on plot A'
    },
    {
      'title': 'Call dealer about urea',
      'time': '11:00 AM',
      'priority': 'Medium',
      'icon': 'call',
      'description': 'Confirm availability and price'
    },
  ];

  final List<Map<String, dynamic>> _upcoming = const [
    {
      'title': 'Spray pesticide (field 2)',
      'date': 'Tomorrow',
      'priority': 'High',
      'icon': 'bug_report',
      'description': 'Aphid control'
    },
    {
      'title': 'Soil sample drop-off',
      'date': 'Mon, 21 Oct',
      'priority': 'Low',
      'icon': 'science',
      'description': 'At local KVK lab'
    },
  ];

  final List<Map<String, dynamic>> _completed = const [
    {
      'title': 'Update Kisan card',
      'date': 'Yesterday',
      'icon': 'check_circle',
      'description': 'Verification done'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () =>
                Navigator.pushNamed(context, ProfileScreen.routeName),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          children: [
            _SectionHeader(title: 'Today'),
            if (_today.isEmpty)
              const _EmptyCard(message: 'No tasks for today')
            else
              ..._today.map((t) => _TaskTile(data: t, isToday: true)),
            SizedBox(height: 2.h),

            _SectionHeader(title: 'Upcoming'),
            if (_upcoming.isEmpty)
              const _EmptyCard(message: 'Nothing scheduled')
            else
              ..._upcoming.map((t) => _TaskTile(data: t)),
            SizedBox(height: 2.h),

            _SectionHeader(title: 'Completed'),
            if (_completed.isEmpty)
              const _EmptyCard(message: 'No completed tasks yet')
            else
              ..._completed.map((t) => _TaskTile(data: t, completed: true)),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Task (coming soon)')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            const Icon(Icons.inbox_outlined),
            SizedBox(width: 3.w),
            Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isToday;
  final bool completed;

  const _TaskTile({
    required this.data,
    this.isToday = false,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final iconName = (data['icon'] as String?) ?? 'task';
    final title = (data['title'] as String?) ?? 'Task';
    final subtitle =
    isToday ? (data['time'] as String? ?? '') : (data['date'] as String? ?? '');
    final priority = (data['priority'] as String?) ?? '';
    final description = (data['description'] as String?) ?? '';

    Color? chipColor;
    switch (priority.toLowerCase()) {
      case 'high':
        chipColor = AppTheme.errorLight;
        break;
      case 'medium':
        chipColor = AppTheme.warningLight;
        break;
      case 'low':
        chipColor = AppTheme.successLight;
        break;
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CustomIconWidget(iconName: iconName, size: 24, color: theme.primaryColor),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle.isNotEmpty) Text(subtitle),
            if (description.isNotEmpty)
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        trailing: completed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (priority.isEmpty
            ? null
            : Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
          decoration: BoxDecoration(
            color: (chipColor ?? theme.colorScheme.surfaceVariant),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            priority.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        )),
        onTap: () {
          // TODO: open task details later
        },
      ),
    );
  }
}
