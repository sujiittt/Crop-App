// lib/presentation/crop_recommendations_screen/widgets/set_planting_reminder_button.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/reminders_repository.dart';
import '../../../../core/services/notifications_service.dart';

class SetPlantingReminderButton extends StatefulWidget {
  final String cropName;

  const SetPlantingReminderButton({
    super.key,
    required this.cropName,
  });

  @override
  State<SetPlantingReminderButton> createState() =>
      _SetPlantingReminderButtonState();
}

class _SetPlantingReminderButtonState
    extends State<SetPlantingReminderButton> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.alarm_add),
      label: const Text('Set Planting Reminder'),
      onPressed: _working ? null : () => _openPicker(context),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
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
      initialTime:
      TimeOfDay(hour: now.hour == 23 ? 9 : now.hour + 1, minute: 0),
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
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final fmt = DateFormat('EEE, dd MMM yyyy • hh:mm a');
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
              Text('Confirm Reminder',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '${widget.cropName} • ${fmt.format(whenLocal)}',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
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

    setState(() => _working = true);
    try {
      final notifId = await NotificationsService.instance
          .schedulePlantingReminder(
        cropName: widget.cropName,
        whenLocal: whenLocal,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );

      final reminder = CropReminder(
        id: notifId.toString(),
        cropName: widget.cropName,
        whenLocal: whenLocal,
        notificationId: notifId,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );
      await RemindersRepository.instance.upsert(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reminder set for ${widget.cropName} on ${DateFormat('dd MMM, hh:mm a').format(whenLocal)}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }
}
