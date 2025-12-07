import 'package:flutter/material.dart';
import '../../farm_canvas/models.dart';

class CropQuickViewSheet extends StatelessWidget {
  final CropKind crop;
  final VoidCallback onTasks;
  final VoidCallback onSoil;
  final VoidCallback onClear;

  const CropQuickViewSheet({
    super.key,
    required this.crop,
    required this.onTasks,
    required this.onSoil,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(crop.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 8),
                Text(
                  crop.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.list_alt_outlined),
                    label: const Text('Tasks'),
                    onPressed: () {
                      Navigator.pop(context);
                      onTasks();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.biotech_outlined),
                    label: const Text('Soil Test'),
                    onPressed: () {
                      Navigator.pop(context);
                      onSoil();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary.withOpacity(.12),
                  foregroundColor: primary,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear tile'),
                onPressed: () {
                  Navigator.pop(context);
                  onClear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
