import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const WeatherAlertsWidget({
    Key? key,
    required this.alerts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            "Weather Alerts",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: alerts.length > 2 ? 25.h : 12.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              Color alertColor;
              Color backgroundColor;

              switch (alert["severity"] as String) {
                case "critical":
                  alertColor = AppTheme.lightTheme.colorScheme.error;
                  backgroundColor = AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.1);
                  break;
                case "high":
                  alertColor = AppTheme.getWarningColor(true);
                  backgroundColor =
                      AppTheme.getWarningColor(true).withValues(alpha: 0.1);
                  break;
                case "medium":
                  alertColor = AppTheme.getAccentColor(true);
                  backgroundColor =
                      AppTheme.getAccentColor(true).withValues(alpha: 0.1);
                  break;
                default:
                  alertColor = AppTheme.getSuccessColor(true);
                  backgroundColor =
                      AppTheme.getSuccessColor(true).withValues(alpha: 0.1);
              }

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: alertColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: alertColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: alertColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: alert["icon"] as String,
                            color: alertColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert["title"] as String,
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: alertColor,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                alert["type"] as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: alertColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: alertColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (alert["severity"] as String).toUpperCase(),
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      alert["description"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color:
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "Valid until: ${alert["validUntil"]}",
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
}
