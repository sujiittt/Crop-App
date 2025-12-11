// lib/presentation/widgets/farm_canvas/farm_canvas.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';
import 'farm_tile.dart';
import 'sheets/plant_tile_sheet.dart';
import 'sheets/crop_quick_view_sheet.dart';
import 'plant_coach_prefs.dart';
import 'coachmark.dart';
import 'farm_storage.dart';
import 'farm_legend.dart';

class FarmCanvas extends StatefulWidget {
  const FarmCanvas({super.key});

  @override
  State<FarmCanvas> createState() => _FarmCanvasState();
}

class _FarmCanvasState extends State<FarmCanvas> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _current = 0;

  List<FarmField> _fields = [
    FarmField.empty(id: 'f1', name: 'North Plot', cols: 8, rows: 4),
  ];

  final _gridKey = GlobalKey();
  OverlayEntry? _coachEntry;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    final saved = await FarmStorage.load();
    if (saved != null && saved.isNotEmpty) {
      setState(() => _fields = saved);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoachmark());
  }

  Future<void> _saveFields() async {
    await FarmStorage.save(_fields);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _coachEntry?.remove();
    super.dispose();
  }

  // ---------- Tile mutate + save ----------
  void _setTile(FarmField field, FarmTile tile, FarmTile newTile) {
    final idxField = _fields.indexWhere((f) => f.id == field.id);
    if (idxField < 0) return;

    final idxTile = field.tiles.indexWhere((t) => t.x == tile.x && t.y == tile.y);
    if (idxTile < 0) return;

    final newTiles = List<FarmTile>.from(field.tiles);
    newTiles[idxTile] = newTile;

    final newField = FarmField(
      id: field.id,
      name: field.name,
      cols: field.cols,
      rows: field.rows,
      tiles: newTiles,
    );

    setState(() {
      _fields = List<FarmField>.from(_fields)..[idxField] = newField;
    });
    _saveFields();
  }

  // ---------- Stage helpers ----------
  TileStage _nextStage(TileStage s) {
    switch (s) {
      case TileStage.sown:
        return TileStage.growing;
      case TileStage.growing:
        return TileStage.harvest;
      case TileStage.harvest:
        return TileStage.sown;
    }
  }

  void _cycleStage(FarmField field, FarmTile tile) {
    if (tile.stage == null) return;
    final newStage = _nextStage(tile.stage!);
    _setTile(field, tile, tile.withStage(newStage));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked ${tile.crop!.label}: ${newStage.label}')),
    );
  }

  // ---------- Sheets ----------
  void _openPlantSheet(FarmField field, FarmTile tile) {
    _dismissCoach();
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => PlantTileSheet(
        onPick: (kind, density) {
          _setTile(field, tile, tile.plant(kind, density: density));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Planted ${kind.label} ×$density at (${tile.x + 1}, ${tile.y + 1})',
              ),
            ),
          );
        },
        onOpenSoil: () {
          Navigator.of(context).pushNamed('/soil-analysis-screen');
        },
      ),
    );
  }

  void _openCropSheet(FarmField field, FarmTile tile) {
    final crop = tile.crop!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => CropQuickViewSheet(
        crop: crop,
        onTasks: () => Navigator.of(context).pushNamed('/tasks-screen'),
        onSoil: () => Navigator.of(context).pushNamed('/soil-analysis-screen'),
        onClear: () {
          _setTile(field, tile, tile.clear());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tile cleared')),
          );
        },
      ),
    );
  }

  void _handleTileTap(FarmField field, FarmTile tile) {
    if (tile.isEmpty) {
      _openPlantSheet(field, tile);
    } else {
      _openCropSheet(field, tile);
    }
  }

  // ---------- Coachmark ----------
  Future<void> _maybeShowCoachmark() async {
    if (await PlantCoachPrefs.isShown()) return;
    final rect = _firstEmptyTileRect();
    if (rect == null) return;

    _coachEntry = Coachmark.show(
      context: context,
      target: rect,
      onDismiss: () {
        _coachEntry = null;
        PlantCoachPrefs.markShown();
      },
    );
  }

  void _dismissCoach() {
    _coachEntry?.remove();
    _coachEntry = null;
  }

  Rect? _firstEmptyTileRect() {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final field = _fields[_current];
    final idx = field.tiles.indexWhere((t) => t.isEmpty);
    if (idx < 0) return null;

    final cols = field.cols;
    final x = idx % cols;
    final y = idx ~/ cols;

    const spacing = 6.0;
    final size = box.size;
    final cellW = (size.width - spacing * (cols - 1)) / cols;
    final cellH = (size.height - spacing * (field.rows - 1)) / field.rows;

    final dx = x * (cellW + spacing);
    final dy = y * (cellH + spacing);

    final topLeft = box.localToGlobal(Offset(dx, dy));
    return Rect.fromLTWH(topLeft.dx, topLeft.dy, cellW, cellH);
  }

  // ---------- FIELD ACTIONS ----------
  Future<void> _createFieldDialog() async {
    final nameCtrl = TextEditingController(text: 'New Plot');
    final colsCtrl = TextEditingController(text: '8');
    final rowsCtrl = TextEditingController(text: '4');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Add Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: colsCtrl,
                      decoration: const InputDecoration(labelText: 'Cols (3–12)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: rowsCtrl,
                      decoration: const InputDecoration(labelText: 'Rows (2–10)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tip: larger grids show smaller tiles.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
          ],
        );
      },
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim().isEmpty ? 'Untitled Field' : nameCtrl.text.trim();
    int cols = int.tryParse(colsCtrl.text) ?? 8;
    int rows = int.tryParse(rowsCtrl.text) ?? 4;

    cols = cols.clamp(3, 12);
    rows = rows.clamp(2, 10);

    final id = const Uuid().v4();
    final newField = FarmField.empty(id: id, name: name, cols: cols, rows: rows);

    setState(() {
      _fields = List<FarmField>.from(_fields)..add(newField);
      _current = _fields.length - 1;
    });
    await _saveFields();

    _pageCtrl.animateToPage(
      _current,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _renameFieldDialog(FarmField field) async {
    final nameCtrl = TextEditingController(text: field.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Field'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Field name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim().isEmpty ? field.name : nameCtrl.text.trim();
    final idx = _fields.indexWhere((f) => f.id == field.id);
    if (idx < 0) return;

    setState(() {
      _fields = List<FarmField>.from(_fields)
        ..[idx] = FarmField(
          id: field.id,
          name: name,
          cols: field.cols,
          rows: field.rows,
          tiles: field.tiles,
        );
    });
    _saveFields();
  }

  Future<void> _deleteFieldDialog(FarmField field) async {
    if (_fields.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one field is required.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Field'),
        content: Text('Delete "${field.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final idx = _fields.indexWhere((f) => f.id == field.id);
    if (idx < 0) return;

    setState(() {
      final newList = List<FarmField>.from(_fields)..removeAt(idx);
      _fields = newList;
      if (_current >= _fields.length) _current = _fields.length - 1;
    });
    await _saveFields();

    _pageCtrl.animateToPage(
      _current,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final hasAnyField = _fields.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---------------------------
        // RESPONSIVE Pager of fields
        // ---------------------------
        // Instead of a fixed height, compute page height from available width.
        // ---------- RESPONSIVE Pager of fields (updated small buffer fix) ----------
        // ---------- RESPONSIVE Pager of fields (Step 3: slightly shorter + extra buffer) ----------
        LayoutBuilder(builder: (context, constraints) {
          // available width in parent (full width of Column)
          final availableW = constraints.maxWidth;

          // Use a slightly smaller visible fraction so page has more horizontal breathing.
          // This also indirectly reduces the farm height (since farmHeight uses pageVisibleWidth).
          const double visibleFraction = 0.90;
          final pageVisibleWidth = availableW * visibleFraction;

          // Increase aspect ratio to make farm area a bit shorter (height = width / ratio).
          // 4/3 = 1.333; using 1.5 reduces the height by ~11% which should remove a 10px overflow.
          const double farmAspectRatio = 1.5;

          // compute farm grid height based on visible page width
          final double farmHeight = pageVisibleWidth / farmAspectRatio;

          // header/top area inside _FieldCard (safe reserve for title row & icons)
          const double cardHeaderHeight = 52.0;

          // device bottom inset (navigation bar / gesture area)
          final double bottomInset = MediaQuery.of(context).padding.bottom;

          // increase small buffer for extra safety across devices
          const double smallBuffer = 18.0;

          // final PageView height = header + farmHeight + device bottom inset + small buffer
          final double pageViewHeight = cardHeaderHeight + farmHeight + bottomInset + smallBuffer;

          return SizedBox(
            height: pageViewHeight,
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) {
                setState(() => _current = i);
                WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoachmark());
              },
              itemCount: _fields.length,
              itemBuilder: (_, i) {
                final field = _fields[i];
                return _FieldCard(
                  title: field.name,
                  onAdd: _createFieldDialog,
                  onRename: () => _renameFieldDialog(field),
                  onDelete: () => _deleteFieldDialog(field),
                  child: _FieldGrid(
                    key: i == _current ? _gridKey : null,
                    field: field,
                    onTileTap: (t) => _handleTileTap(field, t),
                    onTileLongPress: (t) => _cycleStage(field, t),
                  ),
                );
              },
            ),
          );
        }),


        const SizedBox(height: 8),

        // Dots + "Add field" quick action
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasAnyField)
              Row(
                children: List.generate(_fields.length, (i) {
                  final selected = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: selected ? 20 : 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withOpacity(0.9)
                          : primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _createFieldDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add field'),
            ),
          ],
        ),

        const SizedBox(height: 8),
        const FarmLegend(), // tiny legend row
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onAdd;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _FieldCard({
    required this.title,
    required this.child,
    required this.onAdd,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withOpacity(0.20),
              primary.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: primary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 12,
              right: 12,
              top: 6,
              child: Row(
                children: [
                  Icon(Icons.terrain_rounded, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Rename',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onRename,
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                  ),
                  IconButton(
                    tooltip: 'Add field',
                    icon: const Icon(Icons.add_box_outlined, size: 20),
                    onPressed: onAdd,
                  ),
                ],
              ),
            ),

            // main content area
            Positioned.fill(top: 44, child: child),
          ],
        ),
      ),
    );
  }
}

