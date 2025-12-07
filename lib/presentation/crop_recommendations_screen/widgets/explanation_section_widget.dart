import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExplanationSectionWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const ExplanationSectionWidget({
    Key? key,
    required this.analysisData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final soilType = analysisData['soilType'] as String? ?? 'Unknown';
    final phLevel = analysisData['phLevel'] as double? ?? 0.0;
    final nitrogen = analysisData['nitrogen'] as String? ?? 'Unknown';
    final phosphorus = analysisData['phosphorus'] as String? ?? 'Unknown';
    final potassium = analysisData['potassium'] as String? ?? 'Unknown';
    final region = analysisData['region'] as String? ?? 'Unknown';
    final successRate = analysisData['regionalSuccessRate'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'help_outline',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(width: 3.w),
              Text(
                'Why these crops?',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildFactorCard(
            'Soil Compatibility',
            'Your $soilType soil with pH $phLevel is ideal for the recommended crops',
            Icons.terrain,
            AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          _buildFactorCard(
            'Nutrient Analysis',
            'Nitrogen: $nitrogen, Phosphorus: $phosphorus, Potassium: $potassium levels support optimal growth',
            Icons.science,
            Colors.green,
          ),
          SizedBox(height: 2.h),
          _buildFactorCard(
            'Regional Success',
            '$successRate% success rate for these crops in $region region based on historical data',
            Icons.location_on,
            Colors.orange,
          ),
          SizedBox(height: 2.h),
          _buildFactorCard(
            'Weather Patterns',
            'Current and forecasted weather conditions favor the recommended crop varieties',
            Icons.wb_cloudy,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFactorCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
