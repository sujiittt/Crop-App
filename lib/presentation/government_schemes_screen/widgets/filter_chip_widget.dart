import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? iconName;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconName != null) ...[
              CustomIconWidget(
                iconName: iconName!,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 1.w),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: AppTheme.lightTheme.primaryColor,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor
              : Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: isSelected ? 2 : 0,
        shadowColor: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
      ),
    );
  }
}
