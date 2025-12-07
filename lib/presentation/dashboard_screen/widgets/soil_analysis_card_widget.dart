import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SoilAnalysisCardWidget extends StatelessWidget {
  final Map<String, dynamic> soilData;

  const SoilAnalysisCardWidget({
    Key? key,
    required this.soilData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = Map<String, dynamic>.from(soilData as Map);
// use `data` instead of `soilData`

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'science',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Soil Analysis',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  soilData['date'] as String? ?? 'N/A',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildSoilParameter(
                    'pH Level',
                    '${soilData['ph'] ?? 0.0}',
                    _getPhStatus(soilData['ph'] as double? ?? 0.0),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildSoilParameter(
                    'Nitrogen',
                    '${soilData['nitrogen'] ?? 0}%',
                    _getNutrientStatus(soilData['nitrogen'] as int? ?? 0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildSoilParameter(
                    'Phosphorus',
                    '${soilData['phosphorus'] ?? 0}%',
                    _getNutrientStatus(soilData['phosphorus'] as int? ?? 0),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildSoilParameter(
                    'Potassium',
                    '${soilData['potassium'] ?? 0}%',
                    _getNutrientStatus(soilData['potassium'] as int? ?? 0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/soil-analysis-screen');
                    },
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/soil-analysis-screen');
                    },
                    child: Text('New Test'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilParameter(String label, String value, String status) {
    Color statusColor = _getStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            Text(
              value,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 1.w),
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          status,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getPhStatus(double ph) {
    if (ph < 6.0) return 'Acidic';
    if (ph > 8.0) return 'Alkaline';
    return 'Optimal';
  }

  String _getNutrientStatus(int percentage) {
    if (percentage < 30) return 'Low';
    if (percentage > 70) return 'High';
    return 'Good';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'good':
        return AppTheme.successLight;
      case 'low':
      case 'acidic':
      case 'alkaline':
        return AppTheme.warningLight;
      case 'high':
        return AppTheme.errorLight;
      default:
        return AppTheme.textSecondaryLight;
    }
  }
}
