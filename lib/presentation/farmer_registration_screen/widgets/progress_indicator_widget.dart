import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Safety guards (no UI change)
    final int steps = (totalSteps <= 0) ? 1 : totalSteps;
    final int current = currentStep.clamp(1, steps);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Step $current of $steps',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Progress Bar
          Row(
            children: List.generate(steps, (index) {
              final bool isCompleted = index < current - 1;
              final bool isCurrent = index == current - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: (isCompleted || isCurrent)
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme.lightTheme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < steps - 1) SizedBox(width: 1.w),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),

          // Step Labels with circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps, (index) {
              final bool isCompleted = index < current - 1;
              final bool isCurrent = index == current - 1;

              final String? label =
              (index < stepLabels.length) ? stepLabels[index] : null;

              return Expanded(
                child: Row(
                  children: [
                    // Step Circle
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.getSuccessColor(true)
                            : isCurrent
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.dividerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? CustomIconWidget(
                          iconName: 'check',
                          color: Colors.white,
                          size: 16,
                        )
                            : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.white
                                : AppTheme.lightTheme.colorScheme
                                .onSurfaceVariant,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Step Label (optional)
                    if (label != null) ...[
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                            color: isCurrent
                                ? AppTheme.lightTheme.primaryColor
                                : isCompleted
                                ? AppTheme.getSuccessColor(true)
                                : AppTheme.lightTheme.colorScheme
                                .onSurfaceVariant,
                            fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
