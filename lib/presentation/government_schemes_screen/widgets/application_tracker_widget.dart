import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ApplicationTrackerWidget extends StatelessWidget {
  final List<Map<String, dynamic>> applications;
  final Function(Map<String, dynamic>) onApplicationTap;

  const ApplicationTrackerWidget({
    Key? key,
    required this.applications,
    required this.onApplicationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'assignment',
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Applications Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Start applying for schemes to track your applications here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'track_changes',
                size: 20,
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(width: 2.w),
              Text(
                'Application Tracker',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${applications.length} Active',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Horizontal cards
        SizedBox(
          // give a touch more headroom so tiny rounding never overflows
          height: 26.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return Container(
                width: 70.w,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                child: Card(
                  clipBehavior: Clip.antiAlias, // avoid paint bleeding
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => onApplicationTap(application),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      // tiny bottom padding prevents any sub-pixel overflow
                      padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 4.w + 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status chip + id
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                      application['status'] as String)
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomIconWidget(
                                      iconName: _getStatusIcon(
                                          application['status'] as String),
                                      size: 12,
                                      color: _getStatusColor(
                                          application['status'] as String),
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      application['status'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                        color: _getStatusColor(
                                            application['status']
                                            as String),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                application['applicationId'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1.6.h),

                          // Title
                          Text(
                            application['schemeName'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 0.8.h),

                          // Dates + next step
                          Text(
                            'Applied on: ${application['appliedDate'] as String}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          if (application['nextStep'] != null) ...[
                            Text(
                              'Next Step:',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 0.2.h),
                            Text(
                              application['nextStep'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          // (Instead of Spacer) give fixed, safe breathing space
                          SizedBox(height: 1.0.h),

                          // Progress
                          LinearProgressIndicator(
                            value: _getProgressValue(
                                application['status'] as String),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(
                                  application['status'] as String),
                            ),
                          ),
                          SizedBox(height: 0.8.h),
                          Row(
                            children: [
                              Text(
                                'Progress',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(_getProgressValue(application['status'] as String) * 100).toInt()}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: _getStatusColor(
                                      application['status'] as String),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'under review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'documents required':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'send';
      case 'under review':
        return 'visibility';
      case 'approved':
        return 'check_circle';
      case 'rejected':
        return 'cancel';
      case 'documents required':
        return 'description';
      default:
        return 'help';
    }
  }

  double _getProgressValue(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 0.25;
      case 'under review':
        return 0.5;
      case 'documents required':
        return 0.75;
      case 'approved':
        return 1.0;
      case 'rejected':
        return 1.0;
      default:
        return 0.0;
    }
  }
}
