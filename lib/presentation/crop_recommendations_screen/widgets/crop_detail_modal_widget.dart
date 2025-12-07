import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CropDetailModalWidget extends StatelessWidget {
  final Map<String, dynamic> cropData;

  const CropDetailModalWidget({
    Key? key,
    required this.cropData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cropName = cropData['name'] as String? ?? '';
    final localName = cropData['localName'] as String? ?? '';
    final imageUrl = cropData['image'] as String? ?? '';
    final plantingCalendar =
        cropData['plantingCalendar'] as Map<String, dynamic>? ?? {};
    final waterRequirements =
        cropData['waterRequirements'] as Map<String, dynamic>? ?? {};
    final fertilizerSchedule = (cropData['fertilizerSchedule'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        [];
    final pestManagement =
        (cropData['pestManagement'] as List?)?.cast<Map<String, dynamic>>() ??
            [];

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropName,
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (localName.isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          localName,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Planting Calendar',
                    Icons.calendar_today,
                    _buildPlantingCalendar(plantingCalendar),
                  ),
                  SizedBox(height: 3.h),
                  _buildSection(
                    'Water Requirements',
                    Icons.water_drop,
                    _buildWaterRequirements(waterRequirements),
                  ),
                  SizedBox(height: 3.h),
                  _buildSection(
                    'Fertilizer Schedule',
                    Icons.eco,
                    _buildFertilizerSchedule(fertilizerSchedule),
                  ),
                  SizedBox(height: 3.h),
                  _buildSection(
                    'Pest Management',
                    Icons.bug_report,
                    _buildPestManagement(pestManagement),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon.toString().split('.').last,
              size: 20,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        content,
      ],
    );
  }

  Widget _buildPlantingCalendar(Map<String, dynamic> calendar) {
    final bestTime = calendar['bestTime'] as String? ?? 'Not specified';
    final duration = calendar['duration'] as String? ?? 'Not specified';
    final harvestTime = calendar['harvestTime'] as String? ?? 'Not specified';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow('Best Planting Time', bestTime),
          SizedBox(height: 1.h),
          _buildInfoRow('Growing Duration', duration),
          SizedBox(height: 1.h),
          _buildInfoRow('Harvest Time', harvestTime),
        ],
      ),
    );
  }

  Widget _buildWaterRequirements(Map<String, dynamic> water) {
    final frequency = water['frequency'] as String? ?? 'Not specified';
    final amount = water['amount'] as String? ?? 'Not specified';
    final method = water['method'] as String? ?? 'Not specified';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow('Watering Frequency', frequency),
          SizedBox(height: 1.h),
          _buildInfoRow('Water Amount', amount),
          SizedBox(height: 1.h),
          _buildInfoRow('Irrigation Method', method),
        ],
      ),
    );
  }

  Widget _buildFertilizerSchedule(List<Map<String, dynamic>> schedule) {
    if (schedule.isEmpty) {
      return Text(
        'No fertilizer schedule available',
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: schedule.map((item) {
        final stage = item['stage'] as String? ?? '';
        final fertilizer = item['fertilizer'] as String? ?? '';
        final amount = item['amount'] as String? ?? '';

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stage,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 1.h),
              _buildInfoRow('Fertilizer', fertilizer),
              SizedBox(height: 0.5.h),
              _buildInfoRow('Amount', amount),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPestManagement(List<Map<String, dynamic>> pests) {
    if (pests.isEmpty) {
      return Text(
        'No pest management information available',
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: pests.map((item) {
        final pest = item['pest'] as String? ?? '';
        final symptoms = item['symptoms'] as String? ?? '';
        final treatment = item['treatment'] as String? ?? '';

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pest,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 1.h),
              _buildInfoRow('Symptoms', symptoms),
              SizedBox(height: 0.5.h),
              _buildInfoRow('Treatment', treatment),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.w,
          child: Text(
            '$label:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
