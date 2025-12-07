import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsFabWidget extends StatefulWidget {
  const QuickActionsFabWidget({Key? key}) : super(key: key);

  @override
  State<QuickActionsFabWidget> createState() => _QuickActionsFabWidgetState();
}

class _QuickActionsFabWidgetState extends State<QuickActionsFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h, right: 2.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ScaleTransition(
            scale: _animation,
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: 'search',
                  label: 'Scheme Search',
                  onPressed: () {
                    Navigator.pushNamed(context, '/government-schemes-screen');
                    _toggleFab();
                  },
                ),
                SizedBox(height: 1.2.h),
                _buildActionButton(
                  icon: 'wb_cloudy',
                  label: 'Weather Alert',
                  onPressed: () {
                    Navigator.pushNamed(context, '/weather-forecast-screen');
                    _toggleFab();
                  },
                ),
                SizedBox(height: 1.2.h),
                _buildActionButton(
                  icon: 'science',
                  label: 'New Soil Test',
                  onPressed: () {
                    Navigator.pushNamed(context, '/soil-analysis-screen');
                    _toggleFab();
                  },
                ),
              ],
            ),
          ),
          FloatingActionButton(
            elevation: 4,
            onPressed: _toggleFab,
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: CustomIconWidget(
                iconName: _isExpanded ? 'close' : 'add',
                color: Colors.black,
                size: 24.sp, // <-- fixed: larger and consistent across screens
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          FloatingActionButton.small(
            onPressed: onPressed,
            backgroundColor: AppTheme.lightTheme.primaryColor,
            heroTag: label,
            child: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 16.sp, // adjusted for better visibility
            ),
          ),
        ],
      ),
    );
  }
}