class _FieldGrid extends StatelessWidget {
  final FarmField field;
  final ValueChanged<FarmTile> onTileTap;
  final ValueChanged<FarmTile>? onTileLongPress;

  const _FieldGrid({
    super.key,
    required this.field,
    required this.onTileTap,
    this.onTileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 12.0;
        final w = constraints.maxWidth - padding * 2;
        final h = constraints.maxHeight - padding * 2;

        // tile size & total grid size
        final cellSize = (w / field.cols).clamp(18.0, 40.0);
        final gridWidth = cellSize * field.cols;
        final gridHeight = cellSize * field.rows;

        // center vertically, but never negative (prevents tiny overflow)
        final rawTopPad = (h - gridHeight) / 2;
        final safeTopPad = rawTopPad.clamp(0.0, 24.0);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding + safeTopPad,
          ),
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: Stack(
              children: [
                // Decorative grid painter
                CustomPaint(
                  size: Size(gridWidth, gridHeight),
                  painter: _LightGridPainter(
                    color: Theme.of(context).colorScheme.onSurface,
                    rows: field.rows,
                    cols: field.cols,
                    cellSize: cellSize,
                    lineWidth: 0.5,
                    showDots: false,
                  ),
                ),

                // actual tiles
                _buildGrid(cellSize),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(double cellSize) {
    final children = <Widget>[];

    for (var y = 0; y < field.rows; y++) {
      for (var x = 0; x < field.cols; x++) {
        final tile = field.tileAt(x, y)!;

        // -------- OPTIONAL UI TWEAKS (Step-D) --------

        // glow when density high
        final bool highDensity = (tile.density ?? 1) >= 3;

        // color overlay based on stage
        Color? stageOverlay;
        switch (tile.stage) {
          case TileStage.sown:
            stageOverlay = Colors.brown.withOpacity(0.10);
            break;
          case TileStage.growing:
            stageOverlay = Colors.green.withOpacity(0.12);
            break;
          case TileStage.harvest:
            stageOverlay = Colors.orange.withOpacity(0.12);
            break;
          default:
            stageOverlay = null;
        }

        children.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              boxShadow: highDensity
                  ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.30),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
                  : [],
            ),
            child: Stack(
              children: [
                FarmTileView(
                  tile: tile,
                  size: cellSize,
                  onTap: () => onTileTap(tile),
                  onLongPress:
                  onTileLongPress == null ? null : () => onTileLongPress!(tile),
                ),
                if (stageOverlay != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: stageOverlay,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: field.cols,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: children,
    );
  }
}

// ------------------------------
// Helper: light grid painter
// ------------------------------
class _LightGridPainter extends CustomPainter {
  _LightGridPainter({
    required this.color,
    required this.rows,
    required this.cols,
    required this.cellSize,
    this.lineWidth = 0.6,
    this.showDots = false,
  });

  final Color color;
  final int rows;
  final int cols;
  final double cellSize;
  final double lineWidth;
  final bool showDots;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withOpacity(0.12)
      ..strokeWidth = lineWidth;

    // vertical lines
    for (int c = 0; c <= cols; c++) {
      final dx = (c * cellSize).clamp(0.0, size.width);
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }

    // horizontal lines
    for (int r = 0; r <= rows; r++) {
      final dy = (r * cellSize).clamp(0.0, size.height);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    // optional dots in centers
    if (showDots) {
      final dotPaint = Paint()..color = color.withOpacity(0.08);
      final radius = (cellSize * 0.035).clamp(0.8, 3.0);
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final cx = (c + 0.5) * cellSize;
          final cy = (r + 0.5) * cellSize;
          canvas.drawCircle(Offset(cx, cy), radius, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LightGridPainter old) {
    return old.color != color ||
        old.rows != rows ||
        old.cols != cols ||
        old.cellSize != cellSize ||
        old.lineWidth != lineWidth ||
        old.showDots != showDots;
  }
}
