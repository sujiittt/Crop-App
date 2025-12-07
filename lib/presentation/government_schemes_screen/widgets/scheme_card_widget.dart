import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SchemeCardWidget extends StatelessWidget {
  final Map<String, dynamic> scheme;
  final VoidCallback onTap;
  final VoidCallback onCheckEligibility;
  final VoidCallback onStartApplication;
  final VoidCallback onSetReminder;
  final VoidCallback onShare;

  const SchemeCardWidget({
    Key? key,
    required this.scheme,
    required this.onTap,
    required this.onCheckEligibility,
    required this.onStartApplication,
    required this.onSetReminder,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // small fixed spacers – avoid fractional heights that cause 0.2px overflow on some DPRs
    const k2 = SizedBox(height: 2);
    const k4 = SizedBox(height: 4);
    const k6 = SizedBox(height: 6);
    const k8 = SizedBox(height: 8);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8), // 8 px vertical
      child: Slidable(
        key: ValueKey(scheme['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onCheckEligibility(),
              backgroundColor: AppTheme.getAccentColor(),
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: 'Check',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onStartApplication(),
              backgroundColor: AppTheme.lightTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: Icons.assignment,
              label: 'Apply',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onSetReminder(),
              backgroundColor: AppTheme.getWarningColor(),
              foregroundColor: Colors.white,
              icon: Icons.alarm,
              label: 'Remind',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onShare(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias, // ensure nothing paints outside
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              // integer paddings only
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min, // size to content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top chips: use Wrap to avoid forcing vertical stretch
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _Chip(
                        text: scheme['category'] as String,
                        color: _getCategoryColor(scheme['category'] as String),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEligibilityColor(scheme['eligibilityStatus'] as String)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName:
                              _getEligibilityIcon(scheme['eligibilityStatus'] as String),
                              size: 14,
                              color:
                              _getEligibilityColor(scheme['eligibilityStatus'] as String),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              scheme['eligibilityStatus'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _getEligibilityColor(
                                    scheme['eligibilityStatus'] as String),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  k8,

                  // Title
                  Text(
                    scheme['name'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  k4,

                  // Local script name
                  Text(
                    scheme['nameLocal'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  k6,

                  // Short description
                  Text(
                    scheme['description'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  k8,

                  // Benefit & Deadline
                  Row(
                    children: [
                      // Benefit
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maximum Benefit',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            k2,
                            Text(
                              scheme['maxBenefit'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.getSuccessColor(),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Deadline
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Application Deadline',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            k2,
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  size: 14,
                                  color: _isDeadlineNear(scheme['deadline'] as String)
                                      ? AppTheme.getWarningColor()
                                      : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  scheme['deadline'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: _isDeadlineNear(
                                        scheme['deadline'] as String)
                                        ? AppTheme.getWarningColor()
                                        : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // **tiny absorber** to kill sub-pixel “0.238 px” overflows
                  k2,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // helpers
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'subsidies':
        return Colors.green;
      case 'loans':
        return Colors.blue;
      case 'insurance':
        return Colors.orange;
      case 'training programs':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getEligibilityColor(String status) {
    switch (status.toLowerCase()) {
      case 'eligible':
        return Colors.green;
      case 'not eligible':
        return Colors.red;
      case 'pending review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getEligibilityIcon(String status) {
    switch (status.toLowerCase()) {
      case 'eligible':
        return 'check_circle';
      case 'not eligible':
        return 'cancel';
      case 'pending review':
        return 'schedule';
      default:
        return 'help';
    }
  }

  bool _isDeadlineNear(String deadline) {
    try {
      final parts = deadline.split('/');
      if (parts.length == 3) {
        final deadlineDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final now = DateTime.now();
        final diff = deadlineDate.difference(now).inDays;
        return diff <= 30 && diff >= 0;
      }
    } catch (_) {}
    return false;
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
