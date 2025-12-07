import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ManualInputWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onValuesChanged;

  const ManualInputWidget({
    Key? key,
    required this.onValuesChanged,
  }) : super(key: key);

  @override
  State<ManualInputWidget> createState() => _ManualInputWidgetState();
}

class _ManualInputWidgetState extends State<ManualInputWidget> {
  double _phValue = 7.0;
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  String _selectedUnit = 'kg/ha';

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    widget.onValuesChanged({
      'ph': _phValue,
      'nitrogen': double.tryParse(_nitrogenController.text) ?? 0.0,
      'phosphorus': double.tryParse(_phosphorusController.text) ?? 0.0,
      'potassium': double.tryParse(_potassiumController.text) ?? 0.0,
      'unit': _selectedUnit,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Soil Test Values',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildPhSlider(),
        SizedBox(height: 3.h),
        _buildNutrientInputs(),
      ],
    );
  }

  Widget _buildPhSlider() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'pH Level',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getPhColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _phValue.toStringAsFixed(1),
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: _getPhColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _phValue,
              min: 0.0,
              max: 14.0,
              divisions: 140,
              onChanged: (value) {
                setState(() {
                  _phValue = value;
                });
                _updateValues();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Acidic (0)',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                'Neutral (7)',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                'Alkaline (14)',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            _getPhDescription(),
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInputs() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nutrient Levels',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButton<String>(
                value: _selectedUnit,
                items: ['kg/ha', 'ppm', 'mg/kg'].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedUnit = newValue;
                    });
                    _updateValues();
                  }
                },
                underline: Container(),
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildNutrientField(
            label: 'Nitrogen (N)',
            controller: _nitrogenController,
            icon: 'eco',
            color: Colors.green,
          ),
          SizedBox(height: 2.h),
          _buildNutrientField(
            label: 'Phosphorus (P)',
            controller: _phosphorusController,
            icon: 'local_florist',
            color: Colors.orange,
          ),
          SizedBox(height: 2.h),
          _buildNutrientField(
            label: 'Potassium (K)',
            controller: _potassiumController,
            icon: 'grass',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientField({
    required String label,
    required TextEditingController controller,
    required String icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: label,
              suffixText: _selectedUnit,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            ),
            onChanged: (value) => _updateValues(),
          ),
        ),
      ],
    );
  }

  Color _getPhColor() {
    if (_phValue < 6.0) return Colors.red;
    if (_phValue > 8.0) return Colors.blue;
    return AppTheme.getSuccessColor(true);
  }

  String _getPhDescription() {
    if (_phValue < 6.0) return 'Acidic soil - may need lime treatment';
    if (_phValue > 8.0) return 'Alkaline soil - may need sulfur treatment';
    return 'Optimal pH range for most crops';
  }

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    super.dispose();
  }
}
