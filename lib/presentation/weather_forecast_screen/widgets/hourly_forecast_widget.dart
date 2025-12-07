import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Text(
              "24-Hour Forecast",
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: hourlyData.length,
              itemBuilder: (context, index) {
                final hour = hourlyData[index];
                return Container(
                  width: 20.w,
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        hour["time"] as String,
                        style:
                        AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      CustomIconWidget(
                        iconName: hour["icon"] as String,
                        color: AppTheme.lightTheme.primaryColor,
                        size: 24,
                      ),
                      Text(
                        "${hour["temp"]}°",
                        style:
                        AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'water_drop',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 12,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            "${hour["precipitation"]}%",
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle:
                            (hour["windDirection"] as int) * 3.14159 / 180,
                            child: CustomIconWidget(
                              iconName: 'navigation',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 12,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            "${hour["windSpeed"]}",
                            style: AppTheme.lightTheme.textTheme.bodySmall,
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
      ),
    );
  }
}
