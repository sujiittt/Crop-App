import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/agricultural_calendar_widget.dart';
import './widgets/current_weather_card.dart';
import './widgets/daily_forecast_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/weather_alerts_widget.dart';
import 'package:cropwise/widgets/profile_action_icon.dart';

class WeatherForecastScreen extends StatefulWidget {
  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen>
    with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
  bool _showDetailedMetrics = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data for current weather
  final Map<String, dynamic> currentWeather = {
    "location": "Pune, Maharashtra",
    "gpsAccuracy": "High (±3m)",
    "temperature": 28,
    "feelsLike": 32,
    "condition": "Partly Cloudy",
    "conditionIcon": "partly_cloudy_day",
    "humidity": "68%",
    "windSpeed": "12 km/h",
    "uvIndex": "6 (High)",
    "soilTemp": "24°C",
    "pressure": "1013 mb",
    "dewPoint": "21°C",
    "visibility": "10 km",
  };

  // Mock data for hourly forecast
  final List<Map<String, dynamic>> hourlyForecast = [
    {
      "time": "Now",
      "temp": 28,
      "icon": "partly_cloudy_day",
      "precipitation": 15,
      "windSpeed": "12",
      "windDirection": 45,
    },
    {
      "time": "2 PM",
      "temp": 30,
      "icon": "wb_sunny",
      "precipitation": 5,
      "windSpeed": "14",
      "windDirection": 60,
    },
    {
      "time": "3 PM",
      "temp": 32,
      "icon": "wb_sunny",
      "precipitation": 0,
      "windSpeed": "16",
      "windDirection": 75,
    },
    {
      "time": "4 PM",
      "temp": 31,
      "icon": "cloud",
      "precipitation": 20,
      "windSpeed": "18",
      "windDirection": 90,
    },
    {
      "time": "5 PM",
      "temp": 29,
      "icon": "cloud",
      "precipitation": 35,
      "windSpeed": "15",
      "windDirection": 105,
    },
    {
      "time": "6 PM",
      "temp": 27,
      "icon": "grain",
      "precipitation": 60,
      "windSpeed": "12",
      "windDirection": 120,
    },
    {
      "time": "7 PM",
      "temp": 25,
      "icon": "grain",
      "precipitation": 80,
      "windSpeed": "10",
      "windDirection": 135,
    },
    {
      "time": "8 PM",
      "temp": 24,
      "icon": "cloud",
      "precipitation": 40,
      "windSpeed": "8",
      "windDirection": 150,
    },
  ];

