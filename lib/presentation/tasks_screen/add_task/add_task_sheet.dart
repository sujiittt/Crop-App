// lib/presentation/tasks_screen/add_task/add_task_sheet.dart
import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../models/task_types.dart';
import '../../../data/task_storage.dart';

// Correct relative imports to farm canvas models/storage
import '../../widgets/farm_canvas/farm_storage.dart';
import '../../widgets/farm_canvas/models.dart';

/// AddTaskSheet - bottom sheet for creating a new task.
///
/// Optional prefill arguments:
/// - prefillFieldId: id of field (if opened from a farm tile)
/// - prefillCropLabel: crop label or emoji (if opened from tile)
class AddTaskSheet extends StatefulWidget {
  final String? prefillFieldId;
  final String? prefillCropLabel;
  final String? prefillStageName;

  const AddTaskSheet({
    Key? key,
    this.prefillFieldId,
    this.prefillCropLabel,
    this.prefillStageName,
  }) : super(key: key);

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  TaskType? _selectedType;
  String? _selectedFieldId;
  String? _selectedCropLabel;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  List<FarmField> _fields = [];
  bool _loadingFields = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedFieldId = widget.prefillFieldId;
    _selectedCropLabel = widget.prefillCropLabel;
    _loadFields();
    // do not call _applyPrefillSuggestions until fields loaded (it may reference them)
  }

  Future<void> _loadFields() async {
    try {
      final fields = await FarmStorage.load();
      setState(() {
        _fields = fields ?? <FarmField>[];
        _loadingFields = false;
      });
    } catch (_) {
      setState(() {
        _fields = <FarmField>[];
        _loadingFields = false;
      });
    }

    // after fields are loaded, apply prefill suggestions
    _applyPrefillSuggestions();
  }

  void _applyPrefillSuggestions() {
    // choose suggested task types based on provided crop/stage
    final suggestions = suggestTasksForCropStage(widget.prefillCropLabel, widget.prefillStageName);
    if (suggestions.isNotEmpty) {
      _selectedType = suggestions.first;
    } else {
      _selectedType = TaskType.irrigation;
    }

    // autofill title if crop/field known
    if (widget.prefillCropLabel != null && widget.prefillCropLabel!.isNotEmpty) {
      _selectedCropLabel = widget.prefillCropLabel;
      _titleCtrl.text = '${_selectedType?.label ?? 'Task'} for ${_selectedCropLabel}';
    } else if (_selectedFieldId != null) {
      FarmField? f;
      try {
        f = _fields.firstWhere((e) => e.id == _selectedFieldId);
      } catch (_) {
        f = null;
      }
      if (f != null) {
        _titleCtrl.text = '${_selectedType?.label ?? 'Task'} — ${f.name}';
      } else {
        _titleCtrl.text = '${_selectedType?.label ?? 'Task'}';
      }
    } else {
      _titleCtrl.text = '${_selectedType?.label ?? 'Task'}';
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (t != null) {
      setState(() => _selectedTime = t);
    }
  }

  DateTime _composeDateTime() {
    if (_selectedTime == null) {
      // default to 09:00 of selected date
      return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 9, 0);
    } else {
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }
  }

  Future<void> _saveTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a title and select a task type.')));
      return;
    }

    final scheduled = _composeDateTime();

    setState(() => _saving = true);
    try {
      await TaskStorage.instance.addTask(
        title: title,
        type: _selectedType!.toStorageString(),
        dateTime: scheduled,
        fieldId: _selectedFieldId,
        cropLabel: _selectedCropLabel,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task saved')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving task: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          children: [
            // header
            Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Add Task',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Task type chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: primaryTaskTypes().map((t) {
                final selected = t == _selectedType;
                return ChoiceChip(
                  label: Text(t.label),
                  avatar: Icon(t.icon, size: 18),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = t;
                      // update title suggestion if title is empty
                      if (_titleCtrl.text.isEmpty) {
                        _titleCtrl.text = '${t.label}${_selectedCropLabel != null ? ' for $_selectedCropLabel' : ''}';
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Field & crop selectors
            _loadingFields
                ? const Center(child: CircularProgressIndicator())
                : Row(
              children: [
                // Field dropdown
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedFieldId,
                    decoration: const InputDecoration(labelText: 'Field (optional)'),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('None')),
                      ..._fields.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedFieldId = v;
                        // clear crop label if user changed field (optional)
                        // _selectedCropLabel = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Crop label (free text)
                Expanded(
                  child: TextFormField(
                    initialValue: _selectedCropLabel,
                    decoration: const InputDecoration(labelText: 'Crop (optional) e.g. 🌾 Wheat'),
                    onChanged: (v) => _selectedCropLabel = v,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),

            const SizedBox(height: 12),

            // Date & Time pickers
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text('Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text(_selectedTime == null ? 'Time: 09:00 (default)' : 'Time: ${_selectedTime!.format(context)}'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Save button
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _saveTask,
                    icon: _saving ? const SizedBox.shrink() : const Icon(Icons.check),
                    label: _saving ? const Text('Saving...') : const Text('Save Task'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
