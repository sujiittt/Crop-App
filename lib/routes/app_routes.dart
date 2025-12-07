import 'package:flutter/material.dart';
import '../presentation/crop_recommendations_screen/crop_recommendations_screen.dart';
import '../presentation/farmer_registration_screen/farmer_registration_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/government_schemes_screen/government_schemes_screen.dart';
import '../presentation/soil_analysis_screen/soil_analysis_screen.dart';
import '../presentation/weather_forecast_screen/weather_forecast_screen.dart';
import 'package:cropwise/presentation/profile_screen/profile_screen.dart';
import 'package:cropwise/presentation/mandi_prices_screen/mandi_prices_screen.dart';
import 'package:cropwise/presentation/tasks_screen/tasks_screen.dart';


class AppRoutes {
  // Route constants
  static const String initial = '/';
  static const String cropRecommendations = '/crop-recommendations-screen';
  static const String farmerRegistration = '/farmer-registration-screen';
  static const String dashboard = '/dashboard-screen';
  static const String governmentSchemes = '/government-schemes-screen';
  static const String soilAnalysis = '/soil-analysis-screen';
  static const String weatherForecast = '/weather-forecast-screen';

  static Map<String, WidgetBuilder> routes = {
    // initial: (context) => const DashboardScreen(),
    cropRecommendations: (context) => const CropRecommendationsScreen(),
    farmerRegistration: (context) => const FarmerRegistrationScreen(),
    dashboard: (context) => const DashboardScreen(),
    governmentSchemes: (context) => const GovernmentSchemesScreen(),
    soilAnalysis: (context) => const SoilAnalysisScreen(),
    weatherForecast: (context) => WeatherForecastScreen(),
    ProfileScreen.routeName: (context) => const ProfileScreen(),
    MandiPricesScreen.routeName: (context) => const MandiPricesScreen(),
    TasksScreen.routeName: (context) => const TasksScreen(),

  };
}