  // Mock data for daily forecast
  final List<Map<String, dynamic>> dailyForecast = [
    {
      "day": "Today",
      "date": "Sep 22",
      "high": 32,
      "low": 22,
      "icon": "partly_cloudy_day",
      "rainChance": 25,
      "humidity": "68%",
      "wind": "12-18 km/h NE",
      "uvIndex": 6,
      "pressure": 1013,
      "visibility": 10,
      "dewPoint": 21,
      "alerts": [
        {
          "severity": "low",
          "icon": "wb_sunny",
          "message": "Ideal conditions for pesticide application",
        }
      ],
      "farmingActivities": [
        {
          "icon": "water_drop",
          "title": "Irrigation Timing",
          "description":
          "Early morning irrigation recommended due to low wind and moderate humidity",
        },
        {
          "icon": "bug_report",
          "title": "Pest Control",
          "description":
          "Good conditions for pesticide application between 6-8 AM",
        }
      ]
    },
    {
      "day": "Tomorrow",
      "date": "Sep 23",
      "high": 29,
      "low": 20,
      "icon": "grain",
      "rainChance": 75,
      "humidity": "85%",
      "wind": "8-15 km/h SW",
      "uvIndex": 3,
      "pressure": 1008,
      "visibility": 6,
      "dewPoint": 24,
      "alerts": [
        {
          "severity": "medium",
          "icon": "umbrella",
          "message": "Heavy rain expected - avoid field operations",
        }
      ],
      "farmingActivities": [
        {
          "icon": "home",
          "title": "Indoor Activities",
          "description":
          "Focus on equipment maintenance and planning due to expected rainfall",
        }
      ]
    },
    {
      "day": "Monday",
      "date": "Sep 24",
      "high": 26,
      "low": 18,
      "icon": "cloud",
      "rainChance": 40,
      "humidity": "72%",
      "wind": "10-16 km/h N",
      "uvIndex": 4,
      "pressure": 1015,
      "visibility": 8,
      "dewPoint": 19,
      "alerts": [],
      "farmingActivities": [
        {
          "icon": "agriculture",
          "title": "Field Assessment",
          "description":
          "Good day for checking crop conditions after weekend rain",
        }
      ]
    },
    {
      "day": "Tuesday",
      "date": "Sep 25",
      "high": 31,
      "low": 21,
      "icon": "wb_sunny",
      "rainChance": 10,
      "humidity": "58%",
      "wind": "14-20 km/h NE",
      "uvIndex": 7,
      "pressure": 1018,
      "visibility": 12,
      "dewPoint": 18,
      "alerts": [
        {
          "severity": "low",
          "icon": "eco",
          "message": "Excellent harvesting conditions",
        }
      ],
      "farmingActivities": [
        {
          "icon": "agriculture",
          "title": "Harvesting",
          "description": "Perfect conditions for harvesting mature crops",
        },
        {
          "icon": "local_shipping",
          "title": "Transportation",
          "description": "Good weather for transporting harvested produce",
        }
      ]
    },
    {
      "day": "Wednesday",
      "date": "Sep 26",
      "high": 33,
      "low": 23,
      "icon": "wb_sunny",
      "rainChance": 5,
      "humidity": "52%",
      "wind": "16-22 km/h E",
      "uvIndex": 8,
      "pressure": 1020,
      "visibility": 15,
      "dewPoint": 16,
      "alerts": [
        {
          "severity": "medium",
          "icon": "warning",
          "message": "High UV - protect workers during midday",
        }
      ],
      "farmingActivities": [
        {
          "icon": "schedule",
          "title": "Early Operations",
          "description":
          "Schedule field work for early morning and late afternoon",
        }
      ]
    },
    {
      "day": "Thursday",
      "date": "Sep 27",
      "high": 30,
      "low": 22,
      "icon": "partly_cloudy_day",
      "rainChance": 20,
      "humidity": "65%",
      "wind": "12-18 km/h SE",
      "uvIndex": 6,
      "pressure": 1016,
      "visibility": 10,
      "dewPoint": 20,
      "alerts": [],
      "farmingActivities": [
        {
          "icon": "grass",
          "title": "Soil Preparation",
          "description": "Good conditions for land preparation and sowing",
        }
      ]
    },
    {
      "day": "Friday",
      "date": "Sep 28",
      "high": 28,
      "low": 19,
      "icon": "cloud",
      "rainChance": 45,
      "humidity": "78%",
      "wind": "8-14 km/h SW",
      "uvIndex": 4,
      "pressure": 1012,
      "visibility": 8,
      "dewPoint": 22,
      "alerts": [
        {
          "severity": "low",
          "icon": "water_drop",
          "message": "Natural irrigation expected",
        }
      ],
      "farmingActivities": [
        {
          "icon": "eco",
          "title": "Crop Monitoring",
          "description":
          "Monitor young plants for disease after expected moisture",
        }
      ]
    },
  ];

  // Mock data for weather alerts
  final List<Map<String, dynamic>> weatherAlerts = [
    {
      "severity": "high",
      "icon": "warning",
      "title": "Heat Stress Warning",
      "type": "Agricultural Advisory",
      "description":
      "High temperatures expected tomorrow. Ensure adequate water supply for livestock and consider early morning field operations.",
      "validUntil": "Sep 24, 6:00 PM",
    },
    {
      "severity": "medium",
      "icon": "bug_report",
      "title": "Pest Outbreak Conditions",
      "type": "Crop Protection",
      "description":
      "Weather conditions favorable for aphid activity. Monitor crops closely and consider preventive measures.",
      "validUntil": "Sep 26, 12:00 PM",
    },
    {
      "severity": "low",
      "icon": "eco",
      "title": "Optimal Planting Window",
      "type": "Farming Opportunity",
      "description":
      "Soil moisture and temperature conditions are ideal for sowing winter crops in the next 3 days.",
      "validUntil": "Sep 25, 11:59 PM",
    },
  ];

