import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AgriculturalCalendarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;

  const AgriculturalCalendarWidget({
    Key? key,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            "Agricultural Calendar",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 28.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              Color categoryColor;

              switch (recommendation["category"] as String) {
                case "irrigation":
                  categoryColor = Colors.blue;
                  break;
                case "pesticide":
                  categoryColor = Colors.orange;
                  break;
                case "harvesting":
                  categoryColor = AppTheme.getSuccessColor(true);
                  break;
                case "planting":
                  categoryColor = AppTheme.lightTheme.primaryColor;
                  break;
                default:
                  categoryColor = AppTheme.lightTheme.colorScheme.secondary;
              }

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.shadowColor,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: recommendation["icon"] as String,
                              color: categoryColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recommendation["title"] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  (recommendation["category"] as String)
                                      .toUpperCase(),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                  recommendation["priority"] as String)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              (recommendation["priority"] as String)
                                  .toUpperCase(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: _getPriorityColor(
                                    recommendation["priority"] as String),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation["description"] as String,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  icon: 'schedule',
                                  label: 'Best Time',
                                  value: recommendation["bestTime"] as String,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: _buildInfoItem(
                                  icon: 'thermostat',
                                  label: 'Conditions',
                                  value: recommendation["conditions"] as String,
                                ),
                              ),
                            ],
                          ),
                          if (recommendation["weatherDependency"] != null) ...[
                            SizedBox(height: 2.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppTheme.getAccentColor(true)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.getAccentColor(true)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'info',
                                    color: AppTheme.getAccentColor(true),
                                    size: 20,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      "Weather Dependency: ${recommendation["weatherDependency"]}",
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.getAccentColor(true),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "high":
        return AppTheme.lightTheme.colorScheme.error;
      case "medium":
        return AppTheme.getWarningColor(true);
      default:
        return AppTheme.getSuccessColor(true);
    }
  }
}
