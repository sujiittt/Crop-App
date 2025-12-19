import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/auth/auth_guard.dart';
import '../../core/auth/auth_state.dart';

import 'widgets/crop_recommendations_widget.dart';
import 'widgets/government_schemes_widget.dart';
import 'widgets/soil_analysis_card_widget.dart';
import 'widgets/task_card_widget.dart';
import 'widgets/quick_actions_sheet.dart';

import '../widgets/farm_canvas/farm_canvas.dart';
import '../widgets/farm_canvas/weather_location_chips.dart';
import '../widgets/top_app_bar.dart';

import '../profile_screen/profile_screen.dart';
import '../tasks_screen/tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  String _lastUpdated = '';

  final List<Map<String, dynamic>> _todaysTasks = [
    {'id': 1, 'title': 'Soil pH Test - Field A', 'priority': 'high'},
    {'id': 2, 'title': 'Crop Recommendation Review', 'priority': 'medium'},
    {'id': 3, 'title': 'Government Scheme Application', 'priority': 'high'},
  ];

  final Map<String, dynamic> _soilAnalysisData = {
    'date': '15 Sep 2025',
    'ph': 6.8,
    'nitrogen': 45,
    'phosphorus': 38,
    'potassium': 52,
    'status': 'Good',
  };

  final List<Map<String, dynamic>> _cropRecommendations = [
    {'id': 1, 'name': 'Wheat', 'suitability': 85},
    {'id': 2, 'name': 'Sugarcane', 'suitability': 78},
  ];

  final List<Map<String, dynamic>> _governmentSchemes = [
    {
      'id': 1,
      'name': 'PM-KISAN Samman Nidhi',
      'description': 'Direct income support',
      'benefit': '₹6,000/year'
    },
  ];

  @override
  void initState() {
    super.initState();
    _lastUpdated = _formatCurrentTime();
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _lastUpdated = _formatCurrentTime());
  }

  /// 🔐 Step 4.4 – Profile guarded
  Future<void> _onProfileTap() async {
    final isLoggedIn = await AuthState.instance.isLoggedIn();

    final allowed = await AuthGuard.ensureLoggedIn(
      context,
      isLoggedIn: isLoggedIn,
      onLogin: () {
        debugPrint('User chose to login');
      },
    );

    if (!allowed) return;

    Navigator.pushNamed(context, ProfileScreen.routeName);
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => QuickActionsSheet(onAction: (key) {
        Navigator.pop(ctx);
        if (key == 'new_task') {
          Navigator.pushNamed(ctx, TasksScreen.routeName);
        }
      }),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.popUntil(context, (r) => r.isFirst);
        break;
      case 1:
        Navigator.pushNamed(context, '/mandi-prices-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/soil-analysis-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/government-schemes-screen');
        break;
      case 4:
        Navigator.pushNamed(context, '/weather-forecast-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    const double centerCircleDiameter = 88.0;
    const double labelAreaHeight = 30.0;
    const double bottomCushion = 8.0;

    final totalBarHeight =
        kBottomNavigationBarHeight +
            (centerCircleDiameter / 2) +
            labelAreaHeight +
            bottomCushion;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: TopAppBar(
        title: 'CropWise',
        lastUpdatedText: _lastUpdated,
        isOnline: _isOnline,
        onAddPressed: _showQuickActions,
        onNotificationsPressed: () {
          Navigator.pushNamed(context, '/tasks-screen');
        },
        notificationCount: _todaysTasks.length,
      ),







      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12 +
                (centerCircleDiameter / 2) +
                bottomSafe +
                (labelAreaHeight / 2) +
                bottomCushion,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FarmCanvas(),
              const SizedBox(height: 8),
              WeatherLocationChips(
                onTapWeather: () =>
                    Navigator.pushNamed(context, '/weather-forecast-screen'),
                onTapLocation: () =>
                    Navigator.pushNamed(context, '/farmer-registration-screen'),
              ),
              const SizedBox(height: 12),
              TaskCardWidget(tasks: _todaysTasks),
              const SizedBox(height: 12),
              SoilAnalysisCardWidget(soilData: _soilAnalysisData),
              const SizedBox(height: 12),
              CropRecommendationsWidget(
                  recommendations: _cropRecommendations),
              const SizedBox(height: 12),
              GovernmentSchemesWidget(schemes: _governmentSchemes),
              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: totalBarHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: centerCircleDiameter / 2,
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomAppBar(
                  elevation: 8,
                  color: AppTheme.lightTheme.cardColor,
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 6,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _BottomItem(
                              icon: Icons.home_outlined,
                              label: 'Home',
                              selected: _selectedIndex == 0,
                              onTap: () => _onBottomNavTap(0),
                            ),
                            _BottomItem(
                              icon: Icons.store_mall_directory_outlined,
                              label: 'Mandi',
                              selected: _selectedIndex == 1,
                              onTap: () => _onBottomNavTap(1),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _BottomItem(
                              icon: Icons.account_balance_outlined,
                              label: 'Schemes',
                              selected: _selectedIndex == 3,
                              onTap: () => _onBottomNavTap(3),
                            ),
                            _BottomItem(
                              icon: Icons.wb_cloudy_outlined,
                              label: 'Weather',
                              selected: _selectedIndex == 4,
                              onTap: () => _onBottomNavTap(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0,
                child: GestureDetector(
                  onTap: () => _onBottomNavTap(2),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                    child: const Icon(Icons.biotech_outlined,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
