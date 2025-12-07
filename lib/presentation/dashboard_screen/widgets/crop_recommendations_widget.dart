import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
// keep these — you’re already using notifications + small repo
import '../../../core/services/notifications_service.dart';
import '../../../core/data/reminders_repository.dart';

class CropRecommendationsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;

  const CropRecommendationsWidget({
    Key? key,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = _normalize(recommendations);

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'eco',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Crop Recommendations',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/crop-recommendations-screen'),
                  child: Text(
                    'View All',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),

            if (items.isEmpty)
              Center(
                child: Text(
                  'No recommendations available',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              )
            else
            // Card list
              SizedBox(
                height: 29.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length > 5 ? 5 : items.length,
                  itemBuilder: (context, index) {
                    final crop = items[index];
                    final cropName =
                    (crop['name'] as String?)?.trim().isNotEmpty == true
                        ? (crop['name'] as String).trim()
                        : 'Unknown Crop';

                    return Container(
                      width: 40.w,
                      margin: EdgeInsets.only(right: 3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomImageWidget(
                                  imageUrl: crop['image'] as String? ?? '',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 0.8.h),

                            // name
                            Text(
                              cropName,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.4.h),

                            // suitability %
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: AppTheme.warningLight,
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${crop['suitability'] ?? 0}%',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.4.h),

                            // yield
                            Text(
                              'Yield: ${crop['expectedYield'] ?? 'N/A'}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondaryLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.6.h),

                            // suitability pill
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 0.7.h),
                              decoration: BoxDecoration(
                                color: _suitabilityColor(
                                    (crop['suitability'] as int?) ?? 0)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _suitabilityText(
                                    (crop['suitability'] as int?) ?? 0),
                                style: AppTheme
                                    .lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: _suitabilityColor(
                                      (crop['suitability'] as int?) ?? 0),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 0.8.h),

                            // SHORTER reminder CTA
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.alarm_add),
                                label: const Text('Plant Alert'),
                                onPressed: () => _onSetReminder(context, cropName),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // --- New Soil Test CTA (always shown) ---
            if (items.isNotEmpty) SizedBox(height: 1.2.h),
            _SoilTestCTA(
              onTap: () => Navigator.pushNamed(
                context,
                '/soil-analysis-screen',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // safe normalize helper
  List<Map<String, dynamic>> _normalize(List<Map<String, dynamic>> list) {
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList(growable: false);
  }

  // suitability helpers
  Color _suitabilityColor(int s) {
    if (s >= 80) return AppTheme.successLight;
    if (s >= 60) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  String _suitabilityText(int s) {
    if (s >= 80) return 'Highly Suitable';
    if (s >= 60) return 'Moderately Suitable';
    return 'Less Suitable';
  }

  // schedule reminder (unchanged behaviour)
  Future<void> _onSetReminder(BuildContext context, String cropName) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminders aren’t supported on Web. Try on Android device/emulator.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      initialDate: now,
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (now.hour == 23) ? 9 : now.hour + 1,
        minute: 0,
      ),
    );
    if (pickedTime == null) return;

    final whenLocal = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final noteCtrl = TextEditingController();
    final localizations = MaterialLocalizations.of(context);
    final dateStr = localizations.formatMediumDate(whenLocal);
    final timeStr = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(whenLocal),
      alwaysUse24HourFormat: false,
    );

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Confirm Reminder', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('$cropName • $dateStr • $timeStr',
                  style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Optional note',
                  hintText: 'e.g., Prepare seed bed / buy seeds',
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Schedule'),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (ok != true) return;

    try {
      final notifId = await NotificationsService.instance.schedulePlantingReminder(
        cropName: cropName,
        whenLocal: whenLocal,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );

      final reminder = CropReminder(
        id: notifId.toString(),
        cropName: cropName,
        whenLocal: whenLocal,
        notificationId: notifId,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );
      await RemindersRepository.instance.upsert(reminder);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for $cropName on $dateStr at $timeStr')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule: $e')),
      );
    }
  }
}

/// Gradient “New Soil Test” call-to-action shown under the list.
/// Uses your fade-green → fade-brown palette and a soft border.
class _SoilTestCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _SoilTestCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0.5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.95),
            AppTheme.accentBrown.withValues(alpha: 0.90),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.65),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.biotech_rounded, color: Colors.white),
              SizedBox(width: 2.w),
              Text(
                'New Soil Test',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
