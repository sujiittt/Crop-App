import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisLoadingWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const AnalysisLoadingWidget({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<AnalysisLoadingWidget> createState() => _AnalysisLoadingWidgetState();
}

class _AnalysisLoadingWidgetState extends State<AnalysisLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _tipController;
  late Animation<double> _progressAnimation;
  late Animation<double> _tipAnimation;

  int _currentTipIndex = 0;

  final List<Map<String, dynamic>> _analysisSteps = [
    {
      'title': 'Processing soil data...',
      'tip': 'Soil pH affects nutrient availability to plants',
      'icon': 'science',
      'progress': 0.25,
    },
    {
      'title': 'Analyzing nutrient levels...',
      'tip': 'Nitrogen promotes leafy growth in crops',
      'icon': 'eco',
      'progress': 0.50,
    },
    {
      'title': 'Matching crop requirements...',
      'tip': 'Different crops thrive in different soil conditions',
      'icon': 'agriculture',
      'progress': 0.75,
    },
    {
      'title': 'Generating recommendations...',
      'tip': 'Crop rotation helps maintain soil health',
      'icon': 'lightbulb',
      'progress': 1.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnalysis();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _tipController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _tipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tipController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnalysis() async {
    for (int i = 0; i < _analysisSteps.length; i++) {
      setState(() => _currentTipIndex = i);

      _tipController.forward();
      _progressController.animateTo(_analysisSteps[i]['progress']);

      await Future.delayed(Duration(milliseconds: 2000));

      if (i < _analysisSteps.length - 1) {
        _tipController.reverse();
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    await Future.delayed(Duration(milliseconds: 500));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
            AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: 4.h),
          _buildProgressSection(),
          SizedBox(height: 4.h),
          _buildTipSection(),
          SizedBox(height: 4.h),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.primaryColor,
            size: 32,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Analyzing Your Soil',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Please wait while we process your soil data',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value *
                  _analysisSteps[_currentTipIndex]['progress'],
              backgroundColor:
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.primaryColor,
              ),
              minHeight: 8,
            );
          },
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _analysisSteps[_currentTipIndex]['title'],
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${((_analysisSteps[_currentTipIndex]['progress'] as double) * 100).round()}%',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipSection() {
    return AnimatedBuilder(
      animation: _tipAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _tipAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _tipAnimation.value) * 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.getAccentColor(true).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getAccentColor(true).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color:
                      AppTheme.getAccentColor(true).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _analysisSteps[_currentTipIndex]['icon'],
                      color: AppTheme.getAccentColor(true),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agricultural Tip',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.getAccentColor(true),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _analysisSteps[_currentTipIndex]['tip'],
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(
              alpha: _currentTipIndex >= index ? 1.0 : 0.3,
            ),
            borderRadius: BorderRadius.circular(1.w),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _tipController.dispose();
    super.dispose();
  }
}
