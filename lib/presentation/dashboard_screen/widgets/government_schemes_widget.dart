import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GovernmentSchemesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> schemes;

  const GovernmentSchemesWidget({
    Key? key,
    required this.schemes,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final items = schemes
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
// then use `items` instead of `schemes`

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
                  iconName: 'account_balance',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Government Schemes',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/government-schemes-screen');
                  },
                  child: Text(
                    'View All',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            schemes.isEmpty
                ? Center(
              child: Text(
                'No applicable schemes found',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            )
                : Column(
              children: (schemes as List).take(3).map((scheme) {
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              scheme['name'] as String? ??
                                  'Unknown Scheme',
                              style: AppTheme
                                  .lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(
                                  scheme['urgency'] as String? ??
                                      'medium')
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (scheme['urgency'] as String? ?? 'medium')
                                  .toUpperCase(),
                              style: AppTheme
                                  .lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: _getUrgencyColor(
                                    scheme['urgency'] as String? ??
                                        'medium'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        scheme['description'] as String? ?? '',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'currency_rupee',
                            color: AppTheme.successLight,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            scheme['benefit'] as String? ?? 'N/A',
                            style: AppTheme
                                .lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.successLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.textSecondaryLight,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Due: ${scheme['deadline'] as String? ?? 'N/A'}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (schemes.length > 3)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/government-schemes-screen');
                  },
                  child: Text(
                    'View ${schemes.length - 3} More Schemes',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return AppTheme.errorLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.successLight;
      default:
        return AppTheme.warningLight;
    }
  }
}
