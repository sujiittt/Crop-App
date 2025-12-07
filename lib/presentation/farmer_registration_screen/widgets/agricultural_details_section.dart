import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AgriculturalDetailsSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> initialData;

  const AgriculturalDetailsSection({
    Key? key,
    required this.onDataChanged,
    required this.initialData,
  }) : super(key: key);

  @override
  State<AgriculturalDetailsSection> createState() =>
      _AgriculturalDetailsSectionState();
}

class _AgriculturalDetailsSectionState
    extends State<AgriculturalDetailsSection> {
  String? _selectedFarmSize;
  String? _selectedUnit;
  List<String> _selectedCrops = [];
  double _experienceYears = 1.0;

  // --- small helper to make sure dynamic/LinkedMap becomes typed Map<String,dynamic>
  Map<String, dynamic> _norm(dynamic raw) =>
      raw == null ? <String, dynamic>{} : Map<String, dynamic>.from(raw as Map);

  final List<String> _farmSizeOptions = [
    '0.5',
    '1',
    '2',
    '3',
    '4',
    '5',
    '10',
    '15',
    '20',
    '25',
    '50',
    '100+'
  ];

  final List<String> _unitOptions = ['Hectares', 'Acres'];

  final List<Map<String, dynamic>> _cropOptions = [
    {'name': 'Rice', 'icon': 'grass'},
    {'name': 'Wheat', 'icon': 'grain'},
    {'name': 'Corn', 'icon': 'agriculture'},
    {'name': 'Cotton', 'icon': 'eco'},
    {'name': 'Sugarcane', 'icon': 'local_florist'},
    {'name': 'Soybean', 'icon': 'spa'},
    {'name': 'Tomato', 'icon': 'local_grocery_store'},
    {'name': 'Potato', 'icon': 'food_bank'},
    {'name': 'Onion', 'icon': 'restaurant'},
    {'name': 'Chili', 'icon': 'whatshot'},
    {'name': 'Banana', 'icon': 'nature'},
    {'name': 'Mango', 'icon': 'park'},
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Normalize once; now all reads are strongly typed
    final init = _norm(widget.initialData);

    _selectedFarmSize = init['farmSize'] as String?;
    _selectedUnit = (init['farmUnit'] as String?) ?? 'Hectares';
    _selectedCrops = List<String>.from(init['primaryCrops'] ?? const []);
    _experienceYears = (init['experienceYears'] ?? 1.0).toDouble();
  }

  void _updateData() {
    final data = {
      'farmSize': _selectedFarmSize,
      'farmUnit': _selectedUnit,
      'primaryCrops': _selectedCrops,
      'experienceYears': _experienceYears,
    };
    widget.onDataChanged(data);
  }

  void _toggleCrop(String crop) {
    setState(() {
      if (_selectedCrops.contains(crop)) {
        _selectedCrops.remove(crop);
      } else {
        _selectedCrops.add(crop);
      }
    });
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'agriculture',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Agricultural Details',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Farm Size Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Farm Size',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.lightTheme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFarmSize,
                            hint: const Text('Select size'),
                            isExpanded: true,
                            items: _farmSizeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFarmSize = newValue;
                              });
                              _updateData();
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.lightTheme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            isExpanded: true,
                            items: _unitOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUnit = newValue;
                              });
                              _updateData();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Primary Crops Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Primary Crops Grown',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Select all crops you currently grow',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                SizedBox(height: 2.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: _cropOptions.map((crop) {
                    final isSelected = _selectedCrops.contains(crop['name']);
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: crop['icon'],
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(crop['name']),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        _toggleCrop(crop['name']);
                      },
                      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                      selectedColor: AppTheme.lightTheme.primaryColor,
                      checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontSize: 12.sp,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Experience Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Years of Farming Experience',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightTheme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_experienceYears.toInt()} ${_experienceYears.toInt() == 1 ? 'Year' : 'Years'}',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _experienceYears < 2
                                  ? 'Beginner'
                                  : _experienceYears < 5
                                  ? 'Intermediate'
                                  : _experienceYears < 10
                                  ? 'Experienced'
                                  : 'Expert',
                              style: TextStyle(
                                color: AppTheme.lightTheme.primaryColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.lightTheme.primaryColor,
                          inactiveTrackColor:
                          AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                          thumbColor: AppTheme.lightTheme.primaryColor,
                          overlayColor:
                          AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8.0,
                          ),
                        ),
                        child: Slider(
                          value: _experienceYears,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          onChanged: (double value) {
                            setState(() {
                              _experienceYears = value;
                            });
                            _updateData();
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 Year', style: AppTheme.lightTheme.textTheme.bodySmall),
                          Text('50+ Years', style: AppTheme.lightTheme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
