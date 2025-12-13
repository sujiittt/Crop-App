import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// app-wide exports
import 'core/app_export.dart';

// REAL notification service (the one we created)
import 'services/notification_service.dart';

// home
import 'presentation/dashboard_screen/dashboard_screen.dart';

// screens
import 'presentation/government_schemes_screen/government_schemes_screen.dart';
import 'presentation/weather_forecast_screen/weather_forecast_screen.dart';
import 'presentation/soil_analysis_screen/soil_analysis_screen.dart';
import 'presentation/crop_recommendations_screen/crop_recommendations_screen.dart';
import 'presentation/mandi_prices_screen/mandi_prices_screen.dart';
import 'presentation/profile_screen/profile_screen.dart';
import 'presentation/tasks_screen/tasks_screen.dart';
import 'presentation/farmer_registration_screen/farmer_registration_screen.dart';
import 'presentation/tasks_screen/add_task/add_task_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize REAL notifications
  await NotificationService.instance.init();

  // catch uncaught Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // ignore: avoid_print
    print('FlutterError: ${details.exceptionAsString()}');
  };

  runZonedGuarded(() {
    runApp(const CropWiseApp());
  }, (error, stack) {
    // ignore: avoid_print
    print('Uncaught zone error: $error\n$stack');
  });
}

class CropWiseApp extends StatelessWidget {
  const CropWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'CropWise',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),

          routes: {
            '/government-schemes-screen': (_) => GovernmentSchemesScreen(),
            '/weather-forecast-screen': (_) => WeatherForecastScreen(),
            '/soil-analysis-screen': (_) => SoilAnalysisScreen(),
            '/crop-recommendations-screen': (_) =>
                CropRecommendationsScreen(),
            '/mandi-prices-screen': (_) => MandiPricesScreen(),
            '/profile': (_) => ProfileScreen(),
            '/profile-screen': (_) => ProfileScreen(),
            '/tasks-screen': (_) => TasksScreen(),
            '/farmer-registration-screen': (_) =>
                FarmerRegistrationScreen(),
            AddTaskScreen.routeName: (_) => const AddTaskScreen(),
          },

          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Page not found')),
                body: Center(
                  child: Text('No route defined for "${settings.name}"'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
