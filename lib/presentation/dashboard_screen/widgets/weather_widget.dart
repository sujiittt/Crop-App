import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherWidget({
    Key? key,
    required this.weatherData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = Map<String, dynamic>.from(weatherData as Map);
// use `data` instead of `weatherData`

    return Container(
      width: double.infinity,
      height: null, // let it grow naturally
      constraints: BoxConstraints(minHeight: 18.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            // LEFT SIDE
            Flexible(
              fit: FlexFit.loose, // ← allow shrinking to avoid overflow
              child: Column(
                mainAxisSize: MainAxisSize.min, // ← don't force full height
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weatherData['location'] as String? ?? 'Unknown Location',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${weatherData['temperature'] ?? 0}°C',
                    style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    weatherData['condition'] as String? ?? 'Clear',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // RIGHT SIDE
            Flexible(
              fit: FlexFit.loose, // ← allow shrinking to avoid overflow
              child: Column(
                mainAxisSize: MainAxisSize.min, // ← don't force full height
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName:
                    _getWeatherIcon(weatherData['condition'] as String? ?? 'clear'),
                    color: Colors.white,
                    size: 8.w,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Humidity: ${weatherData['humidity'] ?? 0}%',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  if (weatherData['alert'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.warningLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Alert',
                        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'wb_sunny';
      case 'cloudy':
      case 'overcast':
        return 'cloud';
      case 'rainy':
      case 'rain':
        return 'grain';
      case 'stormy':
      case 'thunderstorm':
        return 'flash_on';
      case 'foggy':
      case 'mist':
        return 'blur_on';
      default:
        return 'wb_sunny';
    }
  }
}
