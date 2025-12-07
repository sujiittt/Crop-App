// lib/presentation/dashboard_screen/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'widgets/crop_recommendations_widget.dart';
import 'widgets/government_schemes_widget.dart';
import 'widgets/soil_analysis_card_widget.dart';
import 'widgets/task_card_widget.dart';
import 'widgets/quick_actions_sheet.dart';
import '../widgets/farm_canvas/farm_canvas.dart';
import '../widgets/farm_canvas/weather_location_chips.dart';




import 'package:cropwise/widgets/profile_action_icon.dart';
// ✅ correct relative path (we are already in presentation/dashboard_screen)
import '../widgets/top_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  String _lastUpdated = '';

  // mock data (kept from earlier)
  final Map<String, dynamic> _weatherData = {
    'location': 'Pune, Maharashtra',
    'temperature': 28,
    'condition': 'Sunny',
    'humidity': 65,
    'alert': null,
  };

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

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: // Home
        Navigator.popUntil(context, (r) => r.isFirst);
        break;
      case 1: // Mandi
        Navigator.pushNamed(context, '/mandi-prices-screen');
        break;
      case 2: // Soil Test (center)
        Navigator.pushNamed(context, '/soil-analysis-screen');
        break;
      case 3: // Schemes
        Navigator.pushNamed(context, '/government-schemes-screen');
        break;
      case 4: // Weather
        Navigator.pushNamed(context, '/weather-forecast-screen');
        break;
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => QuickActionsSheet(onAction: (key) {
        Navigator.pop(ctx);
        if (key == 'new_task') Navigator.pushNamed(ctx, '/tasks-screen');
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text('Action: $key')));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    // --- bottom bar constants (safe spacing fix) ---
    const double centerCircleDiameter = 88.0;
    const double labelAreaHeight = 30.0; // slightly smaller to remove overflow
    const double _bottomCushion = 8.0;

    final double _totalBarHeight =
        kBottomNavigationBarHeight + (centerCircleDiameter / 2) + labelAreaHeight + _bottomCushion;  // new: small safety padding


    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,

      // Top app bar with + moved here
      appBar: TopAppBar(
        title: 'CropWise',
        lastUpdatedText: _lastUpdated,
        isOnline: _isOnline,
        onAddPressed: _showQuickActions,
        onNotificationsPressed: () {
          Navigator.pushNamed(context, '/tasks-screen');
        },
        notificationCount: _todaysTasks.length, // or 0 to hide
      ),


      // Body with extra bottom padding so the center pill/labels never overlap
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12 + (centerCircleDiameter / 2) + bottomSafe + (labelAreaHeight / 2) + _bottomCushion,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FarmCanvas(),
              const SizedBox(height: 8),
              WeatherLocationChips(
                // Hook these to your existing data if you have:
                // location: _weatherData?.locationName ?? 'Your farm',
                // temperature: _weatherData?.tempString ?? '—°C',
                // condition: _weatherData?.condition ?? '—',
                onTapWeather: () => Navigator.pushNamed(context, '/weather-forecast-screen'),
                onTapLocation: () => Navigator.pushNamed(context, '/farmer-registration-screen'),
              ),
              const SizedBox(height: 12),

              TaskCardWidget(tasks: _todaysTasks),
              const SizedBox(height: 12),
              SoilAnalysisCardWidget(soilData: _soilAnalysisData),
              const SizedBox(height: 12),
              CropRecommendationsWidget(recommendations: _cropRecommendations),
              const SizedBox(height: 12),
              GovernmentSchemesWidget(schemes: _governmentSchemes),
              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),

      // Bottom navigation with fixed index mapping and centered Soil Test pill
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: _totalBarHeight,
          child: Stack(

          alignment: Alignment.topCenter,
            children: [
              // Bottom bar (shifted down so the pill sits above it)
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
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left group: Home + Mandi
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            _BottomItem(
                              icon: Icons.home_outlined,
                              label: 'Home',
                              selected: _selectedIndex == 0,
                              onTap: () => _onBottomNavTap(0),
                            ),
                            _BottomItem(
                              icon: Icons.store_mall_directory_outlined,
                              label: 'Mandi',
                              selected: _selectedIndex == 1, // ✅ correct index
                              onTap: () => _onBottomNavTap(1),
                            ),
                          ],
                        ),

                        // Right group: Schemes + Weather
                        Row(
                          children: [
                            _BottomItem(
                              icon: Icons.account_balance_outlined,
                              label: 'Schemes',
                              selected: _selectedIndex == 3, // ✅ correct index
                              onTap: () => _onBottomNavTap(3),
                            ),
                            const SizedBox(width: 8),
                            _BottomItem(
                              icon: Icons.wb_cloudy_outlined,
                              label: 'Weather',
                              selected: _selectedIndex == 4, // ✅ correct index
                              onTap: () => _onBottomNavTap(4),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Center circle (Soil Test) with its own label below
              Positioned(
                top: 0,
                child: Column(
                  children: [
                    // Outer white shadow circle
                    Container(
                      width: centerCircleDiameter,
                      height: centerCircleDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _onBottomNavTap(2),
                          child: Container(
                            width: 62.0,
                            height: 62.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedIndex == 2
                                  ? AppTheme.lightTheme.primaryColor
                                  : Colors.white,
                              border: Border.all(
                                color: _selectedIndex == 2
                                    ? Colors.transparent
                                    : AppTheme.lightTheme.primaryColor,
                                width: 2.4,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.biotech_outlined,
                                size: 32,
                                color: _selectedIndex == 2
                                    ? Colors.white
                                    : AppTheme.lightTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: labelAreaHeight,
                      child: Center(
                        child: Text(
                          'Soil Test',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == 2
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.textSecondary,
                          ),
                        ),
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
  }
}

/// A small bottom item (icon + label) with proper theming & bigger tap target.
class _BottomItem extends StatelessWidget {
  const _BottomItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final baseColor = theme.colorScheme.onSurface.withOpacity(0.72);
    final color = selected ? selectedColor : baseColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            height: 44,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
