import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChipsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Highest Yield', 'value': 'yield', 'icon': 'trending_up'},
      {'label': 'Best Price', 'value': 'price', 'icon': 'currency_rupee'},
      {'label': 'Water Efficient', 'value': 'water', 'icon': 'water_drop'},
      {'label': 'Season Appropriate', 'value': 'season', 'icon': 'wb_sunny'},
    ];

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['value'];

          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: filter['icon'] as String,
                  size: 16,
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 2.w),
                Text(
                  filter['label'] as String,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            onSelected: (selected) {
              if (selected) {
                onFilterChanged(filter['value'] as String);
              }
            },
            selectedColor: AppTheme.lightTheme.colorScheme.primary,
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            side: BorderSide(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          );
        },
      ),
    );
  }
}
