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

// AddTaskSheet import (adjusted path because tasks are under presentation/tasks_screen)
import '../../tasks_screen/add_task/add_task_sheet.dart';
import '../../../data/crop_task_generator.dart';
import '../../../data/crop_task_templates.dart';
import '../../../data/task_storage.dart';
import '../../../core/auth/auth_guard.dart';
import '../../../core/auth/auth_state.dart';


class _SuggestedTaskItem {
  final GeneratedTask task;
  bool selected;

  _SuggestedTaskItem({
    required this.task,
    this.selected = true,
  });
}

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
  List<GeneratedTask> _suggestedTasks = [];
  List<_SuggestedTaskItem> _suggestedTaskItems = [];
  String _autoTaskKey({
    required String fieldId,
    required CropStage stage,
  }) {
    return '$fieldId-${stage.name}';
  }
  final Set<String> _autoTaskGeneratedKeys = {};





  final _gridKey = GlobalKey();
  OverlayEntry? _coachEntry;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }
  void _generateSuggestedTasks({
    required String cropName,
    required CropStage stage,
    required DateTime stageStartDate,
    required String fieldId,
  }) {
    final key = _autoTaskKey(fieldId: fieldId, stage: stage);

    // Prevent duplicate suggestions
    if (_autoTaskGeneratedKeys.contains(key)) return;

    final normalizedCrop = cropName.toLowerCase();

    // ✅ NEW: Skip crops without templates
    if (!CropTaskGenerator.hasTemplatesForCrop(cropName)) {
      debugPrint('No task templates for crop: $cropName');
      return; // ❗ DO NOTHING — prevents black screen
    }

    final tasks = CropTaskGenerator.generateTasks(
      cropName: normalizedCrop,
      stage: stage,
      stageStartDate: stageStartDate,
    );

    if (tasks.isEmpty) return;

    _autoTaskGeneratedKeys.add(key);

    setState(() {
      _suggestedTaskItems =
          tasks.map((t) => _SuggestedTaskItem(task: t)).toList();
    });

    // ✅ Only called when tasks exist
    _showSuggestedTasksSheet();
  }


  void _showSuggestedTasksSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Suggested Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: _suggestedTaskItems.map((item) {
                        final task = item.task;
                        return CheckboxListTile(
                          value: item.selected,
                          onChanged: (v) {
                            sheetSetState(() {
                              item.selected = v ?? true;
                            });
                          },
                          title: Text(task.title),
                          subtitle: Text(
                            '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}'
                                '${task.note != null ? '\n${task.note}' : ''}',
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _saveSelectedSuggestedTasks,
                    child: const Text('Add Selected Tasks'),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveSelectedSuggestedTasks() async {
    final selected = _suggestedTaskItems.where((e) => e.selected).toList();

    if (selected.isEmpty) {
      Navigator.pop(context);
      return;
    }

    for (final item in selected) {
      await TaskStorage.instance.addTask(
        title: item.task.title,
        type: 'auto-${item.task.title.toLowerCase().replaceAll(' ', '_')}',
        dateTime: item.task.dueDate,
        notes: item.task.note,
      );
    }

    setState(() {
      _suggestedTaskItems.clear();
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selected.length} tasks added')),
    );
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
    // ✅ STEP 7.3 — regenerate task suggestions for new stage
    _generateSuggestedTasks(
      cropName: tile.crop!.label.toLowerCase(),
      stage: CropStage.values.byName(newStage.name),
      stageStartDate: DateTime.now(),
      fieldId: field.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked ${tile.crop!.label}: ${newStage.label}')),
    );
  }

  // ---------- Sheets ----------
  Future<void> _openPlantSheet(FarmField field, FarmTile tile) async {
    final isLoggedIn = await AuthState.instance.isLoggedIn();

    final allowed = await AuthGuard.ensureLoggedIn(
      context,
      isLoggedIn: isLoggedIn,
      onLogin: () {
        debugPrint('User chose to login');
      },
    );

    if (!allowed) return;

    // ✅ EXISTING LOGIC (UNCHANGED)
    showModalBottomSheet(
      context: context,
      builder: (_) => PlantTileSheet(
        onPick: (kind, density) async {
          final isLoggedIn = await AuthState.instance.isLoggedIn();

          final allowed = await AuthGuard.ensureLoggedIn(
            context,
            isLoggedIn: isLoggedIn,
            onLogin: () {
              debugPrint('User chose to login');
            },
          );

          if (!allowed) return;

          // ✅ CORRECT: create a NEW non-empty tile
          final newTile = FarmTile(
            x: tile.x,
            y: tile.y,
            crop: kind,
            density: density,
            stage: TileStage.sown,
          );

          _setTile(field, tile, newTile);

          _generateSuggestedTasks(
            cropName: kind.label.toLowerCase(),
            stage: CropStage.sown,
            stageStartDate: DateTime.now(),
            fieldId: field.id,
          );

          Navigator.pop(context);
        },




        // ✅ REQUIRED FIX — ADD THIS
        onOpenSoil: () {
          Navigator.pop(context); // close sheet
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

  // ---------- Quick-create Add Task (from tile) ----------
  void _openAddTaskFromTile(FarmField field, FarmTile tile) {
    // Pre-fill field id and crop label and stage name
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddTaskSheet(
        prefillFieldId: field.id,
        prefillCropLabel: tile.crop?.label,
        prefillStageName: tile.stage?.name,
      ),
    ).then((saved) {
      if (saved == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
      }
    });
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
        LayoutBuilder(builder: (context, constraints) {
          final availableW = constraints.maxWidth;
          const double visibleFraction = 0.90;
          final pageVisibleWidth = availableW * visibleFraction;
          const double farmAspectRatio = 1.5;
          final double farmHeight = pageVisibleWidth / farmAspectRatio;
          const double cardHeaderHeight = 52.0;
          final double bottomInset = MediaQuery.of(context).padding.bottom;
          const double smallBuffer = 18.0;
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
                    // pass addTask callback to grid? The grid will pass it to tile views
                  ),
                );
              },
            ),
          );
        }),

        const SizedBox(height: 14),

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
                    width: selected ? 22 : 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withOpacity(0.9)
                          : primary.withOpacity(0.30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final isLoggedIn = await AuthState.instance.isLoggedIn();

                final allowed = await AuthGuard.ensureLoggedIn(
                  context,
                  isLoggedIn: isLoggedIn,
                  onLogin: () {
                    debugPrint('User chose to login');
                  },
                );

                if (!allowed) return;

                // ✅ EXISTING LOGIC (UNCHANGED)
                _createFieldDialog();
              },

              icon: const Icon(Icons.add),
              label: const Text('Add field'),
            ),
          ],
        ),

        const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 10), // more breathing room
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          // Soft ground-like gradient
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6EFE7), // warm soil tint top
              Color(0xFFEDE3D6), // soft ground mid
              Color(0xFFE6DACB), // earth-like bottom
            ],
          ),

          // Light border to keep definition
          border: Border.all(
            color: Colors.black12,
            width: 0.8,
          ),

          // Deeper, softer outer shadow for "real card"
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle inner glow for depth (first layer)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.03),
                      Colors.black.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main header row (top)
            Positioned(
              left: 12,
              right: 12,
              top: 6,
              child: Row(
                children: [
                  Icon(Icons.terrain_rounded, color: primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Rename field',
                    icon: const Icon(Icons.edit_note, size: 22),
                    onPressed: onRename,
                  ),
                  IconButton(
                    tooltip: 'Delete field',
                    icon: const Icon(Icons.delete_outline_rounded, size: 22),
                    onPressed: onDelete,
                  ),
                  IconButton(
                    tooltip: 'Add new field',
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    onPressed: onAdd,
                  ),
                ],
              ),
            ),

            // Main content area (child passed from parent) — keep the same top offset as before
            Positioned.fill(
              top: 44,
              child: child,
            ),

            // Subtle bottom fade for clean edge
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 28,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white70,
                        Colors.transparent,
                      ],
                    ),
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
          padding: EdgeInsets.fromLTRB(
            padding + 2, // slightly wider breathing room
            padding + safeTopPad, // keep top centering logic
            padding + 2,
            padding + 4, // more room at bottom
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
                _buildGrid(context, cellSize),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, double cellSize) {
    final totalCells = field.rows * field.cols;

    // Build each cell widget and force exact sizing via SizedBox.
    final cellWidgets = <Widget>[];
    for (var y = 0; y < field.rows; y++) {
      for (var x = 0; x < field.cols; x++) {
        final tile = field.tileAt(x, y)!;

        final bool highDensity = (tile.density ?? 1) >= 3;

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

        final child = AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Stack(
            children: [
              SizedBox(
                width: cellSize,
                height: cellSize,
                child: FarmTileView(
                  tile: tile,
                  size: cellSize,
                  onTap: () => onTileTap(tile),
                  onLongPress:
                  onTileLongPress == null ? null : () => onTileLongPress!(tile),
                  onAddTask: () {
                    // quick-create a task for this tile
                    // note: we need access to the parent field here; we capture field from outer scope
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Use the parent's method to open the sheet
                      // Since this is a callback inside a stateless widget, call through context via ancestor state:
                      final state = context.findAncestorStateOfType<_FarmCanvasState>();
                      state?._openAddTaskFromTile(field, tile);
                    });
                  },
                ),
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
        );

        // Wrap into fixed-size container so Grid delegate cannot be nudged to a different size.
        cellWidgets.add(SizedBox(width: cellSize, height: cellSize, child: child));
      }
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalCells,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: field.cols,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0, // force square cells
      ),
      itemBuilder: (context, index) {
        return cellWidgets[index];
      },
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
    final baseColor = color.withOpacity(0.07); // softer, more natural
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor
      ..strokeWidth = lineWidth;

    // Draw vertical dividers
    for (int c = 0; c <= cols; c++) {
      final x = (c * cellSize).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Draw horizontal dividers
    for (int r = 0; r <= rows; r++) {
      final y = (r * cellSize).clamp(0.0, size.height);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Optional dot grid for a subtle land texture
    if (showDots) {
      final dotPaint = Paint()..color = baseColor.withOpacity(0.5);
      final dotRadius = (cellSize * 0.03).clamp(0.6, 2.0);

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final cx = (c + 0.5) * cellSize;
          final cy = (r + 0.5) * cellSize;
          canvas.drawCircle(Offset(cx, cy), dotRadius, dotPaint);
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