  // Mock data for agricultural calendar
  final List<Map<String, dynamic>> agriculturalRecommendations = [
    {
      "category": "irrigation",
      "icon": "water_drop",
      "title": "Morning Irrigation Schedule",
      "description":
      "Optimal soil moisture conditions detected. Schedule irrigation between 5:00-7:00 AM for maximum efficiency and minimal water loss.",
      "priority": "high",
      "bestTime": "5:00-7:00 AM",
      "conditions": "Low wind, moderate humidity",
      "weatherDependency": "No rain expected for next 24 hours",
    },
    {
      "category": "pesticide",
      "icon": "bug_report",
      "title": "Pesticide Application Window",
      "description":
      "Weather conditions are favorable for pesticide application. Low wind speed and no rain forecast ensure effective treatment.",
      "priority": "medium",
      "bestTime": "6:00-8:00 AM",
      "conditions": "Wind < 15 km/h, no rain",
      "weatherDependency": "Avoid if rain expected within 6 hours",
    },
    {
      "category": "harvesting",
      "icon": "agriculture",
      "title": "Harvest Readiness Alert",
      "description":
      "Crops have reached optimal moisture content. Clear weather forecast makes this an ideal harvesting period.",
      "priority": "high",
      "bestTime": "8:00 AM - 4:00 PM",
      "conditions": "Dry, sunny weather",
      "weatherDependency": null,
    },
    {
      "category": "planting",
      "icon": "eco",
      "title": "Winter Crop Sowing",
      "description":
      "Soil temperature and moisture levels are perfect for winter crop germination. Take advantage of this optimal planting window.",
      "priority": "medium",
      "bestTime": "Morning hours",
      "conditions": "Soil temp 18-25°C",
      "weatherDependency": "Stable weather pattern for next week",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshWeatherData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weather data updated successfully'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleDetailedMetrics() {
    setState(() {
      _showDetailedMetrics = !_showDetailedMetrics;
    });
  }

  void _shareWeatherReport() {
    // Mock share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weather report prepared for sharing'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final appBarTheme = theme.appBarTheme;
    final bg = appBarTheme.backgroundColor ?? theme.primaryColor;
    final fg = appBarTheme.foregroundColor ??
        theme.colorScheme.onPrimary; // <- safe fallback

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Weather Forecast',
          style: appBarTheme.titleTextStyle ??
              theme.textTheme.titleLarge?.copyWith(color: fg),
        ),
        backgroundColor: bg,
        elevation: appBarTheme.elevation ?? 0,
        actions: [
          IconButton(
            onPressed: _shareWeatherReport,
            icon: CustomIconWidget(
              iconName: 'share',
              color: fg,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Weather alert settings'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'notifications',
              color: fg,
              size: 24,
            ),
          ),
          const ProfileActionIcon(),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshWeatherData,
          color: theme.primaryColor,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurrentWeatherCard(currentWeather: currentWeather),

                  GestureDetector(
                    onTap: _toggleDetailedMetrics,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showDetailedMetrics
                                ? 'Hide Details'
                                : 'Show Detailed Metrics',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName:
                            _showDetailedMetrics ? 'expand_less' : 'expand_more',
                            color: theme.primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showDetailedMetrics) ...[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detailed Farming Metrics",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailedMetric(
                                  "Barometric Pressure",
                                  currentWeather["pressure"] as String,
                                  "speed",
                                ),
                              ),
                              Expanded(
                                child: _buildDetailedMetric(
                                  "Dew Point",
                                  currentWeather["dewPoint"] as String,
                                  "thermostat",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _buildDetailedMetric(
                            "Visibility",
                            currentWeather["visibility"] as String,
                            "visibility",
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 2.h),
                  HourlyForecastWidget(hourlyData: hourlyForecast),
                  SizedBox(height: 2.h),
                  WeatherAlertsWidget(alerts: weatherAlerts),
                  SizedBox(height: 2.h),
                  DailyForecastWidget(dailyData: dailyForecast),
                  SizedBox(height: 2.h),
                  AgriculturalCalendarWidget(
                    recommendations: agriculturalRecommendations,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedMetric(String label, String value, String icon) {
    final theme = AppTheme.lightTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
