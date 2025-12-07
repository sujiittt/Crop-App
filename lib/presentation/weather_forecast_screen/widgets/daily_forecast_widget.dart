import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DailyForecastWidget extends StatefulWidget {
  final List<Map<String, dynamic>> dailyData;

  const DailyForecastWidget({
    Key? key,
    required this.dailyData,
  }) : super(key: key);

  @override
  State<DailyForecastWidget> createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            "7-Day Forecast",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: widget.dailyData.length,
          itemBuilder: (context, index) {
            final day = widget.dailyData[index];
            final isExpanded = expandedIndex == index;

            return GestureDetector(
              onLongPress: () => _showDetailedView(context, day),
              child: Card(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          expandedIndex = isExpanded ? null : index;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day["day"] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    day["date"] as String,
                                    style:
                                    AppTheme.lightTheme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: CustomIconWidget(
                                iconName: day["icon"] as String,
                                color: AppTheme.lightTheme.primaryColor,
                                size: 32,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${day["high"]}°",
                                        style: AppTheme
                                            .lightTheme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "${day["low"]}°",
                                        style: AppTheme
                                            .lightTheme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'water_drop',
                                        color: AppTheme
                                            .lightTheme.colorScheme.secondary,
                                        size: 16,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        "${day["rainChance"]}%",
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName:
                              isExpanded ? 'expand_less' : 'expand_more',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      Divider(height: 1),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          children: [
                            if ((day["alerts"] as List).isNotEmpty) ...[
                              _buildAlertsSection(day["alerts"] as List),
                              SizedBox(height: 2.h),
                            ],
                            _buildDetailedMetrics(day),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlertsSection(List alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agricultural Alerts",
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...alerts.map((alert) {
          final alertData = alert as Map<String, dynamic>;
          Color alertColor;
          switch (alertData["severity"] as String) {
            case "high":
              alertColor = AppTheme.lightTheme.colorScheme.error;
              break;
            case "medium":
              alertColor = AppTheme.getWarningColor(true);
              break;
            default:
              alertColor = AppTheme.getSuccessColor(true);
          }

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: alertColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: alertData["icon"] as String,
                  color: alertColor,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    alertData["message"] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: alertColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDetailedMetrics(Map<String, dynamic> day) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildMetricRow("Humidity", "${day["humidity"]}%", 'water_drop'),
              SizedBox(height: 1.h),
              _buildMetricRow("Wind", day["wind"] as String, 'air'),
              SizedBox(height: 1.h),
              _buildMetricRow("UV Index", "${day["uvIndex"]}", 'wb_sunny'),
            ],
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            children: [
              _buildMetricRow("Pressure", "${day["pressure"]} mb", 'speed'),
              SizedBox(height: 1.h),
              _buildMetricRow(
                  "Visibility", "${day["visibility"]} km", 'visibility'),
              SizedBox(height: 1.h),
              _buildMetricRow("Dew Point", "${day["dewPoint"]}°", 'thermostat'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, String icon) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDetailedView(BuildContext context, Map<String, dynamic> day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${day["day"]} - ${day["date"]}",
                      style:
                      AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "Farming Activity Suggestions",
                      style:
                      AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ...(day["farmingActivities"] as List).map((activity) {
                      final activityData = activity as Map<String, dynamic>;
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.getSuccessColor(true)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.getSuccessColor(true)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: activityData["icon"] as String,
                                  color: AppTheme.getSuccessColor(true),
                                  size: 20,
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    activityData["title"] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              activityData["description"] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
