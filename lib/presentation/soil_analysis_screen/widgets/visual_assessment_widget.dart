import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VisualAssessmentWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onAssessmentChanged;

  const VisualAssessmentWidget({
    Key? key,
    required this.onAssessmentChanged,
  }) : super(key: key);

  @override
  State<VisualAssessmentWidget> createState() => _VisualAssessmentWidgetState();
}

class _VisualAssessmentWidgetState extends State<VisualAssessmentWidget> {
  String? _selectedColor;
  String? _selectedTexture;
  String? _selectedMoisture;

  final List<Map<String, dynamic>> _soilColors = [
    {'name': 'Dark Brown', 'color': Color(0xFF3E2723), 'fertility': 'High'},
    {'name': 'Brown', 'color': Color(0xFF5D4037), 'fertility': 'Good'},
    {'name': 'Light Brown', 'color': Color(0xFF8D6E63), 'fertility': 'Medium'},
    {'name': 'Red', 'color': Color(0xFFD32F2F), 'fertility': 'Medium'},
    {'name': 'Yellow', 'color': Color(0xFFFBC02D), 'fertility': 'Low'},
    {'name': 'Gray', 'color': Color(0xFF616161), 'fertility': 'Poor'},
  ];

  final List<Map<String, dynamic>> _soilTextures = [
    {
      'name': 'Sandy',
      'icon': 'grain',
      'description': 'Feels gritty, drains quickly'
    },
    {
      'name': 'Clay',
      'icon': 'layers',
      'description': 'Feels sticky when wet, holds water'
    },
    {
      'name': 'Loam',
      'icon': 'eco',
      'description': 'Balanced mix, ideal for crops'
    },
    {
      'name': 'Silt',
      'icon': 'water_drop',
      'description': 'Smooth texture, retains moisture'
    },
  ];

  final List<Map<String, dynamic>> _moistureLevels = [
    {
      'name': 'Dry',
      'icon': 'wb_sunny',
      'color': Colors.orange,
      'description': 'Dusty, cracked surface'
    },
    {
      'name': 'Moist',
      'icon': 'opacity',
      'color': Colors.blue,
      'description': 'Slightly damp, good for planting'
    },
    {
      'name': 'Wet',
      'icon': 'water',
      'color': Colors.indigo,
      'description': 'Waterlogged, may need drainage'
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateAssessment();
  }

  void _updateAssessment() {
    widget.onAssessmentChanged({
      'color': _selectedColor,
      'texture': _selectedTexture,
      'moisture': _selectedMoisture,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visual Soil Assessment',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildColorSelection(),
        SizedBox(height: 3.h),
        _buildTextureSelection(),
        SizedBox(height: 3.h),
        _buildMoistureSelection(),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soil Color',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Select the color that best matches your soil',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            children: _soilColors.map((colorData) {
              final isSelected = _selectedColor == colorData['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = colorData['name'];
                  });
                  _updateAssessment();
                },
                child: Container(
                  width: 25.w,
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                        .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: colorData['color'],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        colorData['name'],
                        style:
                        AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        colorData['fertility'],
                        style:
                        AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextureSelection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soil Texture',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Feel the soil between your fingers',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Column(
            children: _soilTextures.map((textureData) {
              final isSelected = _selectedTexture == textureData['name'];
              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTexture = textureData['name'];
                    });
                    _updateAssessment();
                  },
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: textureData['icon'],
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                textureData['name'],
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                              Text(
                                textureData['description'],
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoistureSelection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Moisture Level',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Current soil moisture condition',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: _moistureLevels.map((moistureData) {
              final isSelected = _selectedMoisture == moistureData['name'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMoisture = moistureData['name'];
                    });
                    _updateAssessment();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? moistureData['color'].withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? moistureData['color']
                            : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: moistureData['icon'],
                          color: isSelected
                              ? moistureData['color']
                              : AppTheme
                              .lightTheme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          moistureData['name'],
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? moistureData['color']
                                : AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          moistureData['description'],
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontSize: 9.sp,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
