import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrentWeatherCard extends StatelessWidget {
  final Map<String, dynamic> currentWeather;

  const CurrentWeatherCard({
    Key? key,
    required this.currentWeather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentWeather["location"] as String,
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'gps_fixed',
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "GPS Accuracy: ${currentWeather["gpsAccuracy"]}",
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  CustomIconWidget(
                    iconName: currentWeather["conditionIcon"] as String,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    currentWeather["condition"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${currentWeather["temperature"]}°",
                style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 48.sp,
                ),
              ),
              SizedBox(width: 2.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  "Feels like ${currentWeather["feelsLike"]}°",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: 'water_drop',
                  label: 'Humidity',
                  value: currentWeather["humidity"] as String,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  icon: 'air',
                  label: 'Wind Speed',
                  value: currentWeather["windSpeed"] as String,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: 'wb_sunny',
                  label: 'UV Index',
                  value: currentWeather["uvIndex"] as String,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  icon: 'thermostat',
                  label: 'Soil Temp',
                  value: currentWeather["soilTemp"] as String,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 24,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
