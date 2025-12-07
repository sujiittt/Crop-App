import 'package:flutter/material.dart';
import '../models.dart';

class PlantTileSheet extends StatefulWidget {
  final void Function(CropKind kind, int density) onPick;
  final VoidCallback onOpenSoil;

  const PlantTileSheet({
    super.key,
    required this.onPick,
    required this.onOpenSoil,
  });

  @override
  State<PlantTileSheet> createState() => _PlantTileSheetState();
}

class _PlantTileSheetState extends State<PlantTileSheet> {
  int _density = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Plant crop',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              IconButton(
                tooltip: 'Soil test',
                onPressed: widget.onOpenSoil,
                icon: const Icon(Icons.biotech_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Density selector
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Single'),
                  selected: _density == 1,
                  onSelected: (_) => setState(() => _density = 1),
                ),
                ChoiceChip(
                  label: const Text('Dense ×2'),
                  selected: _density == 2,
                  onSelected: (_) => setState(() => _density = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Crop grid
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: CropKind.values.map((c) {
              return _CropButton(
                kind: c,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onPick(c, _density);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CropButton extends StatelessWidget {
  final CropKind kind;
  final VoidCallback onTap;
  const _CropButton({required this.kind, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(kind.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(kind.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
