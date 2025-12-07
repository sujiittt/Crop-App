import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CropCardWidget extends StatelessWidget {
  final Map<String, dynamic> cropData;
  final VoidCallback? onTap;
  final VoidCallback? onAddToFarmPlan;
  final VoidCallback? onSetReminder;
  final VoidCallback? onShare;

  const CropCardWidget({
    Key? key,
    required this.cropData,
    this.onTap,
    this.onAddToFarmPlan,
    this.onSetReminder,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suitabilityScore = (cropData['suitabilityScore'] as num).toDouble();
    final cropName = cropData['name'] as String? ?? '';
    final localName = cropData['localName'] as String? ?? '';
    final expectedYield = cropData['expectedYield'] as String? ?? '';
    final priceRange = cropData['priceRange'] as String? ?? '';
    final imageUrl = cropData['image'] as String? ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(cropData['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onAddToFarmPlan?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.add_circle_outline,
              label: 'Add to Plan',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onSetReminder?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: Colors.black,
              icon: Icons.notifications_outlined,
              label: 'Reminder',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onShare?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.share_outlined,
              label: 'Share',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: imageUrl,
                          width: 20.w,
                          height: 20.w,
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
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (localName.isNotEmpty) ...[
                              SizedBox(height: 0.5.h),
                              Text(
                                localName,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                Text(
                                  'Suitability: ',
                                  style:
                                  AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                                Text(
                                  '${suitabilityScore.toInt()}%',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                    _getSuitabilityColor(suitabilityScore),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getSuitabilityColor(suitabilityScore)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${suitabilityScore.toInt()}%',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: _getSuitabilityColor(suitabilityScore),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    height: 0.8.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade200,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: suitabilityScore / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _getSuitabilityColor(suitabilityScore),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'agriculture',
                                  size: 16,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Expected Yield',
                                  style:
                                  AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              expectedYield,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'currency_rupee',
                                  size: 16,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Market Price',
                                  style:
                                  AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              priceRange,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSuitabilityColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
